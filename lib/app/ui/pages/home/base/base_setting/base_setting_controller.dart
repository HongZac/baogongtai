import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_interface.dart';
import 'package:flutter/material.dart';


///设置页面 基础页
abstract class BaseSettingController extends BaseFormController with BaseSettingInterface {

  ///是否显示头部组件
  final bool isShowHeadWidget;
  ///是否显示“回退按钮”
  final bool isShowBackOutlinedButton;


  final Map<String, int> tabIndexMap = {};
  String currentTabKey = '';
  int currentTabIndex = -1;

  final ScrollController leftScrollController = ScrollController();


  BaseSettingController({
    required super.progId,
    super.isShowProgressDialogInOnReady = true,
    super.isNeedGetObjectItem = false,
    this.isShowBackOutlinedButton = true,
    this.isShowHeadWidget = true,
  });

  @override
  void onInit() {
    super.onInit();
    tabIndexMap.addAll(getTabIndexMap(tabValueList));
    currentTabKey = tabIndexMap.keys.first;
    currentTabIndex = 0;
  }


  Map<String, int> getTabIndexMap(List<ChoiceChipModel> tabValueList){
    Map<String, int> map = {};
    for (int index = 0; index < tabValueList.length; index ++){
      ChoiceChipModel element = tabValueList[index];
      if (element.children.isEmpty){
        map.addAll({element.keyName: index});
      }
      else {
        map.addAll(getTabIndexMap(element.children));
      }
    }
    return map;
  }

  void _tabOnChanged(ChoiceChipModel item){
    if (item.children.isEmpty){
      currentTabKey = item.keyName;
      currentTabIndex = tabIndexMap.keys.toList().indexWhere((element) => element == item.keyName);
    }
    else {
      item.isOpen = !item.isOpen;
    }
    update();
  }
  Function(ChoiceChipModel item) get tabOnChanged => _tabOnChanged;


  @override
  void onClose() {
    leftScrollController.dispose();
    super.onClose();
  }

}