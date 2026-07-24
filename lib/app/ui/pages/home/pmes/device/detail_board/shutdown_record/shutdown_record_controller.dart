import 'dart:convert';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/shutdown_record/process_type_edit_form/shutdown_record_process_type_form_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/shutdown_record/process_type_edit_form/shutdown_record_process_type_form_page.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///停机记录 670003
class ShutdownRecordController
    extends BaseFormWithPageDataController<MoProcessModel>
    with DateFilterInterface,
        CommandBarInterface,
        InfoFormInterface {

  get dateSearchTypeList => List.unmodifiable(AppConfig.shutdownRecordDateSearchTypeList);
  get dateSearchQueryDataList => List.unmodifiable(dateSearchTypeList.expand((e) => e.content.split(',')).toSet().toList());

  ///派工单列表区域显示的按钮组列表
  final List<CommandBarBtnModel> commandBarList = [
    CommandBarBtnModel(
      title: '反馈停机原因',
      keyName: 'shutdownRecord-processType',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.filled,
      isShow: true,
      btnPermissionKeyName: 'editbtn',
    ),
    CommandBarBtnModel(
      title: '\u00A0\u00A0\u00A0\u00A0展开\u00A0\u00A0\u00A0\u00A0',
      keyName: 'shutdownRecord-expanded',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.outlined,
      isShow: true,
    ),
  ];

  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> shutdownRecordListInfoFormListMap = {
    0: [
      //InfoFormModel(keyName: 'DeviceCode', title: '设备编号', width: 320, groupType: 0, isShow: true),
      //InfoFormModel(keyName: 'DeviceName', title: '设备名称', width: 320, groupType: 0, isShow: true),
      InfoFormModel(keyName: 'ProcessClass', title: '停机类型', width: 320, groupType: 0, isShow: true),
      InfoFormModel(keyName: 'StopTime', title: '停机时长', width: 320, groupType: 0, isShow: true),
      InfoFormModel(keyName: 'ProcessDate', title: '记录时间', width: 320, groupType: 0, isShow: true),
      InfoFormModel(keyName: 'ProcessTime', title: '开始时间', width: 320, groupType: 0, isShow: true),
      InfoFormModel(keyName: 'OverTime', title: '结束时间', width: 320, groupType: 0, isShow: true),
      InfoFormModel(keyName: 'Description', title: '备注', width: 320, groupType: 0, isShow: true),
    ],
    1: [
      //InfoFormModel(keyName: 'Operator', title: '操作人员', width: 320, groupType: 0, isShow: true),
      //InfoFormModel(keyName: 'OperateDate', title: '操作时间', width: 320, groupType: 0, isShow: true),
      InfoFormModel(keyName: 'MouldCode', title: '模具编号', width: 320, groupType: 0, isShow: true),
      InfoFormModel(keyName: 'MouldName', title: '模具名称', width: 320, groupType: 0, isShow: true),
    ],
  };

  final String deviceId;


  ShutdownRecordController({
    super.progId = 670003,
    required this.deviceId,
  });


  void onInit() {
    super.onInit();
    dataListPageConfig.sidx = 'ProcessDate';
    dataListPageConfig.sord = 'desc';
    dataListPageConfig.rows = 7;
    dataListPageConfig.queryData = {
      'DeviceId': deviceId,
      'ProcessClass': '2,4,8',
    };
    datePickerValueMap = getDatePickerValueMapByStorage(
      jsonEncode(AppConfig.todayDatePickerValueMap)
    );
    dateQueryDataOnChanged();
  }

  @override
  Future<PageResult<MoProcessModel>> getDataList(PageConfig pageConfig) async {
    var res = await MoProcessRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取停机记录列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }


  //region 日期搜索

  @override
  Future<void> dateOnChanged(String string) async {
    DateTime? oldStartDate = startDate;
    DateTime? oldEndDate = endDate;
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    await super.dateOnChanged(string);
    if (oldStartDate == startDate && oldEndDate == endDate){
      isLoading = false;
      return;
    }
    dateQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }
  void dateQueryDataOnChanged() {
    dataListPageConfig.queryData!.removeWhere((key, value) => dateSearchQueryDataList.contains(key));
    if (startDate != null && endDate != null){
      String keyWord = dateSearchTypeList[dateSearchTypeIndex].content;
      List<String> keywordList = keyWord.split(',');
      if (keywordList.length == 2){
        dataListPageConfig.queryData![keywordList[0]] = startDateStrWithNoTime;
        dataListPageConfig.queryData![keywordList[1]] = endDateStrWithNoTime;
      }
    }
  }

  //endregion


  @override
  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {
    item as MoProcessModel;
    switch (keyName){
      case 'shutdownRecord-processType':
        await editProcessType(item);
        break;
      case 'shutdownRecord-expanded':
        itemExpandedOnChanged(item);
        break;
    }
  }


  ///Item“展开按钮”点击变化
  void itemExpandedOnChanged(MoProcessModel item){
    item.isExpanded = !item.isExpanded;
    update();
  }

  ///反馈停机原因
  Future<void> editProcessType(MoProcessModel item) async {
    if (item.processId == null || item.processId!.isEmpty){
      ToastNotification(Get.overlayContext!).warn("数据错误！");
      return;
    }
    var res = await DialogUtils.showCustomDialog<ShutdownRecordProcessTypeFormController, String>(
      Get.context!,
      title: '反馈停机原因',
      isMaximize: true,
      contentPadding: const EdgeInsets.all(0),
      content: ShutdownRecordProcessTypeFormPage(),
      controller: ShutdownRecordProcessTypeFormController(
        processType: item.processType.toString(),
        desc: item.description,
        operatorId: item.operator,
        processId: item.processId ?? '',
      ),
    );

    if (res != null && res.isNotEmpty){
      ProgressDialogUtil.showProgressDialog(msg: '正在刷新数据', completedMsg: '数据刷新成功！');
      var res = await MoProcessRepository().getEntity(item.processId ?? '');
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).warn('获取刷新数据时出错：${res.message}');
        ProgressDialogUtil.close();
        return;
      }
      item.fromJson(res.data.toJson());
      update();
      ProgressDialogUtil.update();
    }
  }

}