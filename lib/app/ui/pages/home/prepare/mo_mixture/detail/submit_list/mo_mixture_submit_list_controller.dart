
import 'dart:typed_data';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/detail_tab/mo_mixture_detail_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/submit/mo_mixture_submit_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/mo_mixture_controller.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/command_bar.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

///拌料报工单列表 651073 OR 粉料报工单列表 651078
class MoMixtureSubmitListController
    extends BaseFormWithPageDataController<MoMixSubmitModel>
    with InterfaceUtil {

  final int mainProgId;
  late final String typeTitle = mainProgId == 651071 ? '拌料' : mainProgId == 651076 ? '粉料' : '';

  final String moMixtureId;

  ///报工单列表中选中的报工单
  MoMixSubmitModel selectedSubmitModel = MoMixSubmitModel();

  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now();

  ///报工单删除时间限制
  late int? limitTime = ShareStorageUtil.instance?.read(ShareKeyUtil().getMoPowderSharedPreferencesKey(
      mainProgId,
      SharedPreferencesKeys.MO_MIXTURE_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY
  )) ?? AppConfig.limitTime;

  final double? fontSize = Theme.of(Get.context!).textTheme.bodyLarge!.fontSize;
  final double? iconSize = Theme.of(Get.context!).textTheme.bodyLarge!.fontSize! * 1.43;
  late final List<CommandBarItem> commandBarList = [
    //region
    CommandBarButton(
      label: '补打',
      icon: Icons.local_print_shop_rounded,
      fontSize: fontSize,
      iconSize: iconSize,
      onPressed: () async{ await printBarcode(); },
    ),
    CommandBarButton(
      label: '删除',
      icon: FluentIcons.delete_24_filled,
      fontSize: fontSize,
      iconSize: iconSize,
      onPressed: () async{ await deleteSubmit(); },
    ),
    //endregion
  ];


  MoMixtureSubmitListController({
    required super.progId,
    required this.moMixtureId,
    required this.mainProgId,
  });


  @override
  void onInit()  {
    super.onInit();
    dataListPageConfig.rows = 5;
    dataListPageConfig.sidx = 'CreateDate';
    dataListPageConfig.queryData = {
      'progid': progId,
      'MoMixId': moMixtureId,
      'startdate': '${DateUtil.getDateStrByDateTime(startDate,
          format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00',
      'enddate': '${DateUtil.getDateStrByDateTime(endDate,
          format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00'
    };
  }

  @override
  Future<PageResult<MoMixSubmitModel>> getDataList(PageConfig pageConfig) async{
    selectedSubmitModel = MoMixSubmitModel();
    var res = await MoMixSubmitRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取$typeTitle报工单列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }

  ///报工单选中变变化
  Future<void> submitOnSelected(MoMixSubmitModel item) async{
    if (!item.isChoice){
      for (var element in dataList) {
        if (element.moMixSubmitId == item.moMixSubmitId){
          element.isChoice = true;
        }
        else {
          element.isChoice = false;
        }
      }
      selectedSubmitModel = item;
    }
    else {
      item.isChoice = false;
      selectedSubmitModel = MoMixSubmitModel();
    }
    update();
  }

  ///报工单Item“展开按钮”点击变化
  void submitExpandedOnChanged(MoMixSubmitModel item){
    item.isExpanded = !item.isExpanded;
    update();
  }


  ///日期筛选
  Future<void> dateChanged(String string) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (string.isEmpty){
      startDate = null;
      endDate = null;
      dataListPageConfig.queryData!['startdate'] = null;
      dataListPageConfig.queryData!['enddate'] = null;
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
      dataListPageConfig.queryData!['startdate'] = '${DateUtil.getDateStrByDateTime(
          startDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
      dataListPageConfig.queryData!['enddate'] = '${DateUtil.getDateStrByDateTime(
          endDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
    }
    await pageChanged(pageIndex: 1);
    update();
    isLoading = false;
  }

  //region 工具栏回调

  ///补打
  Future<void> printBarcode() async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 提交前判断
    if (selectedSubmitModel.moMixSubmitId == null || selectedSubmitModel.moMixSubmitId!.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择要补打的报工单！");
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认补打？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    Map<String, dynamic> printInfoMap = await getPrintInfo();
    String printerUrl = printInfoMap['printerUrl']!; ///打印机Url
    String printerName = printInfoMap['printerName']!; ///打印机Name
    //int defaultPrintCopies = printInfoMap['printCopies']!; ///打印份数
    //String printType = printInfoMap['printType']!; ///打印方式
    //region 获取模板文件名称 frxName
    String frxName = ShareStorageUtil.instance?.read(ShareKeyUtil().getMoPowderSharedPreferencesKey(
        mainProgId,
        SharedPreferencesKeys.MO_MIXTURE_SUBMIT_TEMPLATE_FILENAME_KEY
    )) ?? AppConfigUtil().getMoPowderAppConfig(mainProgId, AppConfig.moMixtureSubmitPrintFileName);
    if (frxName.isEmpty){
      ToastNotification(Get.overlayContext!).error('打印的模板名称为空，请在设置中修改！');
      isLoading = false;
      return;
    }
    //endregion
    //endregion
    ProgressDialogUtil.showProgressDialog(msg: '正在打印', completedMsg: '打印成功！');
    String url = MoMixSubmitRepository().getPrintUrl(selectedSubmitModel.moMixSubmitId!, frxName, 'pdf');
    Printer? printer = Printer(url: printerUrl, name: printerName);
    AppRepository().downloadFile(
      url,
      onReceiveProgress: (int current, int length){
        if (length == 0){
          length = 1;
        }
        var process = current / length;
        PrintUtil.printDebug(process.toString());
      },
      onDone: (Uint8List data) async {
        if (!kIsWeb && GetPlatform.isWindows){
          await Printing.directPrintPdf(
            printer: printer,
            onLayout: (format) => Future.value(data),
            usePrinterSettings: true,
          );
        }
        else {
          await Printing.layoutPdf(
            onLayout: (format) => Future.value(data),
            usePrinterSettings: true,
          );
        }
        isLoading = false;
        ProgressDialogUtil.update(value: 1);
        ToastNotification(Get.overlayContext!).info("打印完成，共${selectedSubmitModel.number?.toInt() ?? 0}份！");
      },
      onError: (String message){
        ToastNotification(Get.overlayContext!).error("打印文件生成失败！");
        isLoading = false;
        ProgressDialogUtil.close();
        return;
      },
    );
  }

  ///删除报工单
  Future<void> deleteSubmit() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (selectedSubmitModel.moMixSubmitId == null || selectedSubmitModel.moMixSubmitId!.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择要删除的报工单！");
      isLoading = false;
      return;
    }
    if (selectedSubmitModel.createDate != null && limitTime != null
        && selectedSubmitModel.createDate!.add(Duration(seconds: limitTime!)).isBefore(DateTime.now())){
      ToastNotification(Get.overlayContext!).warn("该报工单的提交时间已超过$limitTime秒，不能删除！");
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认删除报工记录？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在删除报工记录', completedMsg: '数据刷新成功！');
    //region 报工单删除
    var res = await MoMixSubmitRepository().deleteEntity(selectedSubmitModel.moMixSubmitId!);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('删除报工记录时出错：${res.message}！');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '删除成功，正在刷新数据！');
    //endregion
    //region 数据刷新
    dataList.removeWhere((element) => element.moMixSubmitId == selectedSubmitModel.moMixSubmitId);
    total --;
    //region
    var mixtureRes = await MoMixtureRepository().getModel(selectedSubmitModel.moMixId ?? '');
    if (!mixtureRes.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取拌料单信息时出错：${mixtureRes.message}');
      ProgressDialogUtil.close();
      isLoading = false;
      update();
      return;
    }
    MoMixtureModel mixtureModel = mixtureRes.data;

    //region 首页
    MoMixtureController mixtureController = Get.find<MoMixtureController>(tag: mainProgId.toString());
    MoMixtureModel? mixture = mixtureController.dataList.firstWhereOrNull((element) => element.moMixtureId == selectedSubmitModel.moMixId);
    if (mixture != null){
      mixture.submitQty = mixtureModel.submitQty;
    }
    mixtureController.update();
    //endregion

    MoMixtureDetailTabController? mixtureDetailTabController;
    try {
      mixtureDetailTabController = Get.find<MoMixtureDetailTabController>();
    } catch(e){}
    if (mixtureDetailTabController != null){
      //region 报工页
      MoMixtureSubmitController? mixtureSubmitController;
      try {
        mixtureSubmitController = Get.find<MoMixtureSubmitController>();
      } catch (e){}
      if (mixtureSubmitController != null){
        if (mixtureSubmitController.mixtureModel.moMixtureId == selectedSubmitModel.moMixId){
          mixtureSubmitController.mixtureModel.submitQty = mixtureModel.submitQty;
        }
        mixtureSubmitController.update();
      }
      //endregion
    }
    //endregion
    isLoading = false;
    selectedSubmitModel = MoMixSubmitModel();
    update();
    ProgressDialogUtil.update(value: 2);
  }

  //endregion


  @override
  void onClose() {
    super.onClose();
  }

}