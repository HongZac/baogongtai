import 'dart:convert';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:desktop/app/model/web_socket_model.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/attach_view/attach_utils.dart';
import 'package:desktop/app/ui/pages/attach_view/full_screen_wrapper.dart';
import 'package:desktop/app/ui/pages/home/base/interface/web_socket_stream_interface.dart';
import 'package:desktop/app/ui/pages/pdf_screen/pdf_screen_controller.dart';
import 'package:desktop/app/ui/pages/pdf_screen/pdf_screen_page.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';


///远程云消息列表显示窗口
class CloudServiceTaskController
    extends BaseFormController
    with WebSocketStreamInterface {

  final appService = Get.find<AppService>();

  ///接受到的云消息（如果接收到新的消息的话，旧消息的内容需要删掉）
  CloudServiceTaskEntity? cloudServiceTaskEntity;

  ///解析后的云消息列表（单个云消息可能会传过来多个内容）
  ///
  /// {
  ///
  /// 'docId': docId,
  ///
  /// 'id': id,
  ///
  /// 'progid': progid,
  ///
  /// 'category': category,
  ///
  /// 'key': item.key,
  ///
  /// 'model': <InitialPreviewConfigModel>
  ///
  /// 'url': <String>
  ///
  /// 'pdfDataModel': <PdfControllerWithKeyModel>
  ///
  /// 'view'
  ///
  /// 'controller'
  ///
  /// 'onDispose':
  ///
  /// }
  final List<Map<String, dynamic>> taskList = [];

  final Size sliderItemSize = Size(120, 70);
  ///轮播图当前显示的页面的索引
  int sliderPageIndex = 0;
  final CarouselSliderController sliderController = CarouselSliderController();
  ///前台是否显示了轮播图
  bool isShowSliderController = false;

  ///选中的需要大图显示的云消息
  ///
  /// {
  ///
  /// 'docId': docId,
  ///
  /// 'id': id,
  ///
  /// 'progid': progid,
  ///
  /// 'category': category,
  ///
  /// 'key': item.key,
  ///
  /// 'model': <InitialPreviewConfigModel>
  ///
  /// 'url': <String>
  ///
  /// 'pdfDataModel': <PdfControllerWithKeyModel>
  ///
  /// 'view'
  ///
  /// 'controller'
  ///
  /// 'onDispose':
  ///
  /// }
  Map<String, dynamic>? selectedItem;

  ///是否正在解析 ws 传过来的消息
  bool isLoadNewData = false;

  CloudServiceTaskController({
    super.progId = -1,
  });


  Future<void> onData(WebSocketModel webSocketModel) async {
    switch (webSocketModel.name){
      case 'CloudServiceTaskEntity':
        var data = json.decode(webSocketModel.data);
        if (data == null || data['payload'] == null) { return; }

        String idKey = CryptoUtils.md5CryptStr(
          '${data['token']}-${data['name']}-${data['payload']}'
        );
        CloudServiceTaskEntity newData = CloudServiceTaskEntity(
          token: data['token'],
          name: data['name'],
          payload: data['payload'],
          idKey: idKey,
        );
        if ((newData.token ?? '').isNotEmpty
            && newData.token != BaseService.profile.userId){
          return;
        }

        isLoadNewData = true;
        cloudServiceTaskEntity = null;
        selectedItem = null;
        for (var element in taskList) {
          element['onDispose']?.call();
        }
        taskList.clear();
        update();
        await Future.delayed(const Duration(seconds: 1));

        cloudServiceTaskEntity = newData;

        //region 解析消息
        switch (cloudServiceTaskEntity!.name) {
          case 'singleAttach':
            //region 取单个附件/文档附件
            try {
              Map<String, dynamic> payloadMap = json.decode(cloudServiceTaskEntity!.payload!);

              InitialPreviewConfigModel? model;
              String? url;
              Map<String, dynamic>? viewControllerMap;
              if ((payloadMap['docId'] ?? '').isEmpty) { ///附件类型
                var res = await FormRepository().getDocument(
                  payloadMap['category'],
                  payloadMap['progid'],
                  payloadMap['id'],
                );
                if (res.isSuccess) {
                  if (res.data.initialPreviewConfig != null
                      && res.data.initialPreviewConfig!.isNotEmpty) {
                    int index = res.data.initialPreviewConfig!.indexWhere(
                            (element) => element.key == payloadMap['key']);
                    model = index == -1
                        ? null
                        : res.data.initialPreviewConfig![index];
                    url = index == -1
                        ? null
                        : res.data.initialPreview![index];
                  }
                }
              }
              else { ///文档附件类型
                var res = await DocumentRepository().getModel(
                    payloadMap['docId']
                );
                if (res.isSuccess){
                  if (res.data?.initialPreviewConfig != null
                      && res.data!.initialPreviewConfig!.isNotEmpty) {
                    int index = res.data!.initialPreviewConfig!.indexWhere(
                            (element) => element.key == payloadMap['key']);
                    model = index == -1
                        ? null
                        : res.data!.initialPreviewConfig![index];
                    url = index == -1
                        ? null
                        : res.data!.initialPreview![index];
                  }
                }
              }
              ///此时的[cloudServiceTaskEntity]可能会更新成新的对象，移除掉不符合新对象的 taskItem
              taskList.removeWhere((element) => element['idKey'] != cloudServiceTaskEntity?.idKey);
              ///如果当前正在解析的消息和[cloudServiceTaskEntity]不相同，则退出
              if (cloudServiceTaskEntity?.idKey != idKey){ return; }
              if (model != null && url != null){
                viewControllerMap = getViewAndController(
                  idKey: cloudServiceTaskEntity!.idKey!,
                  model: model,
                  url: url,
                  progid: payloadMap['progid'],
                );
              }
              taskList.add({
                ...payloadMap,
                'idKey': idKey,
                'model': model,
                'url': url,
                'view': viewControllerMap?['view'],
                'controller': viewControllerMap?['controller'],
                'onDispose': viewControllerMap?['onDispose'],
              });

              ///pdf 的数据流需要异步读取
              if (model?.type == 'pdf' && (url ?? '').isNotEmpty){
                AttachUtils().getPdfUint8List(key: model!.key ?? '', url: url!).then((value){
                  taskList.removeWhere((element) => element['idKey'] != cloudServiceTaskEntity?.idKey);
                  if (cloudServiceTaskEntity?.idKey != idKey){ return; }
                  taskList.firstWhereOrNull((element) => element['model'].key == model?.key)?.addAll({
                    'pdfDataModel': value,
                  });
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                    update();
                  });
                });
              }
            } catch (e){}
            //endregion
            break;
          case 'attachs':
            //region 需要取整个附件列表/文档附件列表
            try {
              Map<String, dynamic> payloadMap = json.decode(cloudServiceTaskEntity!.payload!);

              final List<InitialPreviewConfigModel> attachList = [];
              final Map<String, String> attachInitialPreviewMap = {};
              if ((payloadMap['docId'] ?? '').isEmpty){ ///附件类型
                var res = await FormRepository().getDocument(
                  payloadMap['category'],
                  payloadMap['progid'],
                  payloadMap['id'],
                );
                if (res.isSuccess) {
                  if (res.data.initialPreviewConfig != null
                      && res.data.initialPreviewConfig!.isNotEmpty) {
                    attachList.addAll(res.data.initialPreviewConfig!);
                    Map<int, String> map = res.data.initialPreview?.asMap() ?? {};
                    for (int index = 0; index < attachList.length; index ++){
                      attachInitialPreviewMap.addAll({
                        attachList[index].key ?? '': map[index] ?? '',
                      });
                    }
                  }
                }
              }
              else { ///文档附件类型
                var res = await DocumentRepository().getModel(
                    payloadMap['docId']
                );
                if (res.isSuccess) {
                  if (res.data?.initialPreviewConfig != null
                      && res.data!.initialPreviewConfig!.isNotEmpty) {
                    attachList.addAll(res.data!.initialPreviewConfig!);
                    Map<int, String> map = res.data!.initialPreview?.asMap() ?? {};
                    for (int index = 0; index < attachList.length; index ++){
                      attachInitialPreviewMap.addAll({
                        attachList[index].key ?? '': map[index] ?? '',
                      });
                    }
                  }
                }
              }
              taskList.removeWhere((element) => element['idKey'] != cloudServiceTaskEntity?.idKey);
              if (cloudServiceTaskEntity?.idKey != idKey){ return; }
              taskList.addAll(attachList.map((e){
                String? url = attachInitialPreviewMap[e.key];
                Map<String, dynamic>? viewControllerMap;
                if (url != null){
                  viewControllerMap = getViewAndController(
                    idKey: cloudServiceTaskEntity!.idKey!,
                    model: e,
                    url: url,
                    progid: payloadMap['progid'],
                  );
                }
                return {
                  ...payloadMap,
                  'idKey': idKey,
                  'model': e,
                  'url': attachInitialPreviewMap[e.key],
                  'view': viewControllerMap?['view'],
                  'controller': viewControllerMap?['controller'],
                  'onDispose': viewControllerMap?['onDispose'],
                };
              }));

              ///pdf 的数据流需要异步读取
              for (int index = 0; index < attachList.length; index ++){
                taskList.removeWhere((element) => element['idKey'] != cloudServiceTaskEntity?.idKey);
                if (cloudServiceTaskEntity?.idKey != idKey){ break; }
                var element = attachList[index];
                String url = attachInitialPreviewMap[element.key] ?? '';
                if (element.type == 'pdf' && url.isNotEmpty) {
                  AttachUtils().getPdfUint8List(key: element.key ?? '', url: url).then((value){
                    taskList.removeWhere((element) => element['idKey'] != cloudServiceTaskEntity?.idKey);
                    if (cloudServiceTaskEntity?.idKey != idKey){ return; }

                    taskList.firstWhereOrNull((element1) => element1['model'].key == element.key)?.addAll({
                      'pdfDataModel': value,
                    });
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                      update();
                    });
                  });
                }
              }
            } catch (e){}
            //endregion
            break;
        }
        //endregion

        if (taskList.isNotEmpty){
          sliderPageIndex = 0;
          selectedItem = taskList[0];
        }
        isLoadNewData = false;
        update();
        break;
    }
  }


  Map<String, dynamic> getViewAndController({
    required String idKey,
    required InitialPreviewConfigModel model,
    required String url,
    required int progid,
  }) {
    final Map<String, dynamic> map = {};

    String tag = 'cloud-service-$idKey-${model.key}';
    switch (model.type){
      case 'pdf':
        var ctl =  Get.put<PdfScreenController>(PdfScreenController(
          pageTitle: '${model.caption ?? ''}',
          pdfUrl: AddressService.getUrl(url),
          onPressed: (){ Get.back(); }
        ), tag: tag);
        map.addAll({
          'view': PdfScreenPage(extraTag: tag,),
          'controller': ctl,
          'onDispose': (){
            Get.delete<PdfScreenController>(tag: tag, force: true);
          }
        });
        break;
      case 'image':
        map.addAll({
          'view': FullScreenWrapper(
            imageProvider: CachedNetworkImageProvider(AddressService.getUrl(url)),
            isCloudServiceView: true,
          ),
        });
        break;
      case 'mp4':
      case 'video':
        map.addAll({
          'view': const SizedBox.shrink(),
        });
        break;
      case 'doc':
      case 'docx':
      case 'office':
        map.addAll({
          'view': const SizedBox.shrink(),
        });
        break;
    }

    return map;
  }

  void sliderPageIndexOnChanged(int index) {
    sliderPageIndex = index;
    selectedItem = taskList[index];
    update();
  }

  ///跳转到指定页回调
  void sliderPageJump(int index) {
    if (isShowSliderController) {
      sliderController.animateToPage(index);
    }
    else {
      sliderPageIndexOnChanged(index);
    }
    update();
  }

  ///前进按钮回调
  void sliderPageNext() {
    if (isShowSliderController) {
      sliderController.nextPage();
    }
    else {
      sliderPageIndexOnChanged(
          sliderPageIndex == taskList.length - 1
              ? 0
              : sliderPageIndex + 1
      );
    }
    update();
  }

  ///后退按钮回调
  void sliderPagePrevious() {
    if (isShowSliderController) {
      sliderController.previousPage();
    }
    else {
      sliderPageIndexOnChanged(
          sliderPageIndex == 0
              ? taskList.length - 1
              : sliderPageIndex - 1
      );
    }
    update();
  }


  @override
  onClose() {
    for (var element in taskList) {
      element['onDispose']?.call();
    }
    super.onClose();
  }

}