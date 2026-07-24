import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/base_tab/base_tab_interface.dart';
import 'package:flutter/material.dart';


///Tab页面 基础页
abstract class BaseTabController extends BaseFormController with BaseTabInterface {

  ///是否显示“回退按钮”
  final bool isShowBackOutlinedButton;

  ///是否显示“设置按钮”
  final bool isShowSettingButton;

  late final TabController tabController = TabController(
    length: tabValueList.length,
    initialIndex: initialIndex,
    vsync: this,
  );


  BaseTabController({
    required super.progId,
    super.isShowProgressDialogInOnReady = false,
    super.isNeedGetObjectItem = false,
    this.isShowBackOutlinedButton = true,
    this.isShowSettingButton = true,
  });


  @override
  void onInit() {
    super.onInit();
    tabPageControllerList[initialIndex].controllerPut();
    Future.delayed(const Duration(milliseconds: 500), (){
      tabPageControllerList[tabController.index].tabIndexOnChanged?.call();
    });
  }

  @override
  Future<void> onReady() async {
    await super.onReady();
    tabController.addListener(() async {
      if (!tabController.indexIsChanging){ return; }
      bool isNowInit = false;
      if (!tabPageControllerList[tabController.index].isInit){
        isNowInit = true;
        tabPageControllerList[tabController.index].controllerPut();
      }
      if (isNowInit){
        await Future.delayed(const Duration(milliseconds: 500));
      }
      tabPageControllerList[tabController.index].tabIndexOnChanged?.call();
    });
  }

  @override
  void onClose() {
    for (var element in tabPageControllerList) {
      if (element.isInit){
        element.controllerDelete();
      }
    }
    tabController.dispose();
    super.onClose();
  }

}