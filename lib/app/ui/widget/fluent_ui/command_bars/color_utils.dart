import 'package:desktop/app/ui/widget/fluent_ui/mine_hover_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorUtils{
  static Color getUnCheckedInputColor(
      Set<ButtonStates> states,
      {bool transparentWhenNone = false,
    bool transparentWhenDisabled = false,}){
    //if (states.isDisabled) {
    //  if (transparentWhenDisabled) return Colors.white;
    //  return Colors.yellow;
    //}
    //if (states.isPressing) return Colors.orange;
    //if (states.isHovering) return Colors.green;
    //return transparentWhenNone ? Colors.cyanAccent : Colors.purple;
    if (states.isPressing){
      return Theme.of(Get.context!).focusColor;
    }
    else if (states.isHovering) {
      return Theme.of(Get.context!).hoverColor;
    }
    else {
      return Colors.transparent;
    }
  }
}