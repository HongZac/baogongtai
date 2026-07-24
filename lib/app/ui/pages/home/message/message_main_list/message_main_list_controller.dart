import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/command_bar.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/toast_notification.dart';


///系统消息 —— 详细列表页面
class MessageMainListController extends BaseFormWithPageDataController<MsgReceiveModel>{

  final int typeId;
  MsgReceiveModel selectedMsgReceiveModel = MsgReceiveModel();

  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now();

  final double? fontSize = Theme.of(Get.context!).textTheme.bodyLarge!.fontSize;
  final double? iconSize = Theme.of(Get.context!).textTheme.bodyLarge!.fontSize! * 1.43;
  late final List<CommandBarItem> commandBarList = [
    //region
    CommandBarButton(
      label: '标为已读',
      icon: Icons.local_print_shop_rounded,
      fontSize: fontSize,
      iconSize: iconSize,
      onPressed: () async{ await messageIsRead(true); },
    ),
    CommandBarButton(
      label: '标为未读',
      icon: Icons.fact_check_rounded,
      fontSize: fontSize,
      iconSize: iconSize,
      onPressed: () async{ await messageIsRead(false); },
    ),
    //endregion
  ];


  MessageMainListController({
    required this.typeId,
    super.progId = 150001,
  });


  @override
  void onInit() {
    super.onInit();
    dataListPageConfig.rows = 10;
    dataListPageConfig.sidx = 'msChecked asc,msCreateDate desc';
    dataListPageConfig.queryData = {
      'StartTime': '${DateUtil.getDateStrByDateTime(startDate,
          format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00',
      'EndTime': '${DateUtil.getDateStrByDateTime(endDate,
          format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00'
    };
  }

  @override
  Future<PageResult<MsgReceiveModel>> getDataList(PageConfig pageConfig) async{
    selectedMsgReceiveModel = MsgReceiveModel();
    var res = await MessageRepository().getPageList(pageConfig, typeId);
    if (res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取消息列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }

  ///消息选中变变化
  Future<void> messageOnSelected(MsgReceiveModel item) async{
    if (!item.isChoice){
      for (var element in dataList) {
        if (element.messageId == item.messageId){
          element.isChoice = true;
        }
        else {
          element.isChoice = false;
        }
      }
      selectedMsgReceiveModel = item;
    }
    else {
      item.isChoice = false;
      selectedMsgReceiveModel = MsgReceiveModel();
    }
    update();
  }

  Future<void> dateChanged(String string) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (string.isEmpty){
      startDate = null;
      endDate = null;
      dataListPageConfig.queryData!['StartTime'] = null;
      dataListPageConfig.queryData!['EndTime'] = null;
    }
    else {
      List<String> dateList = string.split('到');
      if (dateList.length != 2){
        ToastNotification(Get.overlayContext!).error("日期数据错误！");
        isLoading = false;
        return;
      }
      startDate = DateTime.tryParse(dateList[0]) ?? DateTime.now();
      endDate = DateTime.tryParse(dateList[1]) ?? DateTime.now();
      dataListPageConfig.queryData!['StartTime'] = '${DateUtil.getDateStrByDateTime(
          startDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
      dataListPageConfig.queryData!['EndTime'] = '${DateUtil.getDateStrByDateTime(
          endDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
    }
    await pageChanged(pageIndex: 1);
    update();
    isLoading = false;
  }

  ///设置已读 OR 未读
  Future<void> messageIsRead(bool isRead) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn("正在提交数据！");
      return;
    }
    isLoading = true;
    if (selectedMsgReceiveModel.messageId == null || selectedMsgReceiveModel.messageId!.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择消息！");
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认设置${isRead ? '已读' : '未读'}？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在设置${isRead ? '已读' : '未读'}', completedMsg: '设置成功！');
    //region 设置已读 OR 未读
    var res = await MessageRepository().setMessageRead(selectedMsgReceiveModel.messageId!, isRead);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('设置失败！${res.message}！');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');
    //endregion
    //region 刷新
    dataList.removeWhere((element) => element.messageId == selectedMsgReceiveModel.messageId);
    total --;
    selectedMsgReceiveModel = MsgReceiveModel();
    update();
    ProgressDialogUtil.update(value: 2);
    //endregion
    isLoading = false;
  }

  @override
  void onClose() async {
    super.onClose();
  }
}