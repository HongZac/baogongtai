import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/mes_submit_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_interface.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_button_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';


///任务单报工接口（一定是生产报工，650041）
mixin OrderSubmitInterface
on SubmitInterface, MesSubmitInterface {

  ///要报工的任务单数据（初始值：上一个页面选中的任务单）
  MoOpOrderModel orderModel = MoOpOrderModel();

  ///选中的岗位列表（用于筛选工序，可以通过班组、员工来改变该值）
  final List<String> postIdList = [];

  ///是否显示工序说明行
  bool isShowOpDescription = AppConfig.isShowOpDescription;
  ///工序说明查看
  String opDescription = '';

  ///是否显示报工汇总（工序班组日期）
  bool isShowOpTgSubmitQty = AppConfig.isShowOpTgSubmitQty;
  ///选中工序 + 选中班组 + 当日 报工总数量（当日报工）
  double? opTGDailySubmitQty;
  ///选中工序 报工总数量（总报工数）
  double? opSubmitQty;
  ///当日总报工数量
  double? dayQty;

  final WeightMsgConnectService _weightMsgConnectService = Get.find<WeightMsgConnectService>();
  ///称重监听列表
  late final List<WeightMsgConnectModel> connectList = _weightMsgConnectService.connectList.where(
          (element) => true).toList();

  @override
  List<ChoiceChipModel> get operationWayList => List.unmodifiable(AppConfig.mesOrderSubmitOperationWayList);

  @override
  final Map<String, int?> formJudgeTypeMap = {
    'DepId': 4,
    'TeamId': 4,
    'wcId': null,
    'DeviceId': null,
    'EmpId': 4,
    'OpId': 4,
    'Qty': 116,
  };

  //region getAdapter

  ///获取工序Adapter
  Future<void> _getProcessAdapter() async {
    processAdapter = await AdapterHelper.getAsyncAdapter(
      'process',
      queryData: {
        'wbId': orderModel.wbId,
        'invId': orderModel.productId,
        'needGetSOP': true,
        'isNeedGetPostFilter': true,
        'postInitSelectedItems': postIdList.map((e) => PostModel(id: e)).toList(),
      },
      multipleSelection: !cannotOverThenTheLastOpSubmitQty && !cannotOverThenTheLastOpS,
    ) as ProcessAdapter;
  }
  ///获取工序Adapter
  Future<void> Function() get getProcessAdapter => _getProcessAdapter;

  //endregion



  //region OnChanged

  ///报工日期选择变化 （日期改变后班次Adapter重新读取）
  Future<void> _billDateOnChanged(DateTime? date) async {
    if (date == null){ return; }
    await super.billDateOnChanged(date);
    await _getOpTGSubmitQty();
    update();
  }
  Future<void> Function(DateTime? date) get billDateOnChanged => _billDateOnChanged;

  ///生产班组选择变化
  Future<void> _teamGroupOnChanged(PickerDataModel model) async {
    MoBeltLineModel item = MoBeltLineModel.fromJson(model.toJson());
    if (submitModel.wcId == item.id){ return; }
    await super.teamGroupOnChanged(item);
    await _getOpTGSubmitQty();
    ///获取当前班组下的所有员工，再选中所有员工的岗位（默认取前7个员工的岗位数据）
    var teamGroupRes = await MoBeltLineRepository().getFormData(item.id, '', null, 0);
    if (!teamGroupRes.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取该班组的员工分配信息时出错：${teamGroupRes.message}，请重试！');
    }
    else {
      List<String> postIdList = [];
      List<MoWorkCenterDetailsModel> bindPersonList = teamGroupRes.data.entryList.where(
              (element) => element.objType == 200009 && (element.objId ?? '').isNotEmpty).toList();
      bindPersonList = bindPersonList.length > 7 ? bindPersonList.sublist(0, 7) : bindPersonList;
      for (var element in bindPersonList){
        var postRes = await PersonRepository().getPostList(element.objId!);
        if (!postRes.isSuccess){
          ToastNotification(Get.overlayContext!).error('获取员工岗位数据时出错：${postRes.message}，请重试！');
          return;
        }
        postIdList.addAll(postRes.data.map((e) => e.postId));
      }
      postIdList.toSet().toList();
      await processAdapter?.postAdapter?.validModelValue(postIdList.join(','));
      await _postOnChanged(postIdList.map((e) => PickerDataModel(id: e)).toList());
    }
    update();
  }
  @override
  Future<void> Function(PickerDataModel model) get teamGroupOnChanged => _teamGroupOnChanged;

  @override
  Future<void> psnOnChanged(List<PickerDataModel> list, {bool isPostNeedChanged = true}) async{
    await super.psnOnChanged(list);
    if (processAdapter != null && isPostNeedChanged){
      ///选中当前生产人员的岗位（默认取前7个员工的数据）
      List<String> postIdList = [];
      List<PickerDataModel> personList = list.length > 7 ? list.sublist(0, 7) : list;
      for (var element in personList){
        var res = await PersonRepository().getPostList(element.id);
        if (!res.isSuccess){
          ToastNotification(Get.overlayContext!).error('获取员工岗位数据时出错：${res.message}，请重试！');
          return;
        }
        postIdList.addAll(res.data.map((e) => e.postId));
      }
      postIdList.toSet().toList();
      await processAdapter?.postAdapter?.validModelValue(postIdList.join(','));
      await _postOnChanged(postIdList.map((e) => PickerDataModel(id: e)).toList());
    }
    update();
  }

  ///岗位选择变化（该函数用于[processAdapter.postAdapter]）
  Future<void> _postOnChanged(List<PickerDataModel> list) async {
    postIdList.clear();
    postIdList.addAll(list.map((e) => e.id));
    ///过滤工序列表
    if (processAdapter != null){
      processAdapter!.dataList.clear();
      processAdapter!.noFilterDataList.forEach((element) {
        if (postIdList.isEmpty || postIdList.contains(element.postId)){
          processAdapter!.dataList.add(element);
        }
      });
      processAdapter!.visibleItems.clear();
      processAdapter!.visibleItems.addAll(processAdapter!.dataList);
      processAdapter!.totalRecords = processAdapter!.dataList.length;

      ///如果只能单次报一道工序，且过滤后只有一道工序，则默认选中，反之，清空选中的工序
      ///如果可以报多道工序，则过滤后，全部选中
      if (cannotOverThenTheLastOpSubmitQty || cannotOverThenTheLastOpS){
        if (processAdapter!.dataList.length == 1) {
          await processAdapter!.validViewValue(processAdapter!.dataList);
          _processOnChangedByAdapter(processAdapter!.dataList);
        }
        else {
          await processAdapter!.validViewValue([]);
          _processOnChangedByAdapter([]);
        }
      }
      else {
        await processAdapter!.validViewValue(processAdapter!.dataList);
        _processOnChangedByAdapter(processAdapter!.dataList);
      }
    }
    await getOpTGSubmitQty();

    update();
  }
  ///岗位选择变化（该函数用于[processAdapter.postAdapter]）
  Future<void> Function(List<PickerDataModel> model) get postOnChanged => _postOnChanged;

  ///工序选择变化（列表选择）
  Future<void> _processOnChanged(MoWorkBillEntryModel model) async{
    if (cannotOverThenTheLastOpSubmitQty || cannotOverThenTheLastOpS){
      ///单次只能报一道工序
      await processAdapter!.validModelValue(model.id);
      _processOnChangedByAdapter([model]);
    }
    else {
      List<MoWorkBillEntryModel> list = processAdapter!.dataList.where(
              (element) => element.isSelected || element.id == model.id).toList();
      if (model.isSelected){
        list.removeWhere((element) => element.id == model.id);
      }
      await processAdapter!.validViewValue(list);
      _processOnChangedByAdapter(list);
    }
    if (isShowOpDescription){
      opDescription = '[${model.opName ?? ''}]${model.opDescription ?? ' '}';
    }
    ///获取[opTGDailySubmitQty]、[opSubmitQty]
    await getOpTGSubmitQty();
    update();
  }
  ///工序选择变化（列表选择）
  Future<void> Function(MoWorkBillEntryModel model) get processOnChanged => _processOnChanged;

  ///工序选择变化（Adapter 选择）
  void _processOnChangedByAdapter(List<PickerDataModel> list) {
    submitModel.workBillEntryId = list.map((e) => e.id).join(',');
    submitModel.opId = list.map((e) => (e as MoWorkBillEntryModel).opId).join(',');
    submitModel.opName = list.map((e) => (e as MoWorkBillEntryModel).opName).join(',');
    submitModel.inspectFlag = list.isEmpty
        ? 0
        : (list[0] as MoWorkBillEntryModel).inspectOpFlag;
    submitModel.pieceRate = list.isEmpty
        ? null
        : (list[0] as MoWorkBillEntryModel).pieceRate;
    update();
  }
  ///工序选择变化（Adapter 选择）
  void Function(List<PickerDataModel> list) get processOnChangedByAdapter => _processOnChangedByAdapter;

  ///工序反选
  Future<void> _processReverseSelection() async {
    if (processAdapter != null){
      List<MoWorkBillEntryModel> unSelectedList = processAdapter!.dataList.where(
              (element) => !element.isSelected).toList();
      await processAdapter?.validViewValue(unSelectedList);
      _processOnChangedByAdapter(unSelectedList);
      update();
    }
  }
  ///工序反选
  Future<void> Function() get processReverseSelection => _processReverseSelection;

  ///“补打”按钮选择变化
  Future<void> _makeUpOnChanged() async{
    await super.makeUpOnChanged();
    await _getOpTGSubmitQty();
    update();
  }
  Future<void> Function() get makeUpOnChanged => _makeUpOnChanged;

  //endregion



  @override
  String? getDepIdByDepGetWayIndex(){
    switch (depGetWayIndex){
      case 0:
        return orderModel.depId;
      case 1:
        return BaseService.profile.departmentId;
      default:
        return '';
    }
  }
  @override
  String? getDepCodeByDepGetWayIndex() {
    switch (depGetWayIndex){
      case 0:
        return orderModel.depCode;
      case 1:
        return BaseService.profile.depCode;
      default:
        return '';
    }
  }



  ///获取报工汇总
  Future<void> _getOpTGSubmitQty() async {
    if (!isShowOpTgSubmitQty){ return; }
    ///获取 [opTGDailySubmitQty]、[opSubmitQty]
    opTGDailySubmitQty = null;
    opSubmitQty = null;
    dayQty = null;
    var dailyRes = await MoOpSubmitRepository().getReport(PageConfig(
        page: 1, rows: 999,
        queryData: {
          'OpId': submitModel.opId,
          'wcId': submitModel.wcId,
          'StartTime': '${DateUtil.getDateStrByDateTime(submitModel.billDate, format: DateFormat.YEAR_MONTH_DAY)}',
          'EndTime': '${DateUtil.getDateStrByDateTime(submitModel.billDate, format: DateFormat.YEAR_MONTH_DAY)}',
          'MoOrderId': submitModel.moOrderId,
        }
    ));
    if (!dailyRes.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取报工汇总数据时出错：${dailyRes.message}！');
    }
    else {
      dailyRes.data.forEach((element) {
        /// TaskDayQty：该工序当前班组当日报工数量：OpId、wcId[wcToken]、StartTime、EndTime、MoOrderId
        /// TaskSumQty：该工单累计报工数量：OpId、moOrderId 条件送入4个只用两个
        /// DayQty：当日累计报工数量：StartTime、EndTime 条件送入4个只用一个
        if ((submitModel.opId ?? '').isNotEmpty && (submitModel.wcId ?? '').isNotEmpty && element.name == 'TaskDayQty'){
          opTGDailySubmitQty = double.tryParse(element.value.toString());
        }
        else if ((submitModel.opId ?? '').isNotEmpty && element.name == 'TaskSumQty') {
          opSubmitQty = double.tryParse(element.value.toString());
        }
        else if (element.name == 'DayQty'){
          dayQty = double.tryParse(element.value.toString());
        }
      });
    }
  }
  ///获取报工汇总
  Future<void> Function() get getOpTGSubmitQty => _getOpTGSubmitQty;



  ///报工数据赋值（第一次进入报工页面时 OR 任务单改变时）
  ///
  /// [workCenterId]：加工中心-任务单报工时的加工中心数据
  ///
  /// [deviceId]、[deviceCode]、[deviceName]：设备对应生产任务单报工时的设备数据
  /// [opId]、[opName]、[workBillEntryId]、[inspectFlag]、[pieceRate]：设备对应生产任务单报工时的任务单工序数据
  Future<void> _setSubmitDataAndAdapter({
    required bool isInit,
    int? progId,
    String? workCenterId,
    String? deviceId,
    String? deviceCode,
    String? deviceName,
    String? opId,
    String? opName,
    String? workBillEntryId,
    int? inspectFlag,
    double? pieceRate,
  }) async {
    assert((isInit && progId != null) || (!isInit));
    submitModel.moOrderId = orderModel.moOrderId;
    submitModel.invId = orderModel.productId;
    submitModel.mouldId = orderModel.mouldId;
    submitModel.mtoNo = orderModel.mtoNo;
    submitModel.mtoSeq = orderModel.mtoSeq;
    submitModel.soCode = orderModel.soCode;
    submitModel.batch = orderModel.batch;
    submitModel.comUnitName = orderModel.comUnitName;
    submitModel.deviceId = deviceId;
    submitModel.deviceCode = deviceCode;
    submitModel.deviceName = deviceName;
    submitModel.opId = opId;
    submitModel.opName = opName;
    submitModel.workBillEntryId = workBillEntryId;
    submitModel.inspectFlag = inspectFlag;
    submitModel.pieceRate = pieceRate;
    if ((orderModel.packingQty ?? 0) > 0
        && double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') != orderModel.packingQty){
      NumPadUtil().setText(NumPadUtil.singleBoxQty, (orderModel.packingQty ?? 0).toStringAsFixed(0), numPadCTList);
      calcQty(NumPadUtil.singleBoxQty);
    }
    if (isInit){
      submitModel.progid = progId;
      submitModel.sign = MoOpSubmitSign.td.sign;
      submitModel.status = '';
      submitModel.enableMark = 1;
      submitModel.deleteMark = 0;
      billDate = DateTime.now();
      submitModel.billDate = DateTime.now();
      submitModel.depId = getDepIdByDepGetWayIndex();
      submitModel.depCode = getDepCodeByDepGetWayIndex();
      submitModel.serialNumber = orderModel.orderSN;
      if (wcDataReportType == 1){
        submitModel.wcId = workCenterId;
      }
      //region getAdapter
      ///获取员工选单数据源可能需要用到 lineCode，该值是通过产线数据源获取的
      switch (wcDataReportType){
        //region
        case 0: ///产线
          await getLineAdapter();
          break;
        case 1: ///加工中心
          await getWorkCenterAdapter();
          break;
        case 2: ///生产班组
          await getTeamGroupAdapter();
          break;
        //endregion
      }
      if (isDeviceHasAdapter){
        getEAMDeviceAdapter().then((value) {
          update();
        });
      }
      else {
        deviceModel = EAMDeviceModel();
      }
      if (isPsnHasAdapter){
        getPersonAdapter().then((value) {
          update();
        });
      }
      else {
        personList.clear();
      }
      getDepAdapter().then((value) {
        update();
      });
      getTeamAdapter().then((value) async {
        await getTeam();
        update();
      });
      _getProcessAdapter().then((value) {
        update();
      });
      getOrderSNAdapter().then((value) {
        update();
      });
      if (isUsePackingPicker){
        getContainerWithNoPageAdapter().then((value) async {
          await geDefaultContainer();
          update();
        });
      }
      //endregion
      getIsFirstInspectionPassed(preType: 'MoOrderId', preId: submitModel.moOrderId!).then((value) {
        update();
      });
      getOpTGSubmitQty().then((value) {
        update();
      });
      if ((submitModel.serialNumber ?? '').isNotEmpty){
        if (submitType != AppConfig.serialNumberSubmit
            && submitType != AppConfig.singleBoxSerialNumberSubmit){
          ChoiceChipModel? item = operationWayList.firstWhereOrNull(
                  (element) => element.keyName == AppConfig.serialNumberSubmit);
          if (item != null){
            submitTypeOnChanged(item);
          }
        }
      }
    }
    else {
      submitModel.opId = opId;
      submitModel.opName = opName;
      submitModel.workBillEntryId = workBillEntryId;
      submitModel.inspectFlag = inspectFlag;
      submitModel.pieceRate = pieceRate;
      submitModel.serialNumber = null;
      if ((submitModel.depId ?? '').isEmpty){
        submitModel.depId = getDepIdByDepGetWayIndex();
        submitModel.depCode = getDepCodeByDepGetWayIndex();
        await depAdapter?.validModelValue(submitModel.depId);
        await getTeamAdapter();
        await getTeam();
        if (psnGetWayIndex == 1 && isPsnHasAdapter){
          submitModel.empId = null;
          submitModel.emploee = null;
          await getPersonAdapter();
        }
      }
      await _getProcessAdapter();
      await _postOnChanged(postIdList.map((e) => PickerDataModel(id: e)).toList());
      await getOrderSNAdapter();
      if (isUsePackingPicker){
        NumPadUtil().setText(NumPadUtil.packingWeight, '', numPadCTList);
        calcQty(NumPadUtil.packingWeight);
        await getContainerWithNoPageAdapter();
        await geDefaultContainer();
      }
      await getIsFirstInspectionPassed(preType: 'MoOrderId', preId: submitModel.moOrderId!);
      await getOpTGSubmitQty();
    }
  }
  ///报工数据赋值（第一次进入报工页面时 OR 任务单改变时）
  Future<void> Function({
    required bool isInit,
    int? progId,
    String? workCenterId,
    String? deviceId,
    String? deviceCode,
    String? deviceName,
    String? opId,
    String? opName,
    String? workBillEntryId,
    int? inspectFlag,
    double? pieceRate,
  }) get setSubmitDataAndAdapter => _setSubmitDataAndAdapter;



  ///查看工序的技术指导书
  Future<void> _processItemAttach(MoRoutingEntryModel? routingEntryModel, String router) async{
    if (routingEntryModel == null || routingEntryModel.routingDId.isEmpty){
      ToastNotification(Get.overlayContext!).warn('无法获取工序图纸！');
      return;
    }
    Get.rootDelegate.toNamed(
      router,
      parameters: {
        'pageTitle': '工序图纸-${routingEntryModel.opName ?? ''}',
        'id': routingEntryModel.routingDId,
        'progId': '660011',
        'category': 'sop',
      }
    );
  }
  ///查看工序的技术指导书
  Future<void> Function(MoRoutingEntryModel? routingEntryModel, String route) get processItemAttach => _processItemAttach;



  ///报工提交前检查（生产任务单）
  /// [True]：通过； [False]：不通过
  ///
  /// [button]：提交按钮的权限名称，默认：btnadd
  ///
  /// [needCheckQty]：是否需要检查报工总数的填报情况（任务单报工，扫描序列号，自动提交报工记录时，不检查报工总数）
  ///
  /// [needCheckOp]：是否需要检查工序的填报情况（任务单报工，扫描序列号，自动提交报工记录时，如果是扫码后跳转到新的任务单，则不检查工序）
  ///
  /// [needCheckSN]：是否需要检查序列号的填报情况（任务单报工，扫描序列号，自动提交报工记录时，不检查序列号）
  Map<bool, String> _submitCheck({
    required bool isPrint,
    required String? invCCode,
    String button = 'btnadd',
    bool needCheckQty = true,
    bool needCheckOp = true,
    bool needCheckSN = true,
  }) {
    Map<bool, String> res = super.submitCheck(
      isPrint: isPrint,
      invCCode: invCCode,
      button: button,
      needCheckQty: needCheckQty,
      needCheckOp: needCheckOp,
      needCheckSN: needCheckSN,
    );
    if (res.containsKey(false)){
      return res;
    }
    if ((submitModel.moOrderId ?? '').isEmpty){
      return {false: '任务单数据错误！'};
    }
    if (cannotSubmitWhenNotInProduction
        && ((orderModel.sign ?? 0) < MoOpOrderSign.scz.sign || (orderModel.sign ?? 0) >= MoOpOrderSign.ysc.sign)){
      return {false: '该任务单未在生产中，不能报工！'};
    }

    return {true: ''};
  }
  @override
  Map<bool, String> Function({
    required bool isPrint,
    required String? invCCode,
    String button,
    bool needCheckQty,
    bool needCheckOp,
    bool needCheckSN,
  }) get submitCheck => _submitCheck;



  ///报工提交成功后，刷新报工填报区域的数据
  Future<void> _resetSubmitDataAfterSave({bool byAutoSubmit = false}) async {
    await super.resetSubmitDataAfterSave();
    if (/*!byAutoSubmit*/submitType != AppConfig.serialNumberSubmit
        && submitType != AppConfig.singleBoxSerialNumberSubmit){
      submitModel.workBillEntryId = null;
      submitModel.opId = null;
      submitModel.opName = null;
      submitModel.inspectFlag = null;
      submitModel.pieceRate = null;
      processAdapter?.clearSelection();
    }
    submitModel.serialNumber = null;
    orderSNAdapter?.clearSelection();
    serialNumberBarcodeMap.clear();
    await getOpTGSubmitQty();
  }
  Future<void> Function({bool byAutoSubmit}) get resetSubmitDataAfterSave => _resetSubmitDataAfterSave;



  //region Widget

  @override
  List<Widget> submitInfoWidget(BuildContext context, BoxConstraints constraints) {
    //region
    Widget opSubmitQtyWidget(BuildContext context, {required String title, required double? qty}){
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(51),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Expanded(
              child: FittedBox(
                child: Text(
                  '${qty == null ? '0' : NumFormatUtil.qtyFormatConverter((qty).toString())}',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: qty == null
                        ? Theme.of(context).colorScheme.outline
                        : AppColors.totalColor,
                  ), maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8,),
          ],
        ),
      );
    }
    Widget qty1Widget = opSubmitQtyWidget(
      context,
      title: '当日报工', ///选中工序 + 选中班组 + 当日 报工总数量（当日报工）
      qty: opTGDailySubmitQty,
    );
    Widget qty2Widget = opSubmitQtyWidget(
      context,
      title: '总报工数', ///选中工序 报工总数量（总报工数）
      qty: opSubmitQty,
    );
    Widget qty3Widget = opSubmitQtyWidget(
      context,
      title: '当日累计', ///当日总报工数量
      qty: dayQty,
    );
    //endregion
    return [
      if (isShowOpTgSubmitQty)
        Padding(
          padding: const EdgeInsets.only(
              bottom: 8
          ),
          child: constraints.maxWidth > 220 ?
          Row(
            children: [
              Expanded(child: qty1Widget,),
              const SizedBox(width: 4,),
              Expanded(child: qty2Widget,),
              const SizedBox(width: 4,),
              Expanded(child: qty3Widget,),
            ],
          ) :
          Column(
              children: [
                qty1Widget,
                const SizedBox(height: 4,),
                qty2Widget,
                const SizedBox(height: 4,),
                qty3Widget,
              ]
          ),
        ),
      if (isShowOpDescription)
        Container(
          alignment: Alignment.topLeft,
          child: Text(
            '工序说明：${opDescription}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
    ];
  }

  //region dataReportItem

  Widget processReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.processForm]!,
      customizeContent: PickerInputWidget(
        adapter: processAdapter,
        maxLines: 2,
        onTap: (List<PickerDataModel> selectList) {
          processOnChangedByAdapter(selectList);
        },
      ),
    );
  }

  //endregion

  Widget processViewWidget(BuildContext context, {
    required String processAttachRouter,
    required bool needRightArea,
  }) {
    if (needRightArea){
      needRightArea = isShowOpDescription || isShowOpTgSubmitQty;
    }
    return CardWidget(
      margin: EdgeInsets.zero,
      content: processAdapter == null ?
      SpinKitCircle(
        color: Colors.grey,
        size: 28,
      ) :
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        ///岗位筛选
                        PickerButtonWidget(
                          adapter: processAdapter?.postAdapter,
                          pickerChoiceType: PickerChoiceType.checkboxListTile,
                          pickerButtonType: PickerButtonType.text,
                          onTap: (List<PickerDataModel> selectList) async{
                            await postOnChanged(selectList);
                          },
                          buttonStyle: ButtonStyle(
                            padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                                horizontal: 4
                            )),
                            minimumSize: WidgetStateProperty.all(const Size(110, 54)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_note_outlined,
                                size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.3,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              Text(
                                '岗位筛选：${processAdapter?.postAdapter?.dataList.where(
                                        (element) => element.isSelected).map(
                                        (e) => e.code).join(',')}',
                                style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Expanded(child: SizedBox.shrink()),

                        ///“反选”按钮
                        if (!cannotOverThenTheLastOpSubmitQty && !cannotOverThenTheLastOpS)
                          FilledButton(
                            onPressed: () async{
                              await processReverseSelection();
                            },
                            style: ButtonStyle(
                                padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                                    horizontal: 4
                                )),
                                minimumSize: WidgetStateProperty.all(const Size(100, 54)),
                                backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context).colorScheme.secondary
                                )
                            ),
                            child: Text(
                              '工序反选',
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 42),
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: processAdapter == null ?
                        const SizedBox.shrink() :
                        Wrap(
                          runSpacing: 6, spacing: 6,
                          children: List.generate(processAdapter!.dataList.length, (index) {
                            MoWorkBillEntryModel item = processAdapter!.dataList[index];
                            MoRoutingEntryModel? routingEntryModel = processAdapter!.routingEntryList.firstWhereOrNull((element) => element.opId == item.opId);
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  processOnChanged(item);
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  width: 220, height: 80,
                                  padding: const EdgeInsets.all(4),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: item.isSelected
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : null,
                                    border: item.isSelected ? null : Border.all(
                                        color: Theme.of(context).colorScheme.outline,
                                        width: 1
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      MineIconButton(
                                        onPressed: () async{
                                          await processItemAttach(
                                            routingEntryModel,
                                            processAttachRouter,
                                          );
                                        },
                                        tooltip: '工序图纸',
                                        isNeedBadges: routingEntryModel != null && routingEntryModel.sop != null && routingEntryModel.sop != 0,
                                        badgesWidget: Text(
                                          (routingEntryModel?.sop ?? '').toString(),
                                          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                              color: Theme.of(context).colorScheme.surface
                                          ),
                                        ),
                                        icon: Icons.attach_file_outlined,
                                        iconSize: 22,
                                        iconColor: Theme.of(context).colorScheme.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
                                      ),
                                      const SizedBox(width: 4,),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '${(item.opName ?? '').isNotEmpty ? item.opName : ' '}',
                                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                    fontWeight: FontWeight.w600
                                                ),
                                                maxLines: 1, overflow: TextOverflow.ellipsis
                                              ),
                                            ),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '检 ${NumFormatUtil.qtyFormatConverter((item.acceptQty ?? 0).toStringAsFixed(0))}'
                                                    ' / '
                                                    '次 ${NumFormatUtil.qtyFormatConverter((item.disabledQty ?? 0).toStringAsFixed(0))}',
                                                style: Theme.of(context).textTheme.bodyLarge,
                                                maxLines: 1, overflow: TextOverflow.ellipsis
                                              ),
                                            ),
                                          ],
                                        )
                                      ),
                                    ],
                                  ),
                                )
                              )
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (needRightArea)
            Expanded(
              flex: 2,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return ScrollbarTheme(
                    data: ScrollbarThemeData(
                      interactive: false,
                      thumbVisibility: WidgetStateProperty.all(false),
                      trackVisibility: WidgetStateProperty.all(false),
                      thumbColor: WidgetStateProperty.all(Colors.transparent),
                      trackColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: submitInfoWidget(context, constraints),
                      ),
                    )
                  );
                }
              ),
            )
        ],
      ),
    );
  }

  //endregion

}