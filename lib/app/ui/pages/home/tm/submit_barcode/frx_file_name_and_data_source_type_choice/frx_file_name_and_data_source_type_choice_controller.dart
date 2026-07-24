import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///打印模板文件、数据源类型名称选择
class FrxFileNameAndDataSourceTypeChoiceController extends BaseDialogController{

  final ScrollController scrollController = ScrollController();

  ///打印模板文件名称
  String frxFileName = '';
  ///数据源类型名称
  String dataSourceType = '';
  /// 获取打印方式  (服务端打印 serverPrint OR 本地打印 localPrint) printType
  final String printType;

  ///产品类别
  final String invCCode;

  final List<ChoiceChipModel> frxFileNameList = [];


  FrxFileNameAndDataSourceTypeChoiceController({
    required this.printType,
    required this.invCCode,
  });


  @override
  void onInit() {
    super.onInit();

    List<ChoiceChipModel> frxFileList = [
      ChoiceChipModel(keyName: SharedPreferencesKeys.DEVICE_DETAIL_PACKING_PRINT_FILE_NAME_KEY, content: AppConfig.packingPrintFrxName), ///详情页面 装箱单打印模板
      ChoiceChipModel(keyName: SharedPreferencesKeys.DEVICE_SUBMIT_TEMPLATE_FILENAME_KEY, content: AppConfig.deviceSubmitPrintFileName), ///机台报工单 装箱单打印模板
      ChoiceChipModel(keyName: SharedPreferencesKeys.MES_TASK_SUBMIT_TEMPLATE_FILENAME_KEY, content: AppConfig.mesTaskSubmitPrintFileName), ///生产派工单 报工单 装箱单打印模板

      ChoiceChipModel(keyName: SharedPreferencesKeys.DEVICE_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY, content: ''),
      ChoiceChipModel(keyName: SharedPreferencesKeys.MES_ORDER_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY, content: ''),
      ChoiceChipModel(keyName: SharedPreferencesKeys.MES_TASK_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY, content: ''),
    ];

    for (var element in frxFileList){
      var data = ShareStorageUtil.instance?.read(element.keyName) ?? (element.content.isEmpty ? {} : element.content);
      if (data is String){
        frxFileNameList.add(ChoiceChipModel(
          title: data,
        ));
      }
      else if (data is Map<String, String>){ //todo 测试
        data.forEach((key, value) {
          frxFileNameList.add(ChoiceChipModel(
            keyName: key,
            title: value,
          ));
        });
      }
    }

    ChoiceChipModel? frxFile = frxFileNameList.firstWhereOrNull((element) => element.keyName.isNotEmpty && element.keyName == invCCode);
    if (frxFile != null){
      frxFileName = frxFile.title;
    }

    update();
  }

  ///打印模板文件选择变化
  void frxFileNameOnChanged(ChoiceChipModel item){
    frxFileName = item.title;
    update();
  }

  ///数据源类型选择变化
  void dataSourceTypeOnChanged(ChoiceChipModel item){
    dataSourceType = item.keyName;
    update();
  }

  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async {
    if (actionName == DialogButtonActionEnum.confirm) {
      if (frxFileName.isEmpty){
        ToastNotification(Get.overlayContext!).error('请选择打印模板！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      if (printType == 'serverPrint' && dataSourceType.isEmpty){
        ToastNotification(Get.overlayContext!).error('请选择数据源类型！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      ToastNotification(Get.overlayContext!).success('打印模板选择成功！');
      return DialogReturnDataModel(isCanCloseDialog: true, data: {'frxFileName': frxFileName, 'dataSourceType': dataSourceType});
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}