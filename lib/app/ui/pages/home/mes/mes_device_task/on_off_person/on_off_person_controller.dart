
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/service/serial_com_service/mixin/serial_port_getx_listener.dart';
import 'package:desktop/app/service/serial_com_service/serial_port_data_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///员工上下岗
class OnOffPersonController
    extends BaseFormController
    with SerialPortGetXListenerMixin<OnOffPersonController>, ScanInterface<OnOffPersonController> {

  final String deviceId;

  final FocusNode scanFN = FocusNode();
  final TextEditingController scanTC = TextEditingController();

  PersonAdapter? personAdapter;

  ///需要提交的员工信息
  final List<PersonModel> psnList = [];

  ///上下岗类型
  ///
  /// 0 上岗
  ///
  /// 1 下岗
  int? onOffType;

  ///获取最后一条员工上岗且未下岗的记录
  EAMHistoryModel? theLastPersonPostData;
  ///[theLastPersonPostData]该条记录是否是当天的
  bool isCurrentDate = false;

  OnOffPersonController({
    super.progId = 220017,
    required this.deviceId,
  });


  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    scanFN.addListener(scanFNOnListen);
  }

  @override
  Future<bool> initializeForm() async {
    ///获取最后一条员工上岗且未下岗的记录；
    ///如果有数据，且是当天的记录，默认选中该人员、下岗，且不可修改；
    ///反之，如果是前几天的上数据的话，只显示出来，不做其他处理；
    var res = await EAMHistoryRepository().getTheLastPersonPost(deviceId);
    if  (res.isSuccess && (res.data.id ?? '').isNotEmpty){
      theLastPersonPostData = res.data;
    }
    isCurrentDate = DateUtil.getDateStrByDateTime(
      theLastPersonPostData?.startDate,
      format: DateFormat.YEAR_MONTH_DAY,
    ) == DateUtil.getDateStrByDateTime(
      DateTime.now(),
      format: DateFormat.YEAR_MONTH_DAY,
    );
    onOffType = isCurrentDate ? 1 : null;
    await getPersonAdapter();
    if (isCurrentDate && (theLastPersonPostData?.sourceId ?? '').isNotEmpty){
      await personAdapter?.validModelValue(theLastPersonPostData!.sourceId);
      PersonModel? psnItem = personAdapter?.dataList.firstWhereOrNull(
              (element) => element.isSelected);
      if (psnItem != null){
        psnList.add(PersonModel.fromJson(psnItem.toJson()));
        personAdapter?.clearSelection();
      }
    }
    return true;
  }

  void scanFNOnListen() {
    if (scanFN.hasFocus) {
      PrintUtil.printDebug('扫码监听：得到焦点');
    }
    else{
      PrintUtil.printDebug('扫码监听：失去焦点，正在重新获取焦点');
      FocusScope.of(Get.context!).requestFocus(scanFN);
    }
  }

  ///扫码完成后提交（扫码内容的最后一个字符一定是回车符）
  Future<void> onSubmitted() async {
    await onBarcode(scanTC.text);
    scanTC.clear();
  }

  Future<void> getPersonAdapter() async {
    personAdapter = await AdapterHelper.getAsyncAdapter(
      'person',
      multipleSelection: false,
      queryData: {
        'Active': 0, ///Active:0不显示离职人员
      },
    ) as PersonAdapter;
  }


  ///personAdapter 选择时
  void psnOnChanged(List<PickerDataModel> list) {
    psnList.clear();
    psnList.addAll(list.map((e) => PersonModel.fromJson(e.toJson())));
    personAdapter?.clearSelection();
    update();
    return;
    list.forEach((element) {
      if (psnList.firstWhereOrNull((element1) => element.id == element1.id) == null){
        psnList.add(PersonModel.fromJson(element.toJson()));
      }
    });
    personAdapter?.clearSelection();
    update();
  }

  void psnListOnDeleted(String psnId) {
    psnList.removeWhere((element) => element.id == psnId);
    update();
  }

  void onOffTypeOnChanged(int value) {
    onOffType = value;
    update();
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
    if (!(theLastPersonPostData == null || !isCurrentDate)){
      isLoading = false;
      return;
    }
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
        if (psnList.firstWhereOrNull((element) => psnRes.data.id == element.id) != null){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        psnList.clear();
        psnList.add(psnRes.data);
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
        if (psnList.firstWhereOrNull((element) => psnRes.data.id == element.id) != null){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        psnList.clear();
        psnList.add(psnRes.data);
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
    if (actionName == DialogButtonActionEnum.confirm){
      if (isLoading) {
        ToastNotification(Get.overlayContext!).warn('正在执行！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      isLoading = true;

      //region 提交前检查
      if (psnList.isEmpty){
        ToastNotification(Get.overlayContext!).error('请选择员工！');
        isLoading = false;
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      if (onOffType == null){
        ToastNotification(Get.overlayContext!).error('请选择上岗或下岗！');
        isLoading = false;
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      //endregion

      ProgressDialogUtil.showProgressDialog(msg: '正在提交${onOffType == 0 ? '上' : '下'}岗数据', completedMsg: '${onOffType == 0 ? '上' : '下'}岗数据提交成功！');

      //region 赋值
      final EAMHistoryModel eamHistoryModel = EAMHistoryModel();
      eamHistoryModel.deviceId = deviceId;
      eamHistoryModel.category = 1024;
      eamHistoryModel.sourceProgid = 200009;
      eamHistoryModel.sourceId = psnList.map((e) => e.id).join(',');
      eamHistoryModel.processUser = psnList.map((e) => e.name).join(',');
      //progid=200009
      if (onOffType == 0){
        eamHistoryModel.startDate = DateTime.now();
      }
      else if (onOffType == 1) {
        eamHistoryModel.endDate = DateTime.now();
      }
      //endregion
      var res = await EAMHistoryRepository().personPost(onOffType!, eamHistoryModel);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('${onOffType == 0 ? '上' : '下'}岗数据提交时出错：${res.message}！');
        isLoading = false;
        ProgressDialogUtil.close();
        return DialogReturnDataModel(isCanCloseDialog: false);
      }

      isLoading = false;
      ProgressDialogUtil.update();
      await ProgressDialogUtil.awaitCompletionDelay();
      return DialogReturnDataModel(isCanCloseDialog: true, data:psnList[0].personID,);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

  @override
  void onClose() {
    super.onClose();
  }

}