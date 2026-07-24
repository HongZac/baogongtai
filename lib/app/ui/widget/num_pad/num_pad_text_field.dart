
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/platform/platform.dart';


///可以用数字软键盘控制的输入框
class NumPadTextField extends StatefulWidget{

  final NumPadController numPadController;
  final double? width;
  ///要和 contentPadding 一起设置
  final double? height;
  final double? maxWidth;
  final EdgeInsets? margin;
  final String? hintText;
  ///单位 (g)
  final String measurement;
  late final EdgeInsets contentPadding;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  NumPadTextField({
    super.key,
    required this.numPadController,
    this.width,
    this.height = 65,
    this.maxWidth = 400,
    this.margin,
    this.hintText,
    this.measurement = '',
    EdgeInsets? contentPadding,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    //this.autofocus = false,
  }){
    this.contentPadding = contentPadding ?? (kIsWeb || GetPlatform.isWindows
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 25)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 22));
  }

  @override
  State<StatefulWidget> createState() => NumPadTextFieldState();
}

class NumPadTextFieldState extends State<NumPadTextField>{

  @override
  void initState() {
    super.initState();
    widget.numPadController.controller.addListener(controllerListen);
    widget.numPadController.focusNode.addListener(fnListener);
  }

  void controllerListen() {  }

  void fnListener() {  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      constraints: BoxConstraints(maxWidth: widget.maxWidth ?? double.infinity),
      child: TextField(
        enabled: widget.numPadController.enabled,
        //autofocus: widget.autofocus,
        controller: widget.numPadController.controller,
        focusNode: widget.numPadController.focusNode,
        keyboardType: widget.numPadController.keyboardType,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: widget.numPadController.isDataByWeightMsg || (widget.numPadController.styleMap[AppConfig.isHighlight] as bool?) == true
              ? AppColors.errorColor
              : null,
          fontWeight: widget.numPadController.isDataByWeightMsg || (widget.numPadController.styleMap[AppConfig.isHighlight] as bool?) == true
              ? FontWeight.w600
              : null,
          fontSize: widget.numPadController.isDataByWeightMsg || (widget.numPadController.styleMap[AppConfig.isHighlight] as bool?) == true
              ? Theme.of(context).textTheme.headlineMedium!.fontSize
              : null,
        ),
        maxLines: 1,
        onTap: (){
          widget.numPadController.controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: widget.numPadController.controller.text.length,
          );
        },
        onChanged: (String value){
          widget.numPadController.isDataByWeightMsg = false;
          widget.onChanged?.call(value);
        },
        decoration: InputDecoration(
          fillColor: widget.numPadController.enabled
              ? null
              : Theme.of(context).disabledColor,
          hintText: widget.hintText,
          hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
              fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
          ),
          contentPadding: widget.contentPadding,
          prefixIcon: widget.prefixIcon,
          prefixIconConstraints: BoxConstraints(
            minWidth: widget.prefixIcon == null
                ? 0
                : 39,
          ),
          suffixIcon: widget.suffixIcon ?? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.measurement,
              style: Theme.of(context).textTheme.bodyLarge,
            )
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: widget.suffixIcon == null && widget.measurement.isEmpty
                ? 0
                : 39,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.numPadController.controller.removeListener(controllerListen);
    widget.numPadController.focusNode.removeListener(fnListener);
    super.dispose();
  }

}