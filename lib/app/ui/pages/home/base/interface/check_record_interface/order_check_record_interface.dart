import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/check_record_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/mes_check_record_interface.dart';
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


///任务单的次品录入接口（一定是生产单据） 811010
mixin OrderCheckRecordInterface
on CheckRecordInterface, MesCheckRecordInterface {

  ///要报次品的任务单数据（初始值：上一个页面选中的任务单）
  MoOpOrderModel orderModel = MoOpOrderModel();

  ///报修工序
  ProcessAdapter? processAdapter;
  MoOrderSNAdapter? orderSNAdapter;

  ///选中的岗位列表（用于筛选工序，可以通过班组、员工来改变该值）
  final List<String> postIdList = [];

  ///是否显示工序说明行
  bool isShowOpDescription = AppConfig.isShowOpDescription;
  ///工序说明查看
  String opDescription = '';

  //region 生产序列号扫码信息
  ///通过扫码得到的产品序列号列表；
  ///key：产品序列号；
  ///
  ///value：是否成功写入到报工数据中
  ///
  ///200：成功；
  ///
  ///1：未通过检查，失败；
  ///
  ///2：获取服务器数据时出错，失败；
  ///
  ///3：查询不到该序列号，失败；
  ///
  ///4：该序列号未被分配到该任务单，失败；
  ///
  ///5：该序列号对应的工序已报工，失败；
  ///
  ///6： 不允许超上道报工，失败；
  ///
  ///7： 该序列号已失效（报废），失败；
  final Map<String, int> serialNumberBarcodeMap = {};
  String get serialNumberBarcodeMsg {
    List<String> successList = [];
    List<String> failList = [];
    serialNumberBarcodeMap.forEach((key, value) {
      if (value == 200){
        successList.add(key);
      }
      else {
        failList.add(key);
      }
    });
    return '已扫${serialNumberBarcodeMap.length}条序列号条码，成功${successList.length}条，失败${failList.length}条！';
  }
  String get serialNumberBarcodeDetailMsg {
    List<String> successList = [];
    List<String> fail1List = [];
    List<String> fail2List = [];
    List<String> fail3List = [];
    List<String> fail4List = [];
    List<String> fail5List = [];
    List<String> fail6List = [];
    List<String> fail7List = [];
    serialNumberBarcodeMap.forEach((key, value) {
      switch (value){
        case 200:
          successList.add(key);
          break;
        case 1:
          fail1List.add(key);
          break;
        case 2:
          fail2List.add(key);
          break;
        case 3:
          fail3List.add(key);
          break;
        case 4:
          fail4List.add(key);
          break;
        case 5:
          fail5List.add(key);
          break;
        case 6:
          fail6List.add(key);
          break;
        case 7:
          fail7List.add(key);
          break;
      }
    });
    int failListLength = fail1List.length + fail2List.length + fail3List.length
        + fail4List.length + fail5List.length + fail6List.length + fail7List.length;
    return '已扫${serialNumberBarcodeMap.length}条序列号条码，'
        '成功${successList.length}条，失败$failListLength条！'
        '${failListLength == 0 ? '' : '\n失败的条码如下：\n'}'
        '${fail1List.isEmpty ? '' : '未通过检查：${fail1List.join(',')}\n'}'
        '${fail2List.isEmpty ? '' : '从服务器中获取数据时出错：${fail2List.join(',')}\n'}'
        '${fail3List.isEmpty ? '' : '查询不到该序列号：${fail3List.join(',')}\n'}'
        '${fail4List.isEmpty ? '' : '未被分配任务单：${fail4List.join(',')}\n'}'
        '${fail5List.isEmpty ? '' : '对应的工序已报工的序列号：${fail5List.join(',')}\n'}'
        '${fail6List.isEmpty ? '' : '不允许超上道报工：${fail6List.join(',')}\n'}'
        '${fail7List.isEmpty ? '' : '该序列号已失效（报废）：${fail7List.join(',')}\n'}';
  }
  //endregion

  @override
  List<ChoiceChipModel> get operationWayList => List.unmodifiable(AppConfig.mesOrderCROperationWayList);

  @override
  final Map<String, int?> formJudgeTypeMap = {
    'DepId': 4,
    'TeamId': 4,
    'wcId': null,
    'DeviceId': null,
    'EmpId': 4,
    'OpId': 4,
    'ComDefects': 4,
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
      multipleSelection: false, ///次品录入只能单道工序
    ) as ProcessAdapter;
  }
  ///获取工序Adapter
  Future<void> Function() get getProcessAdapter => _getProcessAdapter;

  ///获取产品序列号Adapter
  Future<void> _getOrderSNAdapter() async {
    orderSNAdapter = await AdapterHelper.getAsyncAdapter(
      'orderSN',
      queryData: {
        'MoOrderId': checkRecordModel.moOrderId,
      },
      isNeedLoadData: true,
      multipleSelection: true,
      selectedItems: (checkRecordModel.serialNumber ?? '').isEmpty
          ? []
          : checkRecordModel.serialNumber!.split(',').map(
              (e) => PickerDataModel(id: e)).toList(),
    ) as MoOrderSNAdapter;
    if ((checkRecordModel.serialNumber ?? '').isNotEmpty){
      NumPadUtil().setText(NumPadUtil.qty, checkRecordModel.serialNumber!.split(',').length.toString(), numPadCTList);
    }
  }
  ///获取产品序列号Adapter
  Future<void> Function() get getOrderSNAdapter => _getOrderSNAdapter;

  //endregion



  //region OnChanged

  ///生产班组选择变化
  Future<void> _teamGroupOnChanged(PickerDataModel model) async {
    MoBeltLineModel item = MoBeltLineModel.fromJson(model.toJson());
    if (checkRecordModel.wcId == item.id){ return; }
    await super.teamGroupOnChanged(item);
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
    if (processAdapter != null && isPostNeedChanged) {
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

      ///如果过滤后只有一道工序，则默认选中，反之，清空选中的工序
      if (processAdapter!.dataList.length == 1) {
        await processAdapter!.validViewValue(processAdapter!.dataList);
        _processOnChangedByAdapter(processAdapter!.dataList[0]);
      }
      else {
        await processAdapter!.validViewValue([]);
        _processOnChangedByAdapter(MoWorkBillEntryModel());
      }
    }

    update();
  }
  ///岗位选择变化（该函数用于[processAdapter.postAdapter]）
  Future<void> Function(List<PickerDataModel> model) get postOnChanged => _postOnChanged;

  ///工序选择变化（列表选择）（次品录入的工序只能进行单个选择）
  Future<void> _processOnChanged(MoWorkBillEntryModel model) async{
    if (checkRecordModel.workBillEntryId == model.id){ return; }
    await processAdapter!.validModelValue(model.id);
    _processOnChangedByAdapter(model);
    if (isShowOpDescription){
      opDescription = '[${model.opName ?? ''}]${model.opDescription ?? ' '}';
    }
    update();
  }
  ///工序选择变化（列表选择）（次品录入的工序只能进行单个选择）
  Future<void> Function(MoWorkBillEntryModel model) get processOnChanged => _processOnChanged;

  ///工序选择变化（Adapter 选择）
  void _processOnChangedByAdapter(PickerDataModel model) {
  MoWorkBillEntryModel item = MoWorkBillEntryModel.fromJson(model.toJson());
  checkRecordModel.opId = item.opId;
  checkRecordModel.opName = item.opName;
  checkRecordModel.workBillEntryId = item.id;
  update();
  }
  ///工序选择变化（Adapter 选择）
  void Function(PickerDataModel model) get processOnChangedByAdapter => _processOnChangedByAdapter;

  ///产品序列号选择变化
  void _orderSNOnChanged(List<PickerDataModel> list) {
    checkRecordModel.serialNumber = list.map((e) => e.id).join(',');
    NumPadUtil().setText(NumPadUtil.qty, list.length.toString(), numPadCTList);
    update();
  }
  ///产品序列号选择变化
  void Function(List<PickerDataModel> list) get orderSNOnChanged => _orderSNOnChanged;

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



  ///次品数据赋值（第一次进入报次品页面时 OR 任务单改变时）
  Future<void> _setCheckRecordDataAndAdapter({
    required bool isInit,
    int? progId,
    String? workCenterId,
    String? deviceId,
    String? deviceCode,
    String? deviceName,
    String? opId,
    String? opName,
    String? workBillEntryId,
  }) async {
    assert((isInit && progId != null) || (!isInit));
    checkRecordModel.moOrderId = orderModel.moOrderId;
    checkRecordModel.invId = orderModel.productId;
    checkRecordModel.mouldId = orderModel.mouldId;
    checkRecordModel.mtoNo = orderModel.mtoNo;
    checkRecordModel.mtoSeq = orderModel.mtoSeq;
    checkRecordModel.soCode = orderModel.soCode;
    checkRecordModel.batch = orderModel.batch;
    checkRecordModel.comUnitName = orderModel.comUnitName;
    checkRecordModel.deviceId = deviceId;
    checkRecordModel.deviceCode = deviceCode;
    checkRecordModel.deviceName = deviceName;
    checkRecordModel.opId = opId;
    checkRecordModel.opName = opName;
    checkRecordModel.workBillEntryId = workBillEntryId;
    if (isInit){
      checkRecordModel.progID = progId!;
      checkRecordModel.sign = 0;
      checkRecordModel.status = '';
      checkRecordModel.serviceSign = 1;
      productDate = DateTime.now();
      checkRecordModel.productDate = DateTime.now();
      checkRecordModel.depId = getDepIdByDepGetWayIndex();
      checkRecordModel.depCode = getDepCodeByDepGetWayIndex();
      checkRecordModel.serialNumber = orderModel.orderSN;
      if (wcDataReportType == 1){
        checkRecordModel.wcId = workCenterId;
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
      getREProcessAdapter(wbId: orderModel.wbId, invId: orderModel.productId).then((value) {
        update();
      });
      _getOrderSNAdapter().then((value) {
        update();
      });
      getComDefectAdapter(invCCode: orderModel.invCCode).then((value) {
        update();
      });
      //endregion
      if ((checkRecordModel.serialNumber ?? '').isNotEmpty){
        ChoiceChipModel? item = operationWayList.firstWhereOrNull(
                (element) => element.keyName == AppConfig.serialNumberCheckRecord);
        if (item != null){
          checkRecordTypeOnChanged(item);
        }
      }
    }
    else {
      checkRecordModel.opId = opId;
      checkRecordModel.opName = opName;
      checkRecordModel.workBillEntryId = workBillEntryId;
      checkRecordModel.serialNumber = null;
      if ((checkRecordModel.depId ?? '').isEmpty) {
        checkRecordModel.depId = getDepIdByDepGetWayIndex();
        checkRecordModel.depCode = getDepCodeByDepGetWayIndex();
        await depAdapter?.validModelValue(checkRecordModel.depId);
        await getTeamAdapter();
        await getTeam();
        if (psnGetWayIndex == 1 && isPsnHasAdapter){
          checkRecordModel.empId = null;
          checkRecordModel.emploee = null;
          await getPersonAdapter();
        }
      }
      await _getProcessAdapter();
      await getREProcessAdapter(wbId: orderModel.wbId, invId: orderModel.productId);
      await _postOnChanged(postIdList.map((e) => PickerDataModel(id: e)).toList());
      await _getOrderSNAdapter();
      if (comDefectAdapter == null
          || !comDefectAdapter!.itemCode.contains('.${orderModel.invCCode}')){
        checkRecordModel.comDefects = null;
        await getComDefectAdapter(invCCode: orderModel.invCCode);
      }
    }
  }
  ///次品数据赋值（第一次进入报次品页面时 OR 任务单改变时）
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
  }) get setCheckRecordDataAndAdapter => _setCheckRecordDataAndAdapter;



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



  ///次品记录提交前检查（生产任务单）
  /// [True]：通过； [False]：不通过
  ///
  /// [button]：提交按钮的权限名称，默认：btnadd
  Map<bool, String> _checkRecordCheck({
    required bool isPrint,
    required String? invCCode,
    String button = 'btnadd',
  }){
    Map<bool, String> res = super.checkRecordCheck(
      isPrint: isPrint,
      invCCode: invCCode,
      button: button,
    );
    if (res.containsKey(false)){
      return res;
    }
    if ((checkRecordModel.moOrderId ?? '').isEmpty){
      return {false: '任务单数据错误！'};
    }
    return {true: ''};
  }
  Map<bool, String> Function({
    required bool isPrint,
    required String? invCCode,
    String button,
  }) get checkRecordCheck => _checkRecordCheck;



  ///次品记录提交成功后，刷新数据填报区域的数据
  Future<void> _resetCheckRecordDataAfterSave() async {
    await super.resetCheckRecordDataAfterSave();
    checkRecordModel.workBillEntryId = null;
    checkRecordModel.opId = null;
    checkRecordModel.opName = null;
    checkRecordModel.reWorkBillEntryId = null;
    reProcessAdapter?.clearSelection();
    checkRecordModel.serialNumber = null;
    orderSNAdapter?.clearSelection();
    serialNumberBarcodeMap.clear();
  }
  Future<void> Function() get resetCheckRecordDataAfterSave => _resetCheckRecordDataAfterSave;



  //region Widget

  ///序列号扫码历史提示信息
  Widget serialNumberBarcodeMsgWidget(BuildContext context){
    return Tooltip(
      message: serialNumberBarcodeDetailMsg,
      child: Text(
          serialNumberBarcodeMsg,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.errorColor,
          ), maxLines: 1, overflow: TextOverflow.ellipsis
      ),
    );
  }

  @override
  List<Widget> checkRecordInfoWidget(BuildContext context, BoxConstraints constraints) {
    return [
      ...super.checkRecordInfoWidget(context, constraints),
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
          if (selectList.isNotEmpty){
            processOnChangedByAdapter(selectList[0]);
          }
          else {
            processOnChangedByAdapter(MoWorkBillEntryModel());
          }
        },
      ),
    );
  }

  Widget orderSNReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.orderSNForm]!,
      customizeContent: PickerInputWidget(
        adapter: orderSNAdapter,
        maxLines: 2,
        pickerChoiceType: PickerChoiceType.checkboxListTile,
        customContent: (PickerDataModel item) {
          item as MoOrderSNModel;
          return '${item.code}';
        },
        onTap: (List<PickerDataModel> selectList) {
          orderSNOnChanged(selectList);
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
      needRightArea = isShowOpDescription;
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
                            MoRoutingEntryModel? routingEntryModel = processAdapter?.routingEntryList.firstWhereOrNull((element) => element.opId == item.opId);
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
                            children: checkRecordInfoWidget(context, constraints),
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