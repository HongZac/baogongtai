import 'package:desktop/app/model/tab_page_controller_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/base_tab/base_tab_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';


///Tab页面 基础页
mixin BaseTabInterface<T extends BaseTabController> implements BaseFormInterface{

  ///首次进入Tab页面时默认显示的选项卡页面
  final int initialIndex = AppConfig.initialIndex;

  ///tabPageList 的 controllerList
  late final List<TabPageControllerModel> tabPageControllerList = [];

  ///tabList
  final List<String> tabValueList = [];

  ///tabPageList
  final List<Widget> tabPageView = [];

}