
import 'dart:convert';

import 'package:basement/utils.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/ui/pages/printer_choice/printer_choice_controller.dart';
import 'package:desktop/app/ui/pages/printer_choice/printer_choice_view.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/touch_spin.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';


mixin InterfaceUtil {

  ///根据存储的数据获取数据字段列表（存储数据是 Map<String, dynamic>> 格式的）
  @Deprecated('转移到 InfoFormInterface 中，其他的同理')
  List<InfoFormModel> _getInfoFormListByStorage(List<dynamic> mapList, List<InfoFormModel> configList){
    List<InfoFormModel> infoFormList = [];

    Map<String, InfoFormModel> map = {};
    List<InfoFormModel> list = [];
    for (var element in mapList) {
      InfoFormModel model = InfoFormModel.fromJson(element);
      map.addAll({model.keyName: model});
      list.add(model);
    }
    for (var element in configList) {
      InfoFormModel model = InfoFormModel.fromJson(element.toJson());
      InfoFormModel? storageItem = map[model.keyName];
      if (storageItem != null){
        model.fromJson(storageItem.toJson());
      }
      if (element.title.contains('@')){
        model.title = element.title;
      }
      infoFormList.add(model);
    }
    if (list.isNotEmpty){
      infoFormList.sort((a, b){
        int aIndex = list.indexWhere((element) => element.keyName == a.keyName);
        int bIndex = list.indexWhere((element) => element.keyName == b.keyName);
        if (aIndex < 0 && bIndex < 0) { ///如果a和b都是负数，则按照正常顺序排序
          return 0;
        }
        else if (aIndex < 0) { ///如果a是负数而b不是，则b排在前面
          return 1;
        }
        else if (bIndex < 0) { ///如果b是负数而a不是，则a排在前面
          return -1;
        }
        else { ///如果a和b都不是负数，则按照正常顺序排序
          return aIndex.compareTo(bIndex);
        }
      });
    }

    return infoFormList;
  }
  ///根据存储的数据获取数据字段列表（存储数据是 Map<String, dynamic>> 格式的）
  List<InfoFormModel> Function(List<dynamic> mapList, List<InfoFormModel> configList) get getInfoFormListByStorage => _getInfoFormListByStorage;

  ///获取数据字段列表的分组数据
  Map<int, List<InfoFormModel>> _getInfoFormListMap(List<InfoFormModel> list) {
    Map<int, List<InfoFormModel>> map = {};
    list.forEach((element) {
      if (map.containsKey(element.groupType)){
        map[element.groupType]!.add(element);
      }
      else {
        map.addAll({element.groupType: [element]});
      }
    });
    return map;
  }
  ///获取数据字段列表的分组数据
  Map<int, List<InfoFormModel>> Function(List<InfoFormModel> list) get getInfoFormListMap => _getInfoFormListMap;



  ///根据存储的数据获取表单数据填写项的标题名称 Map（存储数据是 String 格式的）
  Map<String, String> _getFormTitleMapByStorage(String str, Map<String, String> configMap){
    Map<String, dynamic> dataMap = {};
    dataMap.addAll(configMap);
    List<String> storageKeyList = [];
    try {
      var jsonD = jsonDecode(str);
      if (jsonD is Map<String, dynamic>){
        jsonD.forEach((key, value) {
          dataMap.addAll(jsonD);
          storageKeyList.add(key);
        });
      }
    } catch (e){}
    List<String> configKeyList = [];
    configMap.forEach((key, value) {
      configKeyList.add(key);
    });
    if (storageKeyList.isNotEmpty){
      configKeyList.sort((a,b){
        int aIndex = storageKeyList.indexWhere((element) => element == a);
        int bIndex = storageKeyList.indexWhere((element) => element == b);
        if (aIndex < 0 && bIndex < 0) { ///如果a和b都是负数，则按照正常顺序排序
          return 0;
        }
        else if (aIndex < 0) { ///如果a是负数而b不是，则b排在前面
          return 1;
        }
        else if (bIndex < 0) { ///如果b是负数而a不是，则a排在前面
          return -1;
        }
        else { ///如果a和b都不是负数，则按照正常顺序排序
          return aIndex.compareTo(bIndex);
        }
      });
    }
    Map<String, String> map = {};
    configKeyList.forEach((element) {
      map.addAll({element: dataMap[element].toString()});
    });

    return map;
  }
  ///根据存储的数据获取表单数据填写项的标题名称 Map（存储数据是 String 格式的）
  Map<String, String> Function(String str, Map<String, String> configMap) get getFormTitleMapByStorage => _getFormTitleMapByStorage;

  ///根据存储的数据获取表单填写项的排序
  int _numPadCTListSortVoidCallback(Map<String, String> formTitleMap, NumPadController a, NumPadController b) {
    int aIndex = formTitleMap.keys.toList().indexWhere((element) => element == a.key);
    int bIndex = formTitleMap.keys.toList().indexWhere((element) => element == b.key);
    if (aIndex < 0 && bIndex < 0) { ///如果a和b都是负数，则按照正常顺序排序
      return 0;
    }
    else if (aIndex < 0) { ///如果a是负数而b不是，则b排在前面
      return 1;
    }
    else if (bIndex < 0) { ///如果b是负数而a不是，则a排在前面
      return -1;
    }
    else { ///如果a和b都不是负数，则按照正常顺序排序
      return aIndex.compareTo(bIndex);
    }
  }
  ///根据存储的数据获取表单填写项的排序
  int Function(Map<String, String> formTitleMap, NumPadController a, NumPadController b) get numPadCTListSortVoidCallback => _numPadCTListSortVoidCallback;

  ///根据存储的数据获取表单数据填写项的样式 Map（存储数据是 String 格式的）
  Map<String, Map<String, dynamic>> _getFormStyleMapByStorage(String str, Map<String, Map<String, dynamic>> configMap){
    Map<String, Map<String, dynamic>> dataMap = {};
    dataMap.addAll(configMap);
    try {
      var jsonD = jsonDecode(str);
      if (jsonD is Map<String, dynamic>){
        jsonD.forEach((key, value) {
          if (value is Map<String, dynamic>){
            dataMap.addAll({key: value});
          }
        });
      }
    } catch (e){}
    return dataMap;
  }
  ///根据存储的数据获取表单数据填写项的样式 Map（存储数据是 String 格式的）
  Map<String, Map<String, dynamic>> Function(String str, Map<String, Map<String, dynamic>> configMap) get getFormStyleMapByStorage => _getFormStyleMapByStorage;



  ///根据存储的数据获取按钮组列表
  List<CommandBarBtnModel> _getCommandBarListByStorage(List<dynamic> mapList, List<CommandBarBtnModel> configList) {
    List<CommandBarBtnModel> commandBarList = [];

    Map<String, CommandBarBtnModel> map = {};
    List<CommandBarBtnModel> list = [];
    for (var element in mapList) {
      CommandBarBtnModel model = CommandBarBtnModel.fromJson(element);
      map.addAll({model.keyName: model});
      list.add(model);
    }
    for (var element in configList) {
      CommandBarBtnModel model = CommandBarBtnModel.fromJson(element.toJson());
      CommandBarBtnModel? storageItem = map[model.keyName];
      if (storageItem != null){
        storageItem.btnPermissionKeyName = model.btnPermissionKeyName;
        model.fromJson(storageItem.toJson());
      }
      commandBarList.add(model);
    }
    if (list.isNotEmpty){
      commandBarList.sort((a, b){
        int aIndex = list.indexWhere((element) => element.keyName == a.keyName);
        int bIndex = list.indexWhere((element) => element.keyName == b.keyName);
        if (aIndex < 0 && bIndex < 0) { ///如果a和b都是负数，则按照正常顺序排序
          return 0;
        }
        else if (aIndex < 0) { ///如果a是负数而b不是，则b排在前面
          return 1;
        }
        else if (bIndex < 0) { ///如果b是负数而a不是，则a排在前面
          return -1;
        }
        else { ///如果a和b都不是负数，则按照正常顺序排序
          return aIndex.compareTo(bIndex);
        }
      });
    }

    return commandBarList;
  }
  ///根据存储的数据获取按钮组列表
  List<CommandBarBtnModel> Function(List<dynamic> mapList, List<CommandBarBtnModel> configList) get getCommandBarListByStorage => _getCommandBarListByStorage;



  ///根据存储的数据获取日期选择器的初始值（存储数据是 String 格式的）
  Map<String, dynamic> _getDatePickerValueMapByStorage(String str){
    Map<String, dynamic> map = {};

    try {
      var jsonD = jsonDecode(str);
      if (jsonD is Map<String, dynamic>){
        map = jsonD;
      }
    } catch (e){}

    return map;
  }
  ///根据存储的数据获取日期选择器的初始值（存储数据是 String 格式的）
  Map<String, dynamic> Function(String str) get getDatePickerValueMapByStorage => _getDatePickerValueMapByStorage;



  ///报工提交前获取打印信息
  ///
  /// {"printerUrl": "", "printerName": "", "printCopies": 1 "printType": ""}
  Future<Map<String, dynamic>> _getPrintInfo() async {
    String printerUrl = ''; ///打印机Url
    String printerName = ''; ///打印机Name
    bool usePrinterSettings = AppConfig.usePrinterSettings;
    int printCopies = 0; ///打印份数
    String printType = ''; ///打印方式
    //region 获取打印机信息 printerUrl printerName
    if (!kIsWeb && GetPlatform.isWindows){
      printerUrl = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PRINTER_URL_KEY) ?? '';
      printerName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PRINTER_NAME_KEY) ?? '';
      usePrinterSettings = ShareStorageUtil.instance?.read(SharedPreferencesKeys.USE_PRINTER_SETTINGS_KEY) ?? AppConfig.usePrinterSettings;
      if (printerUrl.isEmpty){ ///打印机选择
        Map<String, dynamic>? printerChoiceRes = await DialogUtils.showCustomDialog<PrintChoiceController, Map<String, dynamic>>(
          Get.context!,
          initialWidth: 550, initialHeight: 500,
          title: '打印机选择', onConfirmName: '确认',
          contentPadding: const EdgeInsets.all(12),
          content: const PrintChoiceView(),
          controller: PrintChoiceController(),
        );
        printerUrl = (printerChoiceRes?['printer'] as Printer?)?.url ?? '';
        printerName = (printerChoiceRes?['printer'] as Printer?)?.name ?? '';
        usePrinterSettings = printerChoiceRes?['usePrinterSettings'] ?? AppConfig.usePrinterSettings;
      }
    }
    //endregion
    printCopies = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEFAULT_PRINT_COPIES) ?? AppConfig.defaultPrintCopies;
    //region 获取打印方式  (服务端打印 serverPrint OR 本地打印 localPrint) printType
    printType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PRINT_TYPE_KEY) ?? AppConfig.printType;
    //endregion
    return {
      'printerUrl': printerUrl,
      'printerName': printerName,
      'usePrinterSettings': usePrinterSettings,
      'printCopies': printCopies,
      'printType': printType,
    };
  }
  ///报工提交前获取打印信息
  ///
  /// {"printerUrl": "", "printerName": "", "printType": ""}
  Future<Map<String, dynamic>> Function() get getPrintInfo => _getPrintInfo;



  //region 单页显示记录数设置

  ///设置控件
  Widget pageConfigRowsChoiceWidget(BuildContext context, {
    required int pageConfigRows,
    required ValueChanged<int> pageConfigRowsOnChanged,
  }){
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      title: Text(
        '单页显示记录数',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: TouchSpin(
        width: 150,
        numValue: pageConfigRows.toDouble(),
        numMin: 1,
        step: 1,
        point: 0,
        textStyle: Theme.of(context).textTheme.titleLarge,
        iconSize: Theme.of(context).textTheme.titleLarge!.fontSize! * 1.43,
        addIcon: const Icon(Icons.add_circle_outline),
        subtractIcon: const Icon(Icons.remove_circle_outline),
        canInput: false,
        numOnChanged: (double value){
          pageConfigRowsOnChanged(value.toInt());
        },
      ),
    );
  }

  //endregion

}
