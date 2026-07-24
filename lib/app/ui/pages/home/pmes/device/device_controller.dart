import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/web_socket_model.dart';
import 'package:desktop/app/service/tts_service.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/web_socket_stream_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:printing/printing.dart';


///设备监控
class DeviceController
    extends BaseFormController
    with WebSocketStreamInterface {

  ///设备Item 高度固定 173 347 2
  final double itemHeight = 160;
  double itemWidth = 0;
  double itemAspectRatio = 2;

  ///读取sop技术指导书的对象，默认：700216，模具与产品关系sop
  late final int sopProgId = int.parse(dataService.accInformationMap['realtime.sop']?.itemValue ?? '700216');

  ///设备实时监控列表-原始数组
  final List<ModelWithGetxController<MoDeviceTaskModel>> deviceTaskList = [];
  ///设备实时监控列表-过滤后的数组
  final List<ModelWithGetxController<MoDeviceTaskModel>> deviceTaskFilterList = [];
  final ScrollController deviceTaskController = ScrollController();

  //region 搜索
  ///设备编号搜索框按制器
  final TextEditingController searchTC = TextEditingController();
  final FocusNode searchFN = FocusNode();
  ///搜索时启用时间防抖，超过一定时间不输入才正式搜索数据
  final Debounce _debounce = Debounce(Duration(milliseconds: 1500));
  bool isSearchWidgetOpen = false;
  //endregion

  ///是否超产闪烁
  bool isBlink = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_IS_BLINK_KEY) ?? AppConfig.isBlink;
  ///超产闪烁的频率
  int rate = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_BLINK_RATE_KEY) ?? AppConfig.rate;

  ///单个设备卡片显示的设备信息 0 设备编号； 1 设备简称； 2设备名称
  int deviceShowInfoType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_DEVICE_SHOW_INFO_TYPE_KEY) ?? AppConfig.deviceShowInfoType;


  //region deviceSignList 设备状态列表
  ///不显示的机器状态列表
  final List<int> unVisibleDeviceSignList = [];
  late final List<ModelWithGetxController<ChoiceChipModel>> deviceSignList = [
    ///全部 -1
    ModelWithGetxController<ChoiceChipModel>(model: ChoiceChipModel(
        sign: -1, keyName: 'all',
        title: '全部', isSelected: true,
        activeColor: AppColors.totalColor,
        icon: Icons.computer
    )),
    ///运行 1
    ModelWithGetxController<ChoiceChipModel>(model: ChoiceChipModel(
        sign: 1, keyName: 'run',
        title: '运行', isSelected: !unVisibleDeviceSignList.contains(1),
        activeColor: AppColors.runColor,
        icon: Icons.online_prediction
    )),
    ///待机 2
    ModelWithGetxController<ChoiceChipModel>(model: ChoiceChipModel(
        sign: 2, keyName: 'standby',
        title: '待机', isSelected: !unVisibleDeviceSignList.contains(2),
        activeColor: AppColors.standByColor,
        icon: Icons.access_time_outlined
    )),
    ///停机 4
    ModelWithGetxController<ChoiceChipModel>(model: ChoiceChipModel(
        sign: 4, keyName: 'stop',
        title: '停机', isSelected: !unVisibleDeviceSignList.contains(4),
        activeColor: AppColors.stopColor,
        icon: Icons.warning
    )),
    ///未连接 8
    ModelWithGetxController<ChoiceChipModel>(model: ChoiceChipModel(
        sign: 8, keyName: 'notConnected',
        title: '未连接', isSelected: !unVisibleDeviceSignList.contains(8),
        activeColor: AppColors.notConnectedColor,
        icon: Icons.wifi_off
    )),
  ];
  //endregion

  //region 语音播报
  final flutterTtsService = Get.find<TtsService>();
  ///是否可以进行语音播报（语音播报(超产、异常报告、全场呼叫)是否打开 + 语音包引擎是否选择）
  bool canTtsSpeech = false;
  ///是否正在进行新增的语音播报
  bool isSpeechNewData = false;
  bool ttsRunning = false;
  ///超产 是否语音播报
  bool isOpenOverProductFlutterTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_IS_OPEN_OVER_PRODUCT_FLUTTER_TTS) ?? AppConfig.isOpenFlutterTts;
  ///异常报告 是否语音播报
  bool isOpenExceptionReportTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_IS_OPEN_EXCEPTION_REPORT_FLUTTER_TTS) ?? AppConfig.isOpenFlutterTts;
  ///全场呼叫 是否打开语音播报
  bool isOpenAndonTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_IS_OPEN_ANDON_FLUTTER_TTS) ?? AppConfig.isOpenFlutterTts;
  ///超产预警 播报提前时间（秒）
  int leadTimeOverProductWarnFlutterTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_LEAD_TIME_OVER_PRODUCT_WARN_FLUTTER_TTS) ?? AppConfig.leadTimeOverProductWarnFlutterTts;
  ///两次循环之间的间隔时间（秒）
  int timeBetweenCycleFlutterTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_TIME_BETWEEN_CYCLES_FLUTTER_TTS) ?? AppConfig.timeBetweenCyclesFlutterTts;
  ///每次循环的播报次数
  int numOfEachCycleFlutterTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_NUM_OF_EACH_CYCLE_FLUTTER_TTS) ?? AppConfig.numOfEachCycleFlutterTts;
  //endregion

  //region 异常报告、全场呼叫列表（语音播报用）
  ///模具维修列表
  List<MouldServiceModel> mEList = [];
  ///次品列表
  List<MoCheckRecordModel> cRList = [];
  ///设备维修列表
  List<EAMServiceModel> dSList = [];
  ///全场呼叫列表
  List<MoAndonServiceModel> mAList = [];
  //endregion

  //region 定时刷新
  ///是否可以定时刷新
  bool isCanTimedRefresh = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_IS_CAN_TIMED_REFRESH_KEY) ?? AppConfig.isCanTimedRefresh;
  ///刷新 数据刷新频率（时间 秒）
  late int secondOfRefresh = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_SCROLL_REFRESH_TIME_KEY) ?? AppConfig.secondOfRefresh;
  bool isDataRefresh = false;
  bool refreshRunning = false;
  //endregion


  DeviceController({
    super.progId = 670001,
  });


  @override
  void onInit() async {
    super.onInit();
    List<dynamic> list = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_UN_VISIBLE_DEVICE_SIGN_LIST_KEY) ?? [];
    unVisibleDeviceSignList.addAll(list.map((e) => int.tryParse(e.toString()) ?? -1).toList());

    deviceSignList.forEach((element) {
      Get.create<ModelWithGetxController<ChoiceChipModel>>(() => element, tag: 'PMesDevice-${element.model.keyName}');
    });
  }


  Future<void> onReady() async{
    await super.onReady();
    ///语音播报
    startTts();

    ///定时刷新
    startTimerRefresh();

    searchFN.addListener(() async {
      if (searchTC.text.isNotEmpty){
        isSearchWidgetOpen = true;
      }
      else {
        isSearchWidgetOpen = searchFN.hasFocus;
      }
      if (rootCtl.isKeyboardOpenAfterClickTC && searchFN.hasFocus && !kIsWeb && GetPlatform.isWindows){
        await rootCtl.openKeyboard();
      }
      update();
    });
  }


  Map<String, String> setAccItemMap(){
    return {'adjust.reason': 'mplan'};
  }

  Future<bool> initializeForm() async {
    ///获取实时监控数据
    bool res = await getRealTimeMonitor();
    return res;
  }

  ///实时监控数据获取
  Future<bool> getRealTimeMonitor() async {
    PageConfig pageConfig = PageConfig(
      page: 1,
      rows: 10000,
      queryData: {
        'module': 1,
        'onpickers': 1,
      }
    );
    var result = await MoProcessRepository().getRealTimeMonitor(pageConfig);
    if(!result.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取生产实时监控时出错：${result.message}！');
      return false;
    }
    deviceTaskList.forEach((element) {
      Get.delete<ModelWithGetxController<MoDeviceTaskModel>>(tag: 'PMesDevice-${element.model.deviceId ?? ''}', force: true);
      element.onClose();
    });
    deviceTaskList.clear();
    deviceTaskList.addAll(result.rows.map((e) => ModelWithGetxController(model: e)));
    for (var element in deviceTaskList) {
      Get.create<ModelWithGetxController<MoDeviceTaskModel>>(() => element, tag: 'PMesDevice-${element.model.deviceId ?? ''}');
    }
    ///读取SOP附件
    getSopFormDeviceTaskList();
    getFilterOfDeviceTaskList();
    getNumOfDeviceSign();
    return true;
  }

  ///读取SOP附件
  Future<void> getSopFormDeviceTaskList() async{
    for (var element in deviceTaskList) {
      Map<String, String> map = await getSopIdAndCategory(sopProgId, element.model);
      if (map['id']!.isNotEmpty){
        var res = await FormRepository().getDocument(map['category']!, sopProgId, map['id']!);
        if (res.isSuccess && res.data.initialPreviewConfig != null
            && res.data.initialPreviewConfig!.isNotEmpty && res.data.initialPreviewConfig![0].type == 'image'){
          try {
            var item = Get.find<ModelWithGetxController<MoDeviceTaskModel>>(tag: 'PMesDevice-${element.model.deviceId ?? ''}');
            item.model.deviceImage = res.data.initialPreview?.asMap()[0];
            item.update();
          } catch (e){}
        }
        else if (res.isSuccess && res.data.initialPreviewConfig != null
            && res.data.initialPreviewConfig!.isNotEmpty && res.data.initialPreviewConfig![0].type == 'pdf'){
          String url = res.data.initialPreview?.asMap()[0] ?? '';
          if (url.isNotEmpty){
            Uint8List uint8listForAllPage = await DioService().downLoadFile(AddressService.getUrl(url));
            if (uint8listForAllPage.isNotEmpty){
              var list = Printing.raster(uint8listForAllPage, pages: [0], dpi: 72);
              var firstPage = await list.first;
              Uint8List uint8list = await firstPage.toPng();
              try {
                var item = Get.find<ModelWithGetxController<MoDeviceTaskModel>>(tag: 'PMesDevice-${element.model.deviceId ?? ''}');
                item.model.imageUint8List = uint8list;
                item.update();
              } catch (e){}
            }
          }
        }
      }
    }
  }

  ///读取技术指导书的对象 sopProgid 对应的对象id
  Future<Map<String, String>> getSopIdAndCategory(int sopProgid, MoDeviceTaskModel item) async {
    String id ='';
    String category = '';
    switch(sopProgid){
      case 700216: ///默认 模具与产品关系
        id = item.mouldProductId ?? '';
        category = 'sop';
        break;
      case 700217: ///模具与机台关系
        if (item.mouldId != null && item.mouldId!.isNotEmpty
            && item.deviceId != null && item.deviceId!.isNotEmpty){
          PageConfig _pageConfig = PageConfig(
            page: 1,
            rows: 1,
            queryData: {
              'MouldId': item.mouldId,
              'DeviceId': item.deviceId
            }
          );
          var _res = await MouldRepository().getDeviceRelationPageList(_pageConfig);
          if (_res.isSuccess && _res.rows.isNotEmpty){
            id = _res.rows[0].id ?? '';
            category = 'sop';
          }
        }
        break;
      case 700200: ///模具基本档案列表
      case 700201: ///模具基本档案
        id = item.mouldId ?? '';
        category = 'attach';
        break;
      case 200008: ///产品附件
        id = item.invId ?? '';
        category = 'attach';
        break;
    }

    return {'id': id, 'category': category};
  }

  ///筛选出相应的机台 （车间Id、设备编号）(display)
  void getFilterOfDeviceTaskList() {
    ///车间Code
    var _hideDepIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_DEP_ID_DISPLAY_KEY) ?? [];
    ///设备Code
    var _hideDeviceIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_DEVICE_ID_DISPLAY_KEY) ?? [];
    deviceTaskList.forEach((element) {
      element.model.isVisibleOfDep = true;
      element.model.isVisibleOfDevice = true;
      element.model.isVisibleOfDeviceSign = true;
      if (_hideDepIdList.contains(element.model.departmentId)){
        element.model.isVisibleOfDep = false;
      }
      if (_hideDeviceIdList.contains(element.model.deviceId)){
        element.model.isVisibleOfDevice = false;
      }
      if (unVisibleDeviceSignList.contains(element.model.deviceSign)){
        element.model.isVisibleOfDeviceSign = false;
      }
    });
    List<ModelWithGetxController<MoDeviceTaskModel>> deviceTaskFilterList = deviceTaskList.where(
            (element) => element.model.isVisibleOfDep && element.model.isVisibleOfDevice && element.model.isVisibleOfDeviceSign).toList();
    this.deviceTaskFilterList.clear();
    this.deviceTaskFilterList.addAll(deviceTaskFilterList);
  }

  ///筛选出相应的机台 （机台状态）(visible)
  void getNumOfDeviceSign() {
    List<ModelWithGetxController<MoDeviceTaskModel>> list = deviceTaskList.where(
            (element) => element.model.isVisibleOfDep && element.model.isVisibleOfDevice).toList();
    var item0 = Get.find<ModelWithGetxController<ChoiceChipModel>>(tag: 'PMesDevice-${deviceSignList[0].model.keyName}');
    item0.model.content = list.length.toString();
    item0.update();
    var item1 = Get.find<ModelWithGetxController<ChoiceChipModel>>(tag: 'PMesDevice-${deviceSignList[1].model.keyName}');
    item1.model.content = list.where((element) => element.model.deviceSign == DeviceSign.scz.sign).toList().length.toString();
    item1.update();
    var item2 = Get.find<ModelWithGetxController<ChoiceChipModel>>(tag: 'PMesDevice-${deviceSignList[2].model.keyName}');
    item2.model.content = list.where((element) => element.model.deviceSign == DeviceSign.dj.sign).toList().length.toString();
    item2.update();
    var item3 = Get.find<ModelWithGetxController<ChoiceChipModel>>(tag: 'PMesDevice-${deviceSignList[3].model.keyName}');
    item3.model.content = list.where((element) => element.model.deviceSign == DeviceSign.tjz.sign).toList().length.toString();
    item3.update();
    var item4 = Get.find<ModelWithGetxController<ChoiceChipModel>>(tag: 'PMesDevice-${deviceSignList[4].model.keyName}');
    item4.model.content = list.where((element) => element.model.deviceSign == DeviceSign.wlj.sign).toList().length.toString();
    item4.update();
  }

  //region 语音播报
  ///开始语音播报
  Future<void> startTts() async {
    if (isOpenOverProductFlutterTts || isOpenExceptionReportTts || isOpenAndonTts){
      if (Platform.isAndroid && (ShareStorageUtil.instance?.read(SharedPreferencesKeys.FLUTTERTTS_ENGINES) ?? '').isEmpty){
        ToastNotification(Get.overlayContext!).error("未安装或未选择语音包引擎！");
      }
      else {
        canTtsSpeech = true;
        ttsRunning = true;
        Future.doWhile(ttsDoWhile);
      }
    }
  }
  ///机台超产播报
  Future<bool> ttsDoWhile() async{
    try {
      await tts();
    } catch (e){}
    return ttsRunning;
  }
  Future<void> tts() async{
    await Future.doWhile(() async{ ///在进行新增语音播报时，不能循环播报
      await Future.delayed(const Duration(seconds: 1));
      if (isSpeechNewData){
        return true;
      }
      else {
        return false;
      }
    });
    if (!ttsRunning){ return; }

    //region 开始语音播报
    if (isOpenOverProductFlutterTts){
      try{ ///超产播报
        await Future.forEach(deviceTaskList, (ModelWithGetxController<MoDeviceTaskModel> element) async{
          double _qty = (element.model.finishQty ?? 0) - (element.model.assignQty ?? 0) - (element.model.overQty ?? 0);
          if (element.model.deviceSign == DeviceSign.scz.sign && leadTimeOverProductWarnFlutterTts != 0
              && element.model.surplusTime != null && element.model.surplusTime != 0 && element.model.surplusTime! <= leadTimeOverProductWarnFlutterTts){ ///超产提前预警语音播报
            if (!ttsRunning || isSpeechNewData){
              throw Error(); /// forEach 无法正常跳出循环，需要使用抛出异常的方式跳出循环
            }
            await flutterTtsService.flutterTtsSpeak(
                '${flutterTtsService.changeArabicToChineseForNumerals(element.model.deviceCode ?? '')}号机，即将于${NumFormatUtil.timeFormatConverter(element.model.surplusTime)}后超产！',
                repetitions: numOfEachCycleFlutterTts
            );
          }
          else if (element.model.deviceSign == DeviceSign.scz.sign && _qty > 0) { ///超产语音播报
            if (!ttsRunning || isSpeechNewData){
              throw Error(); /// forEach 无法正常跳出循环，需要使用抛出异常的方式跳出循环
            }
            await flutterTtsService.flutterTtsSpeak(
                '${flutterTtsService.changeArabicToChineseForNumerals(element.model.deviceCode ?? '')}号机，已超产${_qty.toStringAsFixed(0)}个！',
                repetitions: numOfEachCycleFlutterTts
            );
          }
        });
      } catch(e){}
    }

    if (isOpenExceptionReportTts){
      try{ ///模具异常播报
        await Future.forEach(mEList, (MouldServiceModel element) async{
          if (element.serviceSign == 1){ ///当状态为报修时，播报语音
            if (!ttsRunning || isSpeechNewData){
              throw Error(); /// forEach 无法正常跳出循环，需要使用抛出异常的方式跳出循环
            }
            await flutterTtsService.flutterTtsSpeak(
                '${flutterTtsService.changeArabicToChineseForNumerals(element.mouldName ?? '')}，'
                    '在${flutterTtsService.changeArabicToChineseForNumerals(element.storageLocation ?? '')}，${element.serviceClass}。',
                repetitions: numOfEachCycleFlutterTts
            );
          }
        });
      } catch(e){}

      try { ///产品异常播报
        await Future.forEach(cRList, (MoCheckRecordModel element) async{
          if (element.serviceSign == 1){ ///当状态为报修时，播报语音
            if (!ttsRunning || isSpeechNewData){
              throw Error(); /// forEach 无法正常跳出循环，需要使用抛出异常的方式跳出循环
            }
            await flutterTtsService.flutterTtsSpeak(
                '机器：${flutterTtsService.changeArabicToChineseForNumerals(element.deviceCode ?? '')}，'
                    '产品异常待处理。',
                repetitions: numOfEachCycleFlutterTts
            );
          }
        });
      } catch(e){}

      try { ///设备异常播报
        await Future.forEach(dSList, (EAMServiceModel element) async{
          if (element.serviceSign == 1){ ///当状态为报修时，播报语音
            if (!ttsRunning || isSpeechNewData){
              throw Error(); /// forEach 无法正常跳出循环，需要使用抛出异常的方式跳出循环
            }
            await flutterTtsService.flutterTtsSpeak(
                '机器：${flutterTtsService.changeArabicToChineseForNumerals(element.deviceCode ?? '')}，'
                    '设备异常待处理。',
                repetitions: numOfEachCycleFlutterTts
            );
          }
        });
      } catch(e){}
    }

    if (isOpenAndonTts){
      try { ///全场呼叫播报
        await Future.forEach(mAList, (MoAndonServiceModel element) async{
          if (element.serviceSign == 1){ ///当状态为报修时，播报语音
            if (!ttsRunning || isSpeechNewData){
              throw Error(); /// forEach 无法正常跳出循环，需要使用抛出异常的方式跳出循环
            }
            await flutterTtsService.flutterTtsSpeak(
                '全场呼叫：${element.serviceName}待处理。',
                repetitions: numOfEachCycleFlutterTts
            );
          }
        });
      } catch(e){}
    }
    //endregion
    await Future.delayed(Duration(seconds: kDebugMode ? 10 : timeBetweenCycleFlutterTts));
  }
  ///新增异常报告时，进行语音播报（前面的内容播报完后，才能播报下一个）
  Future<void> ttsSpeakNew(String text, int speakNum) async{
    await Future.doWhile(() async{
      if (isSpeechNewData){
        await Future.delayed(const Duration(seconds: 1));
        PrintUtil.printDebug('正在进行新增播报，等待中');
        return true;
      }

      isSpeechNewData = true;
      await flutterTtsService.flutterTtsSpeak(text, repetitions: speakNum);
      isSpeechNewData = false;

      return false;
    });
  }
  //endregion

  //region 定时刷新
  Future<void> startTimerRefresh() async {
    if (isCanTimedRefresh){
      refreshRunning = true;
      Future.doWhile(dataRefreshDoWhile);
    }
  }
  Future<bool> dataRefreshDoWhile() async{
    await dataRefresh();
    return refreshRunning;
  }
  Future<void> dataRefresh() async{
    await Future.delayed(Duration(seconds: secondOfRefresh));
    if (!refreshRunning){ return; }
    await onRefreshData();
  }
  ///点击“刷新”按钮的回调
  Future<void> onRefreshData() async {
    if (isDataRefresh) { return; }
    isDataRefresh = true;
    update();
    //region 刷新数据
    await getRealTimeMonitor();
    //endregion
    await Future.delayed(const Duration(seconds: 1));
    isDataRefresh = false;
    update();
  }
  //endregion

  ///设备状态标签选择变化
  Future<void> deviceSignOnChanged(ModelWithGetxController<ChoiceChipModel> item) async{
    if (item.model.sign == -1){
      return;
    }
    if (unVisibleDeviceSignList.contains(item.model.sign)){
      unVisibleDeviceSignList.remove(item.model.sign);
    }
    else {
      unVisibleDeviceSignList.add(item.model.sign);
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_UN_VISIBLE_DEVICE_SIGN_LIST_KEY, unVisibleDeviceSignList);

    for (var element in deviceTaskList){
      element.model.isVisibleOfDeviceSign = true;
      if (unVisibleDeviceSignList.contains(element.model.deviceSign)){
        element.model.isVisibleOfDeviceSign = false;
      }
    }
    List<ModelWithGetxController<MoDeviceTaskModel>> deviceWorkBillFilterList = deviceTaskList.where(
            (element) => element.model.isVisibleOfDep && element.model.isVisibleOfDevice && element.model.isVisibleOfDeviceSign).toList();
    this.deviceTaskFilterList.clear();
    this.deviceTaskFilterList.addAll(deviceWorkBillFilterList);
    item.update();
    update();
  }

  @override
  Future<void> onData(WebSocketModel webSocketModel) async {
    switch(webSocketModel.name){
      case "MoProcessModel":
        //region 采集数量变更
        var data = json.decode(webSocketModel.data);
        if (data != null && deviceTaskList.length > 0){
          ModelWithGetxController<MoDeviceTaskModel>? item = deviceTaskList.firstWhereOrNull((element) => element.model.deviceId == data['deviceId']);
          if (item != null && item.model.deviceId != null && item.model.deviceId!.isNotEmpty) {
            //region
            item.model.assignQty = data['assignQty'];
            item.model.qualifiedQty = data['qualifiedQty'];
            item.model.processQty = data['processQty'];
            item.model.finishQty = data['finishQty'];
            item.model.disabledQty = data['disabledQty'];
            item.model.output = data['output'];
            item.model.availOutput = data['availOutput'];
            item.model.actualCycle = data['actualCycle'];
            item.model.cycleTime = data['cycleTime'];
            item.model.surplusTime = data['surplusTime'];
            item.model.status = data['Status'];
            if (item.model.deviceSign != data['processClass']) { ///事件分类（1:生产中 2:待机 4:停机  8:未连接(停机) 16:故障）
              item.model.deviceSign = data['processClass'];
              item.model.deviceStatus = DeviceSign.values.firstWhereOrNull((element) => element.sign == item.model.deviceSign)?.name ?? '';
              getNumOfDeviceSign();
            }
            //endregion
            Get.find<AppService>().eventBus.fire(item);
            item.update();
          }
        }
        //endregion
        break;
      case "MoDeviceTaskModel":
        //region 机台生产任务信息变更
        var data = json.decode(webSocketModel.data);
        if (data != null && deviceTaskList.length > 0){
          ModelWithGetxController<MoDeviceTaskModel>? item = deviceTaskList.firstWhereOrNull((element) => element.model.deviceId == data['deviceId']);
          if (item != null && item.model.deviceId != null && item.model.deviceId!.isNotEmpty) {
            //region
            item.model.status = data['Status'];
            item.model.deviceSign = data['deviceSign'];
            item.model.deviceStatus = data['deviceStatus'];
            getNumOfDeviceSign();
            item.model.taskId = data['taskId'];
            item.model.taskCode = data['taskCode'];
            item.model.mouldProductId = data['mouldProductId'];
            item.model.mouldId = data['mouldId'];
            item.model.mouldCode = data['mouldCode'];
            item.model.mouldName = data['mouldName'];
            item.model.invId = data['invId'];
            item.model.invCode = data['invCode'];
            item.model.invName = data['invName'];
            item.model.invStd = data['invStd'];
            item.model.departmentId = data['departmentId'];
            item.model.depId = data['depId'];
            item.model.depCode = data['depCode'];
            item.model.depName = data['depName'];
            item.model.departmentId = data['departmentId'];
            item.model.packingType = data['packingType'];
            item.model.assignQty = data['assignQty'];
            item.model.qualifiedQty = data['qualifiedQty'];
            item.model.processQty = data['processQty'];
            item.model.finishQty = data['finishQty'];
            item.model.disabledQty = data['disabledQty'];
            item.model.output = data['output'];
            item.model.availOutput = data['availOutput'];
            item.model.designOutput = data['designOutput'];
            item.model.actualCycle = data['actualCycle'];
            item.model.cycleTime = data['cycleTime'];
            item.model.surplusTime = data['surplusTime'];
            item.model.mtoNo = data['mtoNo'];
            item.model.startDate = DateTime.tryParse(data['startDate'].toString());
            item.model.dueFinishDate = DateTime.tryParse(data['dueFinishDate'].toString());
            item.model.invDefine1 = data['invDefine1'];
            item.model.invDefine2 = data['invDefine2'];
            item.model.invDefine3 = data['invDefine3'];
            item.model.free1 = data['free1'];
            item.model.free2 = data['free2'];
            item.model.free3 = data['free3'];
            item.model.free4 = data['free4'];
            item.model.free5 = data['free5'];
            item.model.free6 = data['free6'];
            item.model.free7 = data['free7'];
            item.model.free8 = data['free8'];
            item.model.free9 = data['free9'];
            item.model.free10 = data['free10'];
            item.model.isFree1 = data['isFree1'] ?? 0;
            item.model.isFree2 = data['isFree2'] ?? 0;
            item.model.isFree3 = data['isFree3'] ?? 0;
            item.model.isFree4 = data['isFree4'] ?? 0;
            item.model.isFree5 = data['isFree5'] ?? 0;
            item.model.isFree6 = data['isFree6'] ?? 0;
            item.model.isFree7 = data['isFree7'] ?? 0;
            item.model.isFree8 = data['isFree8'] ?? 0;
            item.model.isFree9 = data['isFree9'] ?? 0;
            item.model.isFree10 = data['isFree10'] ?? 0;
            //endregion
            //region sop附件读取
            item.model.deviceImage = null;
            item.model.imageUint8List = null;
            Map<String, String> map = await getSopIdAndCategory(sopProgId, item.model);
            if (map['id']!.isNotEmpty){
              var pres = await FormRepository().getDocument(map['category']!, sopProgId, map['id']!);
              if (pres.isSuccess && pres.data.initialPreviewConfig != null
                  && pres.data.initialPreviewConfig!.isNotEmpty && pres.data.initialPreviewConfig![0].type == 'image'){
                item.model.deviceImage = pres.data.initialPreview?.asMap()[0];
              }
              else if (pres.isSuccess && pres.data.initialPreviewConfig != null
                  && pres.data.initialPreviewConfig!.isNotEmpty && pres.data.initialPreviewConfig![0].type == 'pdf'){
                String url = pres.data.initialPreview?.asMap()[0] ?? '';
                if (url.isNotEmpty){
                  Uint8List uint8listForAllPage = await DioService().downLoadFile(AddressService.getUrl(url));
                  if (uint8listForAllPage.isNotEmpty){
                    var list = Printing.raster(uint8listForAllPage, pages: [0], dpi: 72);
                    var firstPage = await list.first;
                    Uint8List uint8list = await firstPage.toPng();
                    item.model.imageUint8List = uint8list;
                  }
                }
              }
            }
            //endregion
            Get.find<AppService>().eventBus.fire(item);
            item.update();
          }
        }
        //endregion
        break;
      case 'MouldServiceEntity':
      case 'MouldServiceModel':
        //region 模具异常 提交+修改
        var data = json.decode(webSocketModel.data);
        if (data != null){
          var res = await MouldServiceRepository().getItem(data['serviceId'] ?? '');
          if (res.isSuccess) {
            MouldServiceModel model = res.data;
            MouldServiceModel? oldModel = mEList.firstWhereOrNull((element) => model.serviceId == element.serviceId);
            if (oldModel == null && model.serviceSign == 1){ ///是新增的模具异常
              mEList.add(model);
              if (isOpenExceptionReportTts){
                await ttsSpeakNew(
                  '机器：${model.deviceCode}，新增模具异常报告。',
                  numOfEachCycleFlutterTts
                );
              }
            }
            else if (oldModel != null && model.serviceSign != 1){ ///在列表中，并且状态变为维修中
              mEList.removeWhere((element) => model.serviceId == element.serviceId);
            }
            else if (oldModel != null){
              oldModel = model;
            }
          }
        }
        //endregion
        break;
      case 'MoCheckRecordEntity':
      case 'MoCheckRecordModel':
        //region 产品问题 提交+修改
        var data = json.decode(webSocketModel.data);
        if (data != null){
          var res = await MoCheckRecordRepository().getModel(data['moRecordId'] ?? '');
          if (res.isSuccess && res.data.progID == 811015) {
            MoCheckRecordModel model = res.data;
            MoCheckRecordModel? oldModel = cRList.firstWhereOrNull((element) => model.moRecordId == element.moRecordId);
            if (oldModel == null && model.serviceSign == 1){ ///是新增的异常
              cRList.add(model);
              if (isOpenExceptionReportTts){
                await ttsSpeakNew(
                    '机器：${model.deviceCode}，新增产品异常报告。',
                    numOfEachCycleFlutterTts
                );
              }
            }
            else if (oldModel != null && model.serviceSign != 1){
              cRList.removeWhere((element) => model.moRecordId == element.moRecordId);
            }
            else if (oldModel != null){
              oldModel = model;
            }
          }
        }
        //endregion
        break;
      case 'EAMServiceEntity':
      case 'EAMServiceModel':
        ///实际上，设备异常报告处理后（状态从报修变为维修中），没有传 webSocketModel
        //region 设备问题 提交+修改
        var data = json.decode(webSocketModel.data);
        if (data != null){
          var res = await EAMServiceRepository().getItem(data['ServiceId'] ?? '');
          if (res.isSuccess) {
            EAMServiceModel model = res.data;
            EAMServiceModel? oldModel = dSList.firstWhereOrNull((element) => model.serviceId == element.serviceId);
            if (oldModel == null && model.serviceSign == 1){ ///是新增的异常
              dSList.add(model);
              if (isOpenExceptionReportTts){
                await ttsSpeakNew(
                    '机器：${model.deviceCode}，新增设备异常报告。',
                    numOfEachCycleFlutterTts
                );
              }
              else if (oldModel != null && model.serviceSign != 1){ ///在列表中，并且状态变为维修中
                dSList.removeWhere((element) => model.serviceId == element.serviceId);
              }
              else if (oldModel != null){
                oldModel = model;
              }
            }
          }
        }
        //endregion
        break;
      case 'MoAndonServiceEntity':
      case 'MoAndonServiceModel':
        //region 全场呼叫
        var data = json.decode(webSocketModel.data);
        if (data != null){
          var res = await AndonServiceRepository().getFormData(data['serviceId'] ?? '');
          if (res.isSuccess){
            MoAndonServiceModel model = res.data;
            MoAndonServiceModel? oldModel = mAList.firstWhereOrNull((element) => element.serviceId == model.serviceId);
            if (oldModel == null && model.serviceSign == 1){ ///是新增内容
              mAList.add(model);
              if (isOpenAndonTts){
                await ttsSpeakNew(
                    '全场呼叫：新增${model.serviceName}。',
                    numOfEachCycleFlutterTts
                );
              }
            }
            else if (oldModel != null && model.serviceSign != 1){ ///在列表中，并且状态变为维修中
              mAList.removeWhere((element) => model.serviceId == element.serviceId);
            }
            else if (oldModel != null){
              oldModel = model;
            }
          }
        }
        //endregion
        break;
    }
  }


  //region 搜索
  ///搜索框输入变化
  Future<void> searchTCOnSearch() async {
    _debounce(() async{
      searchFN.unfocus();
      await deviceCodeSearch();
      update();
    });
  }

  ///搜索框清空
  Future<void> searchTCClear() async{
    searchTC.text = '';
    isSearchWidgetOpen = false;
    await deviceCodeSearch();
    searchFN.unfocus();
    update();
  }

  ///根据设备编号搜索
  Future<void> deviceCodeSearch() async{
    ProgressDialogUtil.showProgressDialog();
    List<ModelWithGetxController<MoDeviceTaskModel>> deviceTaskFilterList = deviceTaskList.where(
            (element) => element.model.isVisibleOfDep && element.model.isVisibleOfDevice && element.model.isVisibleOfDeviceSign
            && (element.model.deviceCode ?? '').toLowerCase().contains(searchTC.text)).toList();
    this.deviceTaskFilterList.clear();
    this.deviceTaskFilterList.addAll(deviceTaskFilterList);
    ProgressDialogUtil.update(value: 1, msg: '查询成功！');
  }
  //endregion


  ///1=报修 2=维修中  4=已试模  8=待验收  256=已结束
  getServiceStatus(int sign){
    switch (sign){
      case 1:
        return '报修';
      case 2:
        return '维修中';
      case 4:
        return '已试模';
      case 8:
        return '待验收';
      case 256:
        return '已结束';
      default:
        return '';
    }
  }

  String getAndonStatus(int sign){
    switch (sign) {
      case 1:
        return '待处理';
      case 2:
        return '处理中';
      case 4:
        return '待确认';
      case 8:
        return '已处理';
      default:
        return '';
    }
  }


  @override
  Future<void> onClose() async {
    _debounce.dispose();
    searchFN.dispose();
    searchTC.dispose();
    ttsRunning = false;
    refreshRunning = false;
    await flutterTtsService.flutterTts.stop();
    deviceSignList.forEach((element) {
      Get.delete<ModelWithGetxController<ChoiceChipModel>>(tag: 'PMesDevice-${element.model.keyName}', force: true);
      element.onClose();
    });
    deviceTaskList.forEach((element) {
      Get.delete<ModelWithGetxController<MoDeviceTaskModel>>(tag: 'PMesDevice-${element.model.deviceId ?? ''}', force: true);
      element.onClose();
    });
    deviceTaskController.dispose();
    super.onClose();
  }

}
