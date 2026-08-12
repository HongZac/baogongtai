
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/mixin/serial_port_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/mixin/tcp_socket_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/detail_tab/mo_mixture_detail_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/submit_list/mo_mixture_submit_list_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/mo_mixture_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';


///拌料单 651073 OR 粉料单 651078 报工页面
class MoMixtureSubmitController
    extends BaseFormController
    with SerialPortGetXListenerMixin<MoMixtureSubmitController>, ScanInterface<MoMixtureSubmitController>,
        TcpSocketGetxListenerMixin<MoMixtureSubmitController>,
        InterfaceUtil {

  final int mainProgId;
  late final String typeTitle = mainProgId == 651071 ? '拌料' : mainProgId == 651076 ? '粉料' : '';

  MoMixtureDetailTabController? moMixtureDetailTabController;

  ///要报工的拌料单（初始值：上一个页面选中的拌料单）
  MoMixtureModel mixtureModel;
  final ScrollController mixtureDetailController = ScrollController();

  final List<NumPadController> numPadCTList = [
    NumPadController(key: NumPadUtil.singleBoxQty, zhName: '包重'), ///单箱数量 == 单箱件数（一箱里面装几个）（从数据库中读取，且数据可修改）
    NumPadController(key: NumPadUtil.num, zhName: '件数', enabled: false), ///入库箱数（装箱数）(整箱箱数)
    NumPadController(key: NumPadUtil.qty, zhName: '总重'), ///报工总数量
  ];

  ///数据填报表单输入时启用时间防抖
  final Debounce debounce = Debounce(const Duration(milliseconds: 500));

  final MoMixSubmitModel mixSubmitModel = MoMixSubmitModel();
  PersonAdapter? personAdapter;
  PersonModel personModel = PersonModel();
  MoMixtureAdapter? mixtureAdapter;

  ///人员是否可以通过 Adapter 选单
  late bool isPsnHasAdapter = ShareStorageUtil.instance?.read(ShareKeyUtil().getMoPowderSharedPreferencesKey(
      mainProgId,
      SharedPreferencesKeys.MO_MIXTURE_SUBMIT_IS_PSN_HAS_ADAPTER_KEY
  )) ?? AppConfig.isPsnHasAdapter;
  ///生产人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间（拌料单只有0、2！）
  late int psnGetWayIndex = ShareStorageUtil.instance?.read(ShareKeyUtil().getMoPowderSharedPreferencesKey(
      mainProgId,
      SharedPreferencesKeys.MO_MIXTURE_SUBMIT_PSN_GET_WAY_INDEX_KEY
  )) ?? AppConfig.psnGetWayIndex;
  ///生产人员获取条件 车间固定值（选单用）
  late String psnDepCode = ShareStorageUtil.instance?.read(ShareKeyUtil().getMoPowderSharedPreferencesKey(
      mainProgId,
      SharedPreferencesKeys.MO_MIXTURE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY
  )) ?? AppConfig.psnDepCode;
  

  MoMixtureSubmitController({
    required super.progId,
    required this.mixtureModel,
    required this.mainProgId,
  });

  
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
      moMixtureDetailTabController = Get.find<MoMixtureDetailTabController>();
    });
  }


  @override
  Future<bool> initializeForm() async {
    //region 获取 mixtureModel 的初始默认值
    mixSubmitModel.progid = progId;
    mixSubmitModel.sign = 0;
    mixSubmitModel.status = '';
    mixSubmitModel.enableMark = 1;
    mixSubmitModel.deleteMark = 0;
    mixSubmitModel.billDate = DateTime.now();
    mixSubmitModel.moMixId = mixtureModel.moMixtureId;
    mixSubmitModel.invId = mixtureModel.invId;
    mixSubmitModel.productId = mixtureModel.productId;
    //endregion
    if (isPsnHasAdapter){
      await getPersonAdapter();
    }
    else {
      personModel = PersonModel();
    }
    await getMixtureAdapter();
    NumPadUtil().setText(NumPadUtil.singleBoxQty, (mixtureModel.boxQty ?? 0).toStringAsFixed(2), numPadCTList);

    return true;
  }
  
  
  //region Adapter

  ///获取人员Adapter
  Future<void> getPersonAdapter() async{
    List<PickerDataModel> list = mixSubmitModel.empId == null || mixSubmitModel.empId!.isEmpty
        ? []
        : mixSubmitModel.empId!.split(',').map((e) => PickerDataModel(id: e)).toList();
    personAdapter = await AdapterHelper.getAsyncAdapter(
      'person',
      multipleSelection: true,
      isNeedLoadData: true,
      queryData: {
        'DepCode': getPsnDepCode(),
        'Active': 0, ///Active:0不显示离职人员
      },
      selectedItems: list,
    ) as PersonAdapter;
  }

  ///获取人员列表的条件
  String? getPsnDepCode(){
    switch (psnGetWayIndex){
      case 0: ///全部
        return '';
      case 2: ///固定车间
        return psnDepCode;
      case 1:
      default:
        return '';
    }
  }

  ///获取拌料单Adapter
  Future<void> getMixtureAdapter() async{
    mixtureAdapter = await AdapterHelper.getAsyncAdapter(
      'moMixture',
      isNeedLoadData: false,
      queryData: {
        'progid': mainProgId,
      },
      selectedItems: [PickerDataModel(id: mixtureModel.moMixtureId)]
    ) as MoMixtureAdapter;
  }

  //endregion


  //region OnChanged

  ///人员选择变化
  Future<void> psnOnChanged(List<PickerDataModel> list) async{
    mixSubmitModel.empId = list.map((e) => e.id).join(',');
    mixSubmitModel.employee = list.map((e) => e.name).join(',');
    update();
  }

  ///拌料单Adapter选择变化
  Future<void> mixtureModelOnChanged(PickerDataModel model) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    ProgressDialogUtil.showProgressDialog();

    if (model.id != mixtureModel.moMixtureId){
      var result = await MoMixtureRepository().getModel(model.id);
      if (!result.isSuccess){
        ToastNotification(Get.overlayContext!).error('获取拌料单详情时出错：${result.message}！');
        ProgressDialogUtil.close();
        isLoading = false;
        return;
      }
      await getOtherMixture(result.data);
    }

    isLoading = false;
    update();
    ProgressDialogUtil.update(value: 1);
  }

  ///拌料单选择变化
  Future<void> getOtherMixture(MoMixtureModel item, {bool isOtherPageNeedChanged = true}) async {
    if (mixtureModel.moMixtureId == item.moMixtureId){
      return;
    }
    //region
    mixtureModel = item;
    mixSubmitModel.moMixId = mixtureModel.moMixtureId;
    mixSubmitModel.invId = mixtureModel.invId;
    mixSubmitModel.productId = mixtureModel.productId;
    NumPadUtil().setText(NumPadUtil.singleBoxQty, (mixtureModel.boxQty ?? 0).toStringAsFixed(2), numPadCTList);
    getNumberTC();
    //endregion
    if (isOtherPageNeedChanged){
      if (moMixtureDetailTabController != null){
        moMixtureDetailTabController!.mixtureModel = item;
        moMixtureDetailTabController!.moMixtureId = item.moMixtureId ?? '';

        //region  刷新拌料单报工列表
        MoMixtureSubmitListController? mixtureSubmitListController;
        try {
          mixtureSubmitListController = Get.find<MoMixtureSubmitListController>();
        } catch (e){}
        if (mixtureSubmitListController != null){
          mixtureSubmitListController.dataListPageConfig.queryData!['MoMixId'] = item.moMixtureId;
          await mixtureSubmitListController.pageChanged(showLoading: false);
          mixtureSubmitListController.update();
        }
        //endregion
      }
    }
  }

  //endregion


  //region 串口、扫码、TCP

  @override
  Future<void> onSerialPortData(SerialPortDataModel serialPortDataModel) async {
    for (var element in serialComService.serialPortMsgProcessList){
      if (element.com == serialPortDataModel.com){
        portMsgOnData(
          element.keyName,
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
      case AppConfig.scanGun:
      case AppConfig.cardReader:
        onBarcode(data);
        break;
    }
  }

  @override
  Future<void> onBarcode(String searchString) async{
    if (kDebugMode){
      searchString = '|G|AS001_0115';
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
      ToastNotification(Get.overlayContext!).warn('条码错误，请检查设置的默认条码格式！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    switch (list[1]){
      case 'G':
        //region 员工条码
        String psnNum = list[2];
        var res1 = await PersonRepository().getFormData('', '', {'PsnNum': psnNum}, 0);
        if (!res1.isSuccess){
          ToastNotification(Get.overlayContext!).warn('获取员工数据时出错：${res1.message}！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (res1.data.id.isEmpty){
          ToastNotification(Get.overlayContext!).warn('查询不到该员工！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if ((mixSubmitModel.empId ?? '').contains(res1.data.id)){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (isPsnHasAdapter){
          for (var element in (personAdapter?.dataList ?? [])) {
            if (element.id == res1.data.id){
              element.isSelected = true;
            }
            else {
              element.isSelected = false;
            }
          }
        }
        else {
          personModel = res1.data;
        }
        await psnOnChanged([res1.data]);
        //endregion
        break;
      default:
        ToastNotification(Get.overlayContext!).warn('条码错误！');
        isLoading = false;
        ProgressDialogUtil.close();
        return;
    }

    isLoading = false;
    update();
    ProgressDialogUtil.update(value: 1);
  }

  @override
  Future<void> onTcpSocketData(TcpSocketDataModel tcpSocketDataModel) async {
    for (var element in tcpSocketService.tcpSocketMsgProcessList){
      if (element.host == tcpSocketDataModel.host && element.port == tcpSocketDataModel.port){
        portMsgOnData(
          element.keyName,
          data: tcpSocketDataModel.data,
          accuracy: element.accuracy,
        );
      }
    }
  }

  //endregion


  //region NumPad 计算

  ///数据填报后的计算
  void calcQty(String keyName){
    debounce((){
      switch (keyName){
        case NumPadUtil.singleBoxQty: ///包重 单箱数量 == 单箱件数（一箱里面装几个）（从数据库中读取，且数据可修改）
        case NumPadUtil.qty: ///总重 报工总数量
          getNumberTC();
          break;
      }
      update();
    });
  }

  ///计算件数 入库箱数（装箱数）(整箱箱数)
  void getNumberTC() {
    double boxQty = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') ?? 0;
    double qty = double.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '') ?? 0;
    String numberStr;
    if (boxQty > 0 && qty > 0){
      numberStr = (qty / boxQty).ceil().toStringAsFixed(0);
    }
    else {
      numberStr = '';
    }
    NumPadUtil().setText(NumPadUtil.num, numberStr, numPadCTList);
  }

  //endregion


  ///保存报工记录
  Future<void> saveSubmit(bool isPrint) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 提交前检查
    if (mixtureModel.moMixtureId == null || mixtureModel.moMixtureId!.isEmpty){
      ToastNotification(Get.overlayContext!).warn('$typeTitle单数据错误！');
      isLoading = false;
      return;
    }
    if (mixSubmitModel.empId == null || mixSubmitModel.empId!.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择生产人员！");
      isLoading = false;
      return;
    }
    String boxQtyString = NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '';
    if (double.tryParse(boxQtyString) == null || double.tryParse(boxQtyString)! <= 0){
      ToastNotification(Get.overlayContext!).warn("包重输入错误！");
      isLoading = false;
      return;
    }
    String qtyString = NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '';
    if (double.tryParse(qtyString) == null || double.tryParse(qtyString)! <= 0){
      ToastNotification(Get.overlayContext!).warn("总重输入错误！");
      isLoading = false;
      return;
    }
    double? maxQty = double.tryParse(objectItem.attributeList.firstWhereOrNull((e) => e.code == 'maxQty')?.text ?? '');
    if (maxQty != null && maxQty >= 0 && double.tryParse(qtyString)! > maxQty){
      ToastNotification(Get.overlayContext!).warn("总重不能大于上限值（$maxQty），请重输！");
      isLoading = false;
      return;
    }

    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!,
      contentWidget: Container(
        width: 1920, height: 968,
        color: Theme.of(Get.context!).colorScheme.surface,
        child: Column(
          children: [
            Divider(
              indent: 0, endIndent: 0,
              color: Theme.of(Get.context!).dividerTheme.color!.withAlpha(102),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                        text: '确认提交报工记录？\n'
                            '请仔细确认打印的内容：\n材料：',
                        style: Theme.of(Get.context!).textTheme.bodyLarge,
                        children: [
                          TextSpan(
                            text: '${mixtureModel.invName ?? ''}\n',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            )
                          ),
                          const TextSpan(text: '色粉：'),
                          TextSpan(
                            text: '${mixtureModel.toner ?? ''}\n',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            )
                          ),
                          const TextSpan(text: '配方：'),
                          TextSpan(
                            text: '${mixtureModel.formula ?? ''}\n',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            )
                          ),
                          TextSpan(
                            text: '包重：$boxQtyString； '
                                '总重：$qtyString； '
                                '打印份数：${NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? ''}； '
                          ),
                        ]
                    ),
                    textScaler: TextScaler.linear(FontFamilyConfig.textScale),
                  ),
                ),
              ),
            ),
            Divider(
              indent: 0, endIndent: 0,
              color: Theme.of(Get.context!).dividerTheme.color!.withAlpha(102),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    String printerUrl = ''; ///打印机Url
    String printerName = ''; ///打印机Name
    String frxName = ''; ///模板文件名称
    if (isPrint){
      Map<String, dynamic> printInfoMap = await getPrintInfo();
      printerUrl = printInfoMap['printerUrl']!; ///打印机Url
      printerName = printInfoMap['printerName']!; ///打印机Name
      //defaultPrintCopies = printInfoMap['printCopies']!; ///打印份数
      //printType = printInfoMap['printType']!; ///打印方式
      //region 获取模板文件名称 frxName
      frxName = ShareStorageUtil.instance?.read(ShareKeyUtil().getMoPowderSharedPreferencesKey(
          mainProgId,
          SharedPreferencesKeys.MO_MIXTURE_SUBMIT_TEMPLATE_FILENAME_KEY
      )) ?? AppConfigUtil().getMoPowderAppConfig(mainProgId, AppConfig.moMixtureSubmitPrintFileName);
      if (frxName.isEmpty){
        ToastNotification(Get.overlayContext!).error('打印的模板名称为空，请在设置中修改！');
        isLoading = false;
        return;
      }
      //endregion
    }
    ProgressDialogUtil.showProgressDialog(max: isPrint ? 3 : 2, msg: '正在提交报工记录', completedMsg: '数据刷新成功！');
    //region 提交报工记录
    //region 赋值
    mixSubmitModel.createDate = DateTime.now();
    mixSubmitModel.billDate = DateTime.now();
    mixSubmitModel.boxQty = double.tryParse(boxQtyString);
    mixSubmitModel.number = double.tryParse(NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '');
    mixSubmitModel.qty = double.tryParse(qtyString);
    //endregion
    var res = await MoMixSubmitRepository().saveVoucher('', mixSubmitModel);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('报工记录提交失败！${res.message}！');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '报工记录提交成功，正在刷新数据！');
    //endregion
    //region 刷新页面
    ///本页面：工序列表的合格数量；当前报工任务单的已质检数量
    mixtureModel.submitQty = (mixtureModel.submitQty ?? 0) + mixSubmitModel.qty!;
    //region 首页：当前报工任务单的已报工数量
    MoMixtureController moMixtureController = Get.find<MoMixtureController>(tag: mainProgId.toString());
    MoMixtureModel? mixture = moMixtureController.dataList.firstWhereOrNull((element) => element.moMixtureId == mixSubmitModel.moMixId);
    if (mixture != null){
      mixture.submitQty = mixtureModel.submitQty;
    }
    moMixtureController.update();
    //endregion
    if (moMixtureDetailTabController != null){
      //region 报工单列表页面：刷新
      MoMixtureSubmitListController? mixtureSubmitListController;
      try {
        mixtureSubmitListController = Get.find<MoMixtureSubmitListController>();
      } catch (e){}
      if (mixtureSubmitListController != null){
        await mixtureSubmitListController.pageChanged(showLoading: false);
        mixtureSubmitListController.update();
      }
      //endregion
    }
    mixSubmitModel.boxQty = 0;
    int printNum = mixSubmitModel.number?.toInt() ?? 0; ///打印份数，打印时要用到
    mixSubmitModel.number = 0;
    mixSubmitModel.qty = 0;
    numPadCTList.forEach((element) {
      element.controller.clear();
    });
    update();
    ProgressDialogUtil.update(value: 2);
    //endregion
    if (isPrint){
      //region 打印
      String url = MoMixSubmitRepository().getPrintUrl(res.data.data ?? '', frxName, 'pdf');
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
          ProgressDialogUtil.update(value: 3);
          ToastNotification(Get.overlayContext!).info("打印完成，共$printNum份！");
          isLoading = false;
        },
        onError: (String message){
          ToastNotification(Get.overlayContext!).error("打印文件生成失败！");
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        },
      );
      //endregion
    }
    else {
      isLoading = false;
    }
  }


  @override
  void onClose() {
    debounce.dispose();
    mixtureDetailController.dispose();
    numPadCTList.forEach((element) {
      element.dispose();
    });
    super.onClose();
  }
  
}