import 'package:flutter/foundation.dart';


/// 用于 TabView 页面 （懒加载）
class TabPageControllerModel<S> {
  bool isInit;

  VoidCallback put;
  VoidCallback? tabIndexOnChanged;
  VoidCallback delete;

  TabPageControllerModel({
    this.isInit = false,
    required this.put,
    this.tabIndexOnChanged,
    required this.delete,
  });

  void controllerPut() {
    put.call();
    isInit = true;
  }

  void controllerDelete() {
    delete.call();
  }
}