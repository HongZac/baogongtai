import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///工作流程-全场呼叫 主界面
class DeviceAndonController extends GetxController{

  final String deviceId;

  final List<WfSchemeInfoModel> schemeInfoList = [];
  final ScrollController schemeInfoListScrollController = ScrollController();

  ///是否在提交数据
  bool isLoading = false;


  DeviceAndonController({required this.deviceId,});


  @override
  void onInit() async{
    super.onInit();
  }

  @override
  Future<void> onReady() async{
    super.onReady();
    ProgressDialogUtil.showProgressDialog();
    var res1 = await getSchemeInfoPageList();
    update();
    if (!res1){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1);
    }
  }

  Future<bool> getSchemeInfoPageList() async{
    PageConfig pageConfig = PageConfig(
        page: 1,
        rows: 100,
        queryData: {
          'Category': '全场呼叫',
        }
    );
    var res = await FlowSchemeRepository().getPageList(pageConfig);
    if (!res.isSuccess) {
      ToastNotification(Get.overlayContext!).error('获取安灯流程模板列表时出错：${res.message}！');
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