
import 'package:flutter/material.dart';

class TextEditingControllerKeyModel {

  String keyName;
  TCType tCType;
  TextEditingController tC;
  FocusNode fn;

  TextEditingControllerKeyModel({
    required this.keyName,
    this.tCType = TCType.text,
    required this.tC,
    required this.fn,
  });
}

enum TCType{
  double,
  text,
}
