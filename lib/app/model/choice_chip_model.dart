import 'package:flutter/material.dart';


class ChoiceChipModel {
  int sign;
  String keyName;
  @Deprecated('弃用')
  bool isSelected;
  IconData? icon;
  String title;
  String content;
  Color activeColor;
  Color disabledColor;
  Color foreColor;
  Color importFontColor;
  final List<ChoiceChipModel> children;
  bool isOpen = false;

  ChoiceChipModel({
    this.sign = -2,
    this.keyName = '',
    this.isSelected = false,
    this.icon,
    this.title = '',
    this.content = '',
    this.activeColor = Colors.black12,
    this.disabledColor = Colors.black12,
    this.foreColor = Colors.white,
    this.importFontColor = Colors.black12,
    this.children = const [],
    this.isOpen = false,
  });

}