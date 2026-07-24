import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///工作流程-异常报告——主界面
class ExceptionReportController extends BaseFormController{

  final String deviceId;

  ///MoAndonClass列表
  final List<WfSchemeInfoModel> schemeInfoList = [];
  final ScrollController schemeInfoListScrollController = ScrollController();


  ExceptionReportController({
    super.progId = 110001,
    required this.deviceId,
  });


  @override
  void onInit() {
    super.onInit();
  }

  Future<bool> initializeForm() async {
    var res = await getSchemeInfoPageList();
    return res;
  }


  Future<bool> getSchemeInfoPageList() async{
    PageConfig pageConfig = PageConfig(
      page: 1,
      rows: 100,
      queryData: {
        'Category': '异常报告',
      }
    );
    var res = await FlowSchemeRepository().getPageList(pageConfig);
    if (!res.isSuccess) {
      ToastNotification(Get.overlayContext!).error('获取流程模板列表时出错：${res.message}！');
      return false;
    }
    schemeInfoList.clear();
    schemeInfoList.addAll(res.rows);
    return true;
  }


  @override
  void onClose() {
    schemeInfoListScrollController.dispose();
    super.onClose();
  }

}