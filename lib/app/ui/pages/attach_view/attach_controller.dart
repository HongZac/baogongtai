
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/model/pdf_controller_with_key_model.dart';
import 'package:desktop/app/ui/pages/attach_view/attach_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';


///附件与图片查看
class AttachController extends GetxController{

  final String id;
  final String pageTitle;
  final String category;
  final int progId;
  final bool showAppBar;

  final List<InitialPreviewConfigModel> attachList = [];
  ///附件缩略图的Map：{'invId': 'initialPreview.url'}
  final Map<String, String> attachInitialPreviewMap = {};
  final List<PdfControllerWithKeyModel> pdfControllerList = [];


  AttachController({
    required this.pageTitle,
    required this.id,
    required this.progId,
    required this.category,
    this.showAppBar = true,
  });


  @override
  void onInit() async {
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    ProgressDialogUtil.showProgressDialog();
    var res = await getAttachList();
    getPdfControllerList(attachList);
    update();
    if (res){
      ProgressDialogUtil.update(value: 1);
    }
    else {
      ProgressDialogUtil.close();
    }
  }

  Future<bool> getAttachList() async{
    attachList.clear();
    attachInitialPreviewMap.clear();
    var res = await FormRepository().getDocument(category, progId, id);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('读取附件时出错：${res.message}');
      return false;
    }
    if (res.data.initialPreviewConfig != null && res.data.initialPreviewConfig!.isNotEmpty){
      attachList.addAll(res.data.initialPreviewConfig!);
    }
    Map<int, String> map = res.data.initialPreview?.asMap() ?? {};
    for (int index = 0; index < attachList.length; index ++){
      attachInitialPreviewMap.addAll({
        attachList[index].key ?? '': map[index] ?? '',
      });
    }
    return true;
  }

  Future<void> getPdfControllerList(List<InitialPreviewConfigModel> list) async {
    for (var element in list) {
      String url = attachInitialPreviewMap[element.key ?? ''] ?? '';
      if (element.type == 'pdf' && url.isNotEmpty){
        var pdfControllerWithKeyModel = await AttachUtils().getPdfUint8List(key: element.key ?? '', url: url);
        pdfControllerList.add(pdfControllerWithKeyModel);
      }
    }
    update();
  }

}
