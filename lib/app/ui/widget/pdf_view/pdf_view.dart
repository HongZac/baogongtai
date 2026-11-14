import 'dart:math';

import 'package:desktop/app/ui/widget/pdf_view/pdf_view_data_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart';


///PDF 浏览视图
class PdfView extends StatefulWidget {

  final Uint8List pdfFileUint8List;
  final ValueChanged<PdfViewDataManager>? onLoaded;


  const PdfView({
    super.key,
    required this.pdfFileUint8List,
    this.onLoaded,
  });

  @override
  State<StatefulWidget> createState() => PdfViewState();
}


class PdfViewState extends State<PdfView> {

  int _documentIndex = 0;

  late final PdfViewDataManager pdfViewDataManager = PdfViewDataManager(
    setState: () {
      if (!mounted) { return; }
      setState(() {});
    },
  );

  PdfDocumentRefData _createPdfDocumentRef(Uint8List pdfFileUint8List) {
    _documentIndex ++;
    return PdfDocumentRefData(
      pdfFileUint8List,
      sourceName: 'pdf-view-${identityHashCode(this)}-$_documentIndex',
      useProgressiveLoading: true,
    );
  }

  void _setPdfDocumentRef(Uint8List pdfFileUint8List) {
    pdfViewDataManager.rotateDataMap[PdfPageRotation.none] = pdfFileUint8List;
    pdfViewDataManager.pdfDocumentRef = _createPdfDocumentRef(pdfFileUint8List);
  }


  @override
  void initState() {
    super.initState();
    _setPdfDocumentRef(widget.pdfFileUint8List);
    widget.onLoaded?.call(pdfViewDataManager);
  }

  @override
  void didUpdateWidget(covariant PdfView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pdfFileUint8List != oldWidget.pdfFileUint8List){
      pdfViewDataManager.rotateDataMap.clear();
      pdfViewDataManager.currentPdfPageRotation = PdfPageRotation.none;
      pdfViewDataManager.pdfDocumentRef = null;
      Future.delayed(const Duration(milliseconds: 100), (){
        if (!mounted) { return; }
        _setPdfDocumentRef(widget.pdfFileUint8List);
        setState(() {  });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (pdfViewDataManager.pdfDocumentRef == null || widget.pdfFileUint8List.isEmpty){
      return const SizedBox.shrink();
    }
    return PdfViewer(
      pdfViewDataManager.pdfDocumentRef!,
      controller: pdfViewDataManager.pdfViewerController,
      params: PdfViewerParams(
        keyHandlerParams: PdfViewerKeyHandlerParams(autofocus: true),
        sizeDelegateProvider: PdfViewerSizeDelegateProviderSmart(),
        onDocumentChanged: (PdfDocument? document) async {
          ///函数通知文档已加载/更改，
          ///即使文档为空（这意味着文档已被卸载），也会调用该函数
          if (document == null) {
            pdfViewDataManager.isOnReady = false;
          }
        },
        onViewerReady: (PdfDocument document, PdfViewerController controller) async {
          ///查看器已准备好进行交互
          pdfViewDataManager.isOnReady = true;
          pdfViewDataManager.initZoom = controller.currentZoom;
          if (pdfViewDataManager.zoom != null){
            await pdfViewDataManager.zoomOnChanged(
              zoom: pdfViewDataManager.zoom,
              duration: const Duration(milliseconds: 0),
            );
          }
          else {
            pdfViewDataManager.zoom = controller.currentZoom;
          }
          pdfViewDataManager.notify();
        },
        loadingBannerBuilder: (BuildContext context, int bytesDownloaded, int? totalBytes){
          return Center(
            child: SpinKitCircle(
              color: Colors.lightBlue,
              size: min(Get.width, Get.height) * 0.2,
            ),
          );
        },
        viewerOverlayBuilder: (BuildContext context, Size size, PdfViewerHandleLinkTap handleLinkTap) => [
          ///双击放大缩小
          PdfOverlayInteractionRegion(
            onDoubleTap: (details) {
              pdfViewDataManager.pdfViewerController.zoomUp(loop: true);
              return true;
            },
            child: SizedBox(width: size.width, height: size.height),
          ),
        ],
      ),

    );
  }

  @override
  void dispose() {
    pdfViewDataManager.dispose();
    super.dispose();
  }

}
