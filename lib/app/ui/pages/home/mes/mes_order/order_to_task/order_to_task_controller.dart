import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/service/serial_com_service/mixin/serial_port_getx_listener.dart';
import 'package:desktop/app/service/serial_com_service/serial_port_data_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产任务单派工页面
class OrderToTaskController
    extends BaseFormController
    with SerialPortGetXListenerMixin<OrderToTaskController>, ScanInterface<OrderToTaskController>,
        InfoFormInterface {

  final List<InfoFormModel> orderInfoFormList = [
    InfoFormModel(keyName: 'BillCode', title: '任务单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'ProductName', title: '产品名称',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'ProductStd', title: '产品规格',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Qty', title: '任务数量',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'BillDate', title: '单据日期',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'SoCode', title: '销售单号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'OrderCode', title: '生产订单号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define22', title: '@单据体.自定义项1',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define23', title: '@单据体.自定义项2',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define24', title: '@单据体.自定义项3',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define25', title: '@单据体.自定义项4',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define26', title: '@单据体.自定义项5',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define27', title: '@单据体.自定义项6',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define28', title: '@单据体.自定义项7',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define29', title: '@单据体.自定义项8',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define30', title: '@单据体.自定义项9',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define31', title: '@单据体.自定义项10',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define32', title: '@单据体.自定义项11',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define33', title: '@单据体.自定义项12',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define34', title: '@单据体.自定义项13',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define35', title: '@单据体.自定义项14',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define36', title: '@单据体.自定义项15',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define37', title: '@单据体.自定义项16',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 0, isShow: true),
  ];

  ///上一个页面选中的任务单
  final MoOpOrderModel orderModel;

  final MoTaskModel taskModel = MoTaskModel();
  DepartmentAdapter? depAdapter;
  EAMDeviceAdapter? deviceAdapter;
  PersonAdapter? personAdapter;
  ProcessAdapter? processAdapter;

  ///派工日期是否手动修改过了（提交时，如果修改过了的话，就取修改的值；反之，再次赋值当前时间）
  bool isTaskDateOnChanged = false;

  final List<NumPadController> numPadCTList = [
    NumPadController(key: NumPadUtil.qty), ///派工总数量
  ];

  ///当前工序未派工数量
  double unAssignQty = 0;

  final FocusNode scanFN = FocusNode();
  final TextEditingController scanTC = TextEditingController();


  OrderToTaskController({
    super.progId = 650011,
    required this.orderModel,
  });


  @override
  Future<void> onReady() async {
    super.onReady();
  }

  @override
  Future<bool> initializeForm() async {
    taskModel.progid = progId;
    taskModel.sign = 0;
    taskModel.enableMark = 1;
    taskModel.deleteMark = 0;
    taskModel.nprint = 0;
    taskModel.attach = 0;
    taskModel.mtoNo = orderModel.mtoNo;
    taskModel.mtoSeq = orderModel.mtoSeq;
    taskModel.soCode = orderModel.soCode;
    taskModel.taskDate = DateTime.now();
    taskModel.opDescription = orderModel.description;
    taskModel.moOrderId = orderModel.moOrderId;
    taskModel.orderCode = orderModel.billCode;
    taskModel.billType = orderModel.billType;
    taskModel.property = orderModel.property;
    taskModel.priority = orderModel.priority;
    taskModel.invId = orderModel.productId;
    taskModel.batch = orderModel.batch;
    taskModel.depId = orderModel.depId;
    taskModel.deviceId = orderModel.deviceId;
    taskModel.wcId = orderModel.wcId;

    getDepAdapter().then((value) {
      update();
    });
    getEAMDeviceAdapter().then((value) {
      update();
    });
    getPersonAdapter().then((value) {
      update();
    });
    getProcessAdapter().then((value) {
      update();
    });
    return true;
  }


  //region get Adapter

  ///获取车间Adapter
  Future<void> getDepAdapter() async{
    depAdapter = await AdapterHelper.getAsyncAdapter(
        'dep',
        selectedItems: [PickerDataModel(id: taskModel.depId)]
    ) as DepartmentAdapter;
  }

  ///获取设备Adapter
  Future<void> getEAMDeviceAdapter() async{
    deviceAdapter = await AdapterHelper.getAsyncAdapter(
        'device',
        selectedItems: [PickerDataModel(id: taskModel.deviceId),],
    ) as EAMDeviceAdapter;
  }

  ///获取人员Adapter
  Future<void> getPersonAdapter() async{
    personAdapter = await AdapterHelper.getAsyncAdapter(
      'person',
      multipleSelection: false,
      isNeedLoadData: true,
      queryData: {
        'Active': 0, ///Active:0不显示离职人员
      },
      selectedItems: (taskModel.emploeeId ?? '').isEmpty
          ? []
          : taskModel.emploeeId!.split(',').map((e) => PickerDataModel(id: e)).toList(),
    ) as PersonAdapter;
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

  //endregion


  //region on Changed

  ///报工车间选择变化 （车间改变后班次Adapter重新读取）
  void depOnChanged(PickerDataModel model) {
    if (taskModel.depId == model.id) { return; }
    taskModel.depId = model.id;
    taskModel.depCode = model.code;
    update();
  }

  ///生产设备选择变化
  void deviceOnChanged(PickerDataModel model) {
    if (taskModel.deviceId == model.id){ return; }
    taskModel.deviceId = model.id;
    taskModel.deviceCode = model.code;
    taskModel.deviceName = model.name;
    update();
  }

  ///人员选择变化
  void psnOnChanged(PickerDataModel model) {
    taskModel.emploeeId = model.id;
    update();
  }

  ///工序选择变化（Adapter 选择）
  void processOnChangedByAdapter(PickerDataModel model) {
    model as MoWorkBillEntryModel;
    taskModel.moOpId = model.wbMxId;
    taskModel.opId = model.opId;
    taskModel.opCode = model.opCode;
    taskModel.opName = model.opName;
    taskModel.opWorkDescription = model.opDescription;
    taskModel.sequ = model.sequ;
    taskModel.pieceRate = model.pieceRate;
    taskModel.inspectFlag = model.inspectOpFlag;
    taskModel.reportFlag = model.reportFlag;
    taskModel.acceptOpFlag = model.acceptOpFlag;
    taskModel.shiftOpFlag = model.shiftOpFlag;

    unAssignQty = (model.unAssignQty ?? 0) <= 0 ? 0 : model.unAssignQty!;
    NumPadUtil().setText(NumPadUtil.qty, unAssignQty.toString(), numPadCTList);

    update();
  }

  ///工序选择变化（列表选择）
  Future<void> processOnChanged(MoWorkBillEntryModel model) async {
    await processAdapter?.validViewValue([model]);
    processOnChangedByAdapter(model);
    update();
  }

  void taskDateOnChanged(DateTime? date) {
    if (date == null){ return; }
    isTaskDateOnChanged = true;
    taskModel.taskDate = date;
    update();
  }

  //endregion


  ///扫码完成后提交（扫码内容的最后一个字符一定是回车符）
  Future<void> onSubmitted() async {
    await onBarcode(scanTC.text);
    scanTC.clear();
  }


  //region 串口、扫码

  @override
  Future<void> onSerialPortData(SerialPortDataModel serialPortDataModel) async {
    for (var element in weightMsgConnectService.connectList){
      if (element.com == serialPortDataModel.com){
        portMsgOnData(
          element.key,
          data: serialPortDataModel.data,
          accuracy: element.accuracy,
        );
      }
    }
  }

  void portMsgOnData(String key, {
    required dynamic data,
    bool isWeightMsgReverseOrder = false,
    double accuracy = 0,
  }){
    switch (key){
      case WeightMsgConnectService.scanGun:
      case WeightMsgConnectService.cardReader:
        onBarcode(data);
        break;
    }
  }

  @override
  Future<void> onBarcode(String searchString) async {
    if (kDebugMode){
      //searchString = '|F|610001|2426495a-9129-41e2-86fd-b8b73aadc906';
      //searchString = '|T|610001|6f5b58f2-be9d-4ef4-91cc-1ccb00c7355b';
      //searchString = '|G|AS001_0115';
      //searchString = '|X|24050506';
    }
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (searchString.isEmpty){
      ToastNotification(Get.overlayContext!).warn('条码为空！');
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(msg: '正在返回扫描结果');

    searchString = getBarCodePrefix(searchString, objectItem.attributeList);
    List<String> list = searchString.split('|');
    if (list.length < 3){
      TipsUtils.showTip(
        msg: '条码错误，请检查设置的默认条码格式！',
        toastType: ToastType.warn,
      );
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    switch (list[1]){
      case 'G':
        //region 员工条码
        String psnNum = list[2];
        var psnRes = await PersonRepository().getFormData('', '', {'PsnNum': psnNum}, 0);
        if (!psnRes.isSuccess){
          TipsUtils.showTip(
            msg: '获取员工数据时出错：${psnRes.message}！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (psnRes.data.id.isEmpty){
          TipsUtils.showTip(
            msg: '查询不到该员工！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if ((taskModel.emploeeId ?? '').split(',').contains(psnRes.data.id)){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        await personAdapter?.validViewValue([psnRes.data]);
        psnOnChanged(psnRes.data);
        //endregion
        break;
      case 'IP':
        //region 员工卡号
        String psnNum = list[2];
        var psnRes = await PersonRepository().getFormData('', '', {'IdCode': psnNum}, 0);
        if (!psnRes.isSuccess){
          TipsUtils.showTip(
            msg: '获取员工数据时出错：${psnRes.message}！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (psnRes.data.id.isEmpty){
          TipsUtils.showTip(
            msg: '查询不到该员工！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if ((taskModel.emploeeId ?? '').split(',').contains(psnRes.data.id)){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        await personAdapter?.validViewValue([psnRes.data]);
        psnOnChanged(psnRes.data);
        //endregion
        break;
      case 'E':
        //region 设备条码
        String deviceInfo = list[2]; ///该值可能是 code，也可能是 id
        if (taskModel.deviceId == deviceInfo || taskModel.deviceCode == deviceInfo){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        EAMDeviceModel eamDeviceModel = EAMDeviceModel();
        var deviceCodeRes = await EAMDeviceRepository().getList({'DeviceCode': deviceInfo});
        if (!deviceCodeRes.isSuccess){
          TipsUtils.showTip(
            msg: '获取设备数据时出错：${deviceCodeRes.message}！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (deviceCodeRes.data.isEmpty){
          var deviceIdRes = await EAMDeviceRepository().getModel(deviceInfo);
          if (!deviceIdRes.isSuccess){
            TipsUtils.showTip(
              msg: '获取设备数据时出错：${deviceIdRes.message}！',
              toastType: ToastType.warn,
            );
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
          if (deviceIdRes.data.id.isEmpty){
            TipsUtils.showTip(
              msg: '查询不到该设备！',
              toastType: ToastType.warn,
            );
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
          eamDeviceModel = deviceIdRes.data;
        }
        else {
          eamDeviceModel = deviceCodeRes.data[0];
        }
        await deviceAdapter?.validViewValue([eamDeviceModel]);
        deviceOnChanged(eamDeviceModel);
        //endregion
        break;
      default:
        TipsUtils.showTip(
          msg: '条码错误！',
          toastType: ToastType.warn,
        );
        isLoading = false;
        ProgressDialogUtil.close();
        return;
    }

    isLoading = false;
    update();
    ProgressDialogUtil.update(value: 1);
  }

  //endregion


  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){ ///上岗
      if (isLoading) {
        ToastNotification(Get.overlayContext!).warn('正在执行！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      isLoading = true;

      //region 提交前检查
      String qtyString = NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '';
      double? qty = double.tryParse(qtyString);
      if (qty == null || qty <= 0){
        ToastNotification(Get.overlayContext!).error('报工总数量输入有误，请重输！');
        isLoading = false;
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      if ((taskModel.moOpId ?? '').isEmpty){
        ToastNotification(Get.overlayContext!).error('请选择需要派工的工序！');
        isLoading = false;
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      //endregion

      ProgressDialogUtil.showProgressDialog(
          msg: '正在提交派工数据', completedMsg: '派工数据提交成功！'
      );

      //region 赋值
      taskModel.assignQty = qty;
      if (!isTaskDateOnChanged){
        taskModel.taskDate = DateTime.now();
      }
      taskModel.createDate = DateTime.now();
      //endregion
      var res = await MoTaskRepository().saveVoucher('', taskModel);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('派工数据提交时出错：${res.message}！');
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



  }