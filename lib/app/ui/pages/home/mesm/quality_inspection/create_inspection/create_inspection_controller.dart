
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/pages/attach_view/attach_controller.dart';
import 'package:desktop/app/ui/pages/attach_view/attach_page.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生成报检单（首巡末完自 检）
class CreateInspectionController extends BaseFormController {

  ///报检分类 0:全部 1:来料检验 2:首检 4:巡检 8:末检 16：产品终检（完检）
  final int category;
  late final int progID = category == IPQCCategory.sj.category
      || category == IPQCCategory.xj.category
      || category == IPQCCategory.mj.category
      || category == IPQCCategory.zj.category
      ? 811011
      : category == IPQCCategory.wj.category
      ? 811031
      : -1;
  late final String categoryTitle = category == IPQCCategory.sj.category
      ? '首检'
      : category == IPQCCategory.xj.category
      ? '巡检'
      : category == IPQCCategory.mj.category
      ? '末检'
      : category == IPQCCategory.wj.category
      ? '产品终检'
      : '';
  /// 源单progid
  ///
  ///case 610001: 生产任务单；
  ///case 611001: 注塑任务单；
  ///case 650011: 生产派工单；
  ///case 651011: 机台派工单；
  final int sourceProgid;
  late final sourceTitle = sourceProgid == 610001
      ? '生产任务单'
      : sourceProgid == 611001
      ? '注塑任务单'
      : sourceProgid == 650011
      ? '生产派工单'
      : sourceProgid == 651011
      ? '机台派工单'
      : '';
  /// 源单单据id
  final String sourceId;

  MoOpOrderModel orderModel = MoOpOrderModel();
  MoTaskModel taskModel = MoTaskModel();
  String opDescription = '';
  final ScrollController detailScrollController = ScrollController();
  final ScrollController dataReportScrollController = ScrollController();
  ///报检单
  MoInspectModel inspectModel = MoInspectModel();
  ProcessAdapter? processAdapter;
  ///报检数量
  TextEditingController quantityTC = TextEditingController(text: '1');
  FocusNode quantityFN = FocusNode();


  CreateInspectionController({
    super.progId = -1,
    required this.category,
    required this.sourceProgid,
    required this.sourceId,
  });


  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<bool> initializeForm() async {
    ///获取源单数据
    switch (sourceProgid){
      case 610001: ///生产任务单
      case 611001: ///注塑任务单
        //region
        var res = await MoOrderRepository().getFormData(sourceId);
        if (!res.isSuccess){
          ToastNotification(Get.overlayContext!).error('获取源单数据时出错：${res.message}');
          ProgressDialogUtil.close();
          return false;
        }
        orderModel = res.data;
        inspectModel.moOrderId = orderModel.moOrderId;
        inspectModel.sourceProgid = orderModel.progid;
        inspectModel.sourceId = orderModel.moOrderId;
        inspectModel.sourceCode = orderModel.billCode;
        inspectModel.mtoNo = orderModel.mtoNo;
        inspectModel.mtoSeq = orderModel.mtoSeq;
        inspectModel.soCode = orderModel.soCode;
        inspectModel.invId = orderModel.productId;
        inspectModel.batch = orderModel.batch;
        inspectModel.depId = orderModel.depId;
        inspectModel.deviceId = orderModel.deviceId;
        inspectModel.wcId = orderModel.wcId;
        inspectModel.mouldId = orderModel.mouldId;

        inspectModel.invCode = orderModel.invCode;
        inspectModel.invName = orderModel.productName;
        inspectModel.invStd = orderModel.productStd;

        await getProcessAdapter();
        //endregion
        break;
      case 650011: ///生产派工单
      case 651011: ///机台派工单
        //region
        var res = await MoTaskRepository().getFormData(sourceId);
        if (!res.isSuccess){
          ToastNotification(Get.overlayContext!).error('获取源单数据时出错：${res.message}');
          ProgressDialogUtil.close();
          return false;
        }
        taskModel = res.data;
        var res2 = await MoWorkBillRepository().getFormData('', '', {'ObjectId': taskModel.moOrderId}, 0);
        if (!res2.isSuccess){
          ToastNotification(Get.overlayContext!).error('获取源单对应的工序计划单时出错：${res2.message}');
          ProgressDialogUtil.close();
          return false;
        }
        MoWorkBillEntryModel? workBillEntryModel = res2.data.entryList.firstWhereOrNull((element) => element.id == taskModel.moOpId);
        inspectModel.moOrderId = taskModel.moOrderId;
        inspectModel.workBillEntryId = taskModel.moOpId;
        inspectModel.taskId = taskModel.taskId;
        inspectModel.sourceProgid = taskModel.progid;
        inspectModel.sourceId = taskModel.taskId;
        inspectModel.sourceCode = taskModel.taskCode;
        inspectModel.mtoNo = taskModel.mtoNo;
        inspectModel.mtoSeq = taskModel.mtoSeq;
        inspectModel.soCode = taskModel.soCode;
        inspectModel.invId = taskModel.invId;
        inspectModel.opId = taskModel.opId;
        inspectModel.opName = taskModel.opName;
        inspectModel.batch = taskModel.batch;
        inspectModel.depId = taskModel.depId;
        inspectModel.deviceId = taskModel.deviceId;
        inspectModel.wcId = taskModel.wcId;
        inspectModel.mouldId = taskModel.mouldId;
        inspectModel.inspId = workBillEntryModel?.inspId;
        inspectModel.teamId = taskModel.teamId;

        inspectModel.invCode = taskModel.invCode;
        inspectModel.invName = taskModel.invName;
        inspectModel.invStd = taskModel.invStd;
        //endregion
        break;
    }
    inspectModel.category = category;
    inspectModel.progID = progID;
    inspectModel.sign = MoInspectSign.djy.sign;
    inspectModel.enableMark = 1;

    return true;
  }


  ///获取工序Adapter
  Future<void> getProcessAdapter() async {
    processAdapter = await AdapterHelper.getAsyncAdapter(
      'process',
      queryData: {
        'wbId': orderModel.wbId,
        'invId': orderModel.productId,
        'needGetSOP': true,
      },
      multipleSelection: false,
    ) as ProcessAdapter;
  }


  ///报检数量 减
  Future<void> changeToLastIndex() async{
    double quantity = double.tryParse(quantityTC.text) ?? 0;
    if (quantity <= 1){
      return;
    }
    quantity --;
    String str;
    if (quantity == quantity.toInt()){
      str = quantity.toStringAsFixed(0);
    }
    else {
      str = quantity.toString();
    }
    quantityTC.text = str;
    update();
  }

  ///报检数量 加
  Future<void> changeToNextIndex() async{
    double quantity = double.tryParse(quantityTC.text) ?? 0;
    quantity ++;
    String str;
    if (quantity == quantity.toInt()){
      str = quantity.toStringAsFixed(0);
    }
    else {
      str = quantity.toString();
    }
    quantityTC.text = str;
    update();
  }



  ///查看工序的技术指导书
  Future<void> processItemAttach(MoWorkBillEntryModel item, MoRoutingEntryModel? routingEntryModel) async{
    if (routingEntryModel == null || routingEntryModel.routingDId.isEmpty){
      ToastNotification(Get.overlayContext!).warn('无法获取工序图纸！');
      return;
    }
    await DialogUtils.showCustomDialog<AttachController, bool>(
      Get.context!,
      isMaximize: true,
      isNeedConfirmBtn: false,
      onCancelName: '关闭',
      title: '工序图纸-${item.opName ?? ''}',
      contentPadding:  const EdgeInsets.all(0),
      content: AttachPage(),
      controller: AttachController(
          showAppBar: false,
          pageTitle: '工序图纸-${item.opName ?? ''}',
          id: routingEntryModel.routingDId,
          progId: 660011,
          category: 'sop'
      ),
    );
  }

  ///工序选择变化
  Future<void> processOnChanged(PickerDataModel item) async {
    for (var element in processAdapter!.dataList) {
      if (element.id == item.id) {
        element.isSelected = true;
        inspectModel.workBillEntryId = element.id;
        inspectModel.opId = element.opId;
        inspectModel.opName = element.opName;
        inspectModel.inspId = element.inspId;
      }
      else {
        element.isSelected = false;
      }
    }
    update();
  }

  ///预计完成时间 选择变化
  Future<void> dueFinishDateOnChanged(DateTime? dateTime) async {
    if (dateTime == null){ return; }
    inspectModel.dueFinishDate = dateTime;
    update();
  }


  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async {
    if (actionName == DialogButtonActionEnum.confirm){
      if (isLoading) {
        ToastNotification(Get.overlayContext!).warn('正在执行！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      isLoading = true;

      //region 提交前检查
      if (sourceProgid == 610001
          && (orderModel.wbId ?? '').isNotEmpty
          && (inspectModel.workBillEntryId ?? '').isEmpty){
        ToastNotification(Get.overlayContext!).error('请选择工序！');
        isLoading = false;
        return DialogReturnDataModel(isCanCloseDialog: false);
      }

      double? quantity = double.tryParse(quantityTC.text);
      if (quantity == null || quantity < 0){
        ToastNotification(Get.overlayContext!).error('报检数量输入有误！');
        isLoading = false;
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      //endregion

      ProgressDialogUtil.showProgressDialog(msg: '正在提交报检单数据', completedMsg: '报检单数据提交成功！');

      //region 赋值
      inspectModel.createDate = DateTime.now();
      inspectModel.processDate = DateTime.now();
      inspectModel.quantity = quantity;
      //endregion
      var res = await MoInspectRepository().postVoucher('', inspectModel);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('报检单数据提交时出错：${res.message}！');
        isLoading = false;
        ProgressDialogUtil.close();
        return DialogReturnDataModel(isCanCloseDialog: false);
      }

      isLoading = false;
      ProgressDialogUtil.update();
      await ProgressDialogUtil.awaitCompletionDelay();
      return DialogReturnDataModel(isCanCloseDialog: true, data: res.data.data);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }


  @override
  void onClose() {
    super.onClose();
    detailScrollController.dispose();
    dataReportScrollController.dispose();
  }

}