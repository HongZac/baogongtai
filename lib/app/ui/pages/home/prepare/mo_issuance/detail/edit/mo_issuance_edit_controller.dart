
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/service/serial_com_service/mixin/serial_port_getx_listener.dart';
import 'package:desktop/app/service/serial_com_service/serial_port_data_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/detail/detail_tab/mo_issuance_detail_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/mo_issuance_controller.dart';
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

///发料单 报工（详情修改）页
class MoIssuanceEditController
    extends BaseFormController
    with SerialPortGetXListenerMixin<MoIssuanceEditController>, ScanInterface<MoIssuanceEditController>,
        InterfaceUtil {

  MoIssuanceDetailTabController? moIssuanceDetailTabController;

  ///要报工的发料单（初始值：上一个页面选中的发料单）
  MoIssuanceModel issuanceModel;

  final ScrollController issuanceDetailController = ScrollController();

  final List<NumPadController> numPadCTList = [
    NumPadController(key: NumPadUtil.num, zhName: '件数'), ///入库箱数（装箱数）(整箱箱数)
    NumPadController(key: NumPadUtil.qty, zhName: '总重'), ///报工总数量
  ];

  ///数据填报表单输入时启用时间防抖
  final Debounce debounce = Debounce(const Duration(milliseconds: 500));

  late final MoIssuanceModel editIssuanceModel;
  PersonAdapter? personAdapter;
  PersonModel personModel = PersonModel();

  ///人员是否可以通过 Adapter 选单
  bool isPsnHasAdapter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MO_ISSUANCE_SUBMIT_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
  ///生产人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间（发料单只有0、2！）
  int psnGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MO_ISSUANCE_SUBMIT_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
  ///生产人员获取条件 车间固定值（选单用）
  String psnDepCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MO_ISSUANCE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY) ?? AppConfig.psnDepCode;


  MoIssuanceEditController({
    super.progId = 651072,
    required this.issuanceModel,
  }){
    editIssuanceModel = MoIssuanceModel.fromJson(issuanceModel.toJson());
  }


  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
      moIssuanceDetailTabController = Get.find<MoIssuanceDetailTabController>();
    });
  }

  @override
  Future<bool> initializeForm() async {
    if (isPsnHasAdapter){
      await getPersonAdapter();
    }
    else {
      personModel = PersonModel();
    }
    NumPadUtil().setText(NumPadUtil.num,
        NumFormatUtil.qtyFormatConverter((editIssuanceModel.number ?? 0).toString(), decimal: 0),
        numPadCTList
    );
    NumPadUtil().setText(
        NumPadUtil.qty,
        NumFormatUtil.qtyFormatConverter((editIssuanceModel.qty ?? 0).toString(), decimal: 2),
        numPadCTList)
    ;

    return true;
  }


  //region Adapter

  ///获取人员Adapter
  Future<void> getPersonAdapter() async{
    personAdapter = await AdapterHelper.getAsyncAdapter(
      'person',
      multipleSelection: false,
      isNeedLoadData: true,
      queryData: {
        'DepCode': getPsnDepCode(),
        'Active': 0, ///Active:0不显示离职人员
      },
    ) as PersonAdapter;
    ///处理初始选中值（因为[editIssuanceModel]中只保存了人员名称）
    if (editIssuanceModel.issuer != null && editIssuanceModel.issuer!.isNotEmpty){
      bool isListHasSelected = false; ///是否获取到初始的已选中的对象
      bool isAllEmpty = true; ///initSelectedItems 中的 id 是否都为空
      //todo
      personAdapter!.initSelectedItems.clear();
      await Future.doWhile(() async {
        if (personAdapter!.pageConfig.page == personAdapter!.totalPage) {
          PersonModel? item = personAdapter!.dataList.firstWhereOrNull((element) => element.name == editIssuanceModel.issuer);
          if (item != null){
            item.isSelected = true;
            personAdapter!.initSelectedItems.add(item);
          }
          return false;
        }
        personAdapter!.pageConfig.page = personAdapter!.pageConfig.page + 1;
        var res = await personAdapter!.asyncData(personAdapter!.pageConfig);
        personAdapter!.totalRecords = res.records ?? 0;
        personAdapter!.totalPage = res.total ?? 0;
        personAdapter!.errorMessage = res.isSuccess ? '' : res.message;
        isAllEmpty = false;
        for (var element1 in res.rows) {
          if (editIssuanceModel.issuer == element1.name) {
            element1.isSelected = true;
            isListHasSelected = true;
            personAdapter!.initSelectedItems.add(element1);
            break; ///如果已经找到选中对象，则跳出循环
          }
        }
        personAdapter!.dataList.addAll(res.rows);
        if (isAllEmpty) {
          isListHasSelected = true;
        }
        return !isListHasSelected;
      });
      personAdapter!.visibleItems.clear();
      personAdapter!.visibleItems.addAll(personAdapter!.dataList);
    }
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

  //endregion


  //region OnChanged

  ///人员选择变化
  Future<void> psnOnChanged(List<PickerDataModel> list) async{
    editIssuanceModel.issuer = list.map((e) => e.name).join(',');
    update();
  }

  //endregion


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
        if ((editIssuanceModel.issuer ?? '').contains(res1.data.name)){
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

  //endregion


  ///保存记录
  Future<void> saveIssuance(bool isPrint) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 提交前检查
    if (editIssuanceModel.moIssueId == null || editIssuanceModel.moIssueId!.isEmpty){
      ToastNotification(Get.overlayContext!).warn('发料单数据错误！');
      isLoading = false;
      return;
    }
    if (editIssuanceModel.issuer == null || editIssuanceModel.issuer!.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择发料人员！");
      isLoading = false;
      return;
    }
    //qtyTC；numberTC 件数
    String numberString = NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '';
    if (int.tryParse(numberString) == null || int.tryParse(numberString)! < 1){
      ToastNotification(Get.overlayContext!).warn("件数输入错误！");
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
                              text: '${editIssuanceModel.invName ?? ''}\n',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              )
                          ),
                          const TextSpan(text: '产品：'),
                          TextSpan(
                              text: '${editIssuanceModel.productName ?? ''}\n',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              )
                          ),
                          const TextSpan(text: '色粉：'),
                          TextSpan(
                              text: '${editIssuanceModel.toner ?? ''}\n',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              )
                          ),
                          const TextSpan(text: '发料人员：'),
                          TextSpan(
                              text: '${editIssuanceModel.issuer ?? ''}\n',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              )
                          ),
                          TextSpan(
                              text: '总重：$qtyString； '
                                  '打印份数：$numberString； '
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
      frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MO_ISSUANCE_SUBMIT_TEMPLATE_FILENAME_KEY) ?? AppConfig.moIssuancePrintFileName;
      if (frxName.isEmpty){
        ToastNotification(Get.overlayContext!).error('打印的模板名称为空，请在设置中修改！');
        isLoading = false;
        return;
      }
      //endregion
    }
    ProgressDialogUtil.showProgressDialog(max: isPrint ? 3 : 2, msg: '正在提交发料记录', completedMsg: '数据刷新成功！');
    //region 提交报工记录
    //region 赋值
    editIssuanceModel.number = double.tryParse(numberString);
    editIssuanceModel.qty = double.tryParse(qtyString);
    //endregion
    var res = await MoIssuanceRepository().saveVoucher(editIssuanceModel.moIssueId ?? '', editIssuanceModel);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('发料记录提交失败！${res.message}！');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '发料记录提交成功，正在刷新数据！');
    //endregion
    //region 刷新页面
    issuanceModel.qty = editIssuanceModel.qty;
    issuanceModel.number = editIssuanceModel.number;
    issuanceModel.issuer = editIssuanceModel.issuer;
    //region 首页：当前报工任务单的已报工数量
    MoIssuanceController moIssuanceController = Get.find<MoIssuanceController>();
    MoIssuanceModel? issuance = moIssuanceController.dataList.firstWhereOrNull((element) => element.moIssueId == editIssuanceModel.moIssueId);
    if (issuance != null){
      issuance.qty = editIssuanceModel.qty;
      issuance.number = editIssuanceModel.number;
      issuance.issuer = editIssuanceModel.issuer;
    }
    moIssuanceController.update();
    //endregion
    update();
    ProgressDialogUtil.update(value: 2);
    //endregion
    if (isPrint){
      //region 打印
      String url = MoIssuanceRepository().getPrintUrl(res.data.data ?? '', frxName, 'pdf');
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
          int num = editIssuanceModel.number!.toInt();
          for (int index = 0; index < num; index ++) {
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
          }
          ProgressDialogUtil.update(value: 3);
          ToastNotification(Get.overlayContext!).info("打印完成，共${editIssuanceModel.number}份！");
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
    issuanceDetailController.dispose();
    numPadCTList.forEach((element) {
      element.dispose();
    });
    super.onClose();
  }


}