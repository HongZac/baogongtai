import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';


class PdfViewDataManager extends ChangeNotifier {

  PdfViewDataManager({
    this.setState,
  }){
    pdfViewerController.addListener(_pdfControllerListener);
  }


  ///pdf视图的控制器
  final PdfViewerController pdfViewerController = PdfViewerController();
  ///用于控制 PdfDocument 的加载/缓存
  PdfDocumentRef? pdfDocumentRef;

  ///旋转数据缓存
  final Map<PdfPageRotation, Uint8List> rotateDataMap = {};
  ///当前旋转角度
  PdfPageRotation currentPdfPageRotation = PdfPageRotation.none;

  ///当前缩放比例（页码旋转后，pdfViewerController.currentZoom 会被重置，需要手动记录）
  double? zoom;
  ///初始化缩放比例
  double? initZoom;

  ///pdf 视图是否已经加载完成（区别于[pdfViewerController.isReady]）
  bool isOnReady = false;

  ///记录当前目标页（用于通知其他页面，当前目标页码已改变）
  int? pageNumber;

  int _documentRefIndex = 0;
  bool _isDisposed = false;


  ///[PdfView]控件刷新通知回调
  void Function()? setState;


  PdfDocumentRefData _createPdfDocumentRef(Uint8List pdfData) {
    _documentRefIndex ++;
    return PdfDocumentRefData(
      pdfData,
      sourceName: 'pdf-view-data-manager-${identityHashCode(this)}-$_documentRefIndex',
      useProgressiveLoading: true,
    );
  }


  //region

  ///跳转到指定页码
  void pageOnChanged(int pageNumber){
    if (pdfViewerController.isReady
        && pageNumber > 0
        && pdfViewerController.pageCount > 0
        && pdfViewerController.pageCount >= pageNumber
        && pdfViewerController.pageNumber != pageNumber){
      pdfViewerController.goToPage(
        pageNumber: pageNumber,
        anchor: PdfPageAnchor.topCenter,
      );
      notify();
    }
  }

  ///还原
  Future<void> reduction() async {
    if (pdfViewerController.isReady && pdfViewerController.pageCount > 0){
      currentPdfPageRotation = PdfPageRotation.none;
      zoom = null;
      pdfViewerController.setZoom(
        pdfViewerController.centerPosition,
        initZoom ?? 1,
        duration: const Duration(milliseconds: 0),
      );
      await _setRotatePdfPage(currentPdfPageRotation);
      setState?.call();
      notify();
    }
  }

  ///顺（逆）时针旋转90度；[isCW]：是否是顺时针
  Future<void> rotate(bool isCW) async {
    if (pdfViewerController.isReady && pdfViewerController.pageCount > 0) {
      if (isCW) {
        currentPdfPageRotation = currentPdfPageRotation == PdfPageRotation.none
            ? PdfPageRotation.clockwise90
            : currentPdfPageRotation == PdfPageRotation.clockwise90
            ? PdfPageRotation.clockwise180
            : currentPdfPageRotation == PdfPageRotation.clockwise180
            ? PdfPageRotation.clockwise270
            : PdfPageRotation.none;
      }
      else {
        currentPdfPageRotation = currentPdfPageRotation == PdfPageRotation.none
            ? PdfPageRotation.clockwise270
            : currentPdfPageRotation == PdfPageRotation.clockwise270
            ? PdfPageRotation.clockwise180
            : currentPdfPageRotation == PdfPageRotation.clockwise180
            ? PdfPageRotation.clockwise90
            : PdfPageRotation.none;
      }

      await _setRotatePdfPage(currentPdfPageRotation);

      setState?.call();
      notify();
    }
  }

  Future<void> _setRotatePdfPage(PdfPageRotation pdfPageRotation) async {
    if (!rotateDataMap.containsKey(pdfPageRotation)){
      final sourcePdfData = rotateDataMap[PdfPageRotation.none];
      if (sourcePdfData == null || sourcePdfData.isEmpty){
        return;
      }
      PdfDocument? sourcePdfDocument;
      PdfDocument? newPdfDocument;
      try {
        sourcePdfDocument = await PdfDocument.openData(
          sourcePdfData,
          sourceName: 'pdf-rotate-source-${identityHashCode(this)}-${pdfPageRotation.index}',
          useProgressiveLoading: false,
        );
        if (_isDisposed) { return; }
        List<PdfPage> newPages = sourcePdfDocument.pages.map(
                (e) => e.rotatedBy(pdfPageRotation)).toList();
        newPdfDocument = await PdfDocument.createNew(
          sourceName: 'pdf-rotate-${identityHashCode(this)}-${pdfPageRotation.index}'
        );
        if (_isDisposed) { return; }
        newPdfDocument.pages = newPages;
        Uint8List pdfBytes = await newPdfDocument.encodePdf();
        if (_isDisposed) { return; }
        rotateDataMap.addAll({pdfPageRotation: pdfBytes});
      } finally {
        await newPdfDocument?.dispose();
        await sourcePdfDocument?.dispose();
      }
    }
    if (_isDisposed) { return; }

    pdfDocumentRef = null;
    setState?.call();
    await Future.delayed(const Duration(milliseconds: 100));
    if (_isDisposed) { return; }
    final pdfData = rotateDataMap[pdfPageRotation];
    if (pdfData == null) { return; }
    pdfDocumentRef = _createPdfDocumentRef(pdfData);
  }

  ///缩小（放大）[isZoomOut]：是否是缩小
  Future<void> zoomOnChanged({double? zoom, bool? isZoomOut, Duration? duration}) async {
    assert((zoom == null) != (isZoomOut == null));
    if (pdfViewerController.isReady && pdfViewerController.pageCount > 0){
      double newZoom;
      if (zoom != null){
        newZoom = zoom;
      }
      else {
        newZoom = isZoomOut!
            ? pdfViewerController.currentZoom - 0.7
            : pdfViewerController.currentZoom + 0.7;
      }
      newZoom = newZoom > 10
          ? 10
          : newZoom < 0.1
          ? 0.1
          : newZoom;
      await pdfViewerController.setZoom(
          pdfViewerController.centerPosition,
          newZoom,
          duration: duration ?? const Duration(milliseconds: 200),
      );
      notify();
    }
  }

  //endregion


  Future<void> _pdfControllerListener() async {
    if (isOnReady){
      bool isNeedNotify = false;
      if (zoom != pdfViewerController.currentZoom) {
        zoom = pdfViewerController.currentZoom;
        isNeedNotify = true;
      }

      if (pageNumber != pdfViewerController.pageNumber){
        pageNumber = pdfViewerController.pageNumber;
        isNeedNotify = true;
      }

      if (isNeedNotify){
        notify();
      }
    }
  }


  void notify(){
    ///防止出错 A MinePaginationNotifier was used after being disposed
    if (hasListeners){
      notifyListeners();
    }

  }

  @override
  void dispose(){
    _isDisposed = true;
    pdfViewerController.removeListener(_pdfControllerListener);
    rotateDataMap.clear();
    currentPdfPageRotation = PdfPageRotation.none;
    pdfDocumentRef = null;
    super.dispose();
  }

}