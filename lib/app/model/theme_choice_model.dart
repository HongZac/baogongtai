import 'package:flutter/material.dart';

class ThemeChoiceModel {
  String keyName;
  bool isSelected;
  ThemeMode themeMode;
  String title;

  ThemeChoiceModel({
    required this.keyName,
    this.isSelected = false,
    required this.themeMode,
    required this.title
  });
}