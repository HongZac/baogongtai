
import 'package:basement/picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///空白的 PickerDataModel 内容框（PickerDataModel的数据只能从外部赋值）
class InputWidget<T extends PickerDataModel> extends StatefulWidget{

  final double? width;
  final double? height;
  final double? maxWidth;
  final EdgeInsets? margin;
  final String hint;
  final TextStyle? hintTextStyle;
  final TextStyle? textStyle;
  final IconData suffixIcon;
  final double? suffixIconSize;
  final Color? suffixIconColor;
  final List<T> dataList;


  const InputWidget({
    super.key,
    this.width,
    this.height = 65,
    this.maxWidth = 400,
    this.margin,
    this.hint = '',
    this.hintTextStyle,
    this.textStyle,
    this.suffixIcon = Icons.qr_code_outlined,
    this.suffixIconSize,
    this.suffixIconColor,
    this.dataList = const [],
  });

  @override
  State<StatefulWidget> createState() => InputWidgetState<T>();
}

class InputWidgetState<T extends PickerDataModel> extends State<InputWidget>{

  final BoxDecoration _inputDecoration = BoxDecoration(
    color: Theme.of(Get.context!).inputDecorationTheme.filled
        ? Theme.of(Get.context!).inputDecorationTheme.fillColor
        : Colors.transparent,
    border: Border.all(
        color: Theme.of(Get.context!).colorScheme.onSurfaceVariant, //M2: onSurfaceVariant.withAlpha(153)
        width: 1
    ),
    borderRadius: BorderRadius.circular(4),
  );

  final BoxDecoration _hoveredInputDecoration = BoxDecoration(
    border: Border.all(
        color: Theme.of(Get.context!).colorScheme.onSurface,
        width: 1
    ),
    borderRadius: BorderRadius.circular(4),
  );
  final effectiveDecoration = const InputDecoration().applyDefaults(Theme.of(Get.context!).inputDecorationTheme);

  bool isMouseEnter = false;
  bool selectionMode = false;

  ///是否正在加载数据
  bool isLoadData = false;

  bool isFirstLoading = true;
  bool isOnPressed = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant InputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: isMouseEnter
          ? _hoveredInputDecoration.color
          : _inputDecoration.color,
      shape: RoundedRectangleBorder(
        side: isMouseEnter
            ? (_hoveredInputDecoration.border?.bottom ?? BorderSide.none)
            : (_inputDecoration.border?.bottom ?? BorderSide.none),
        borderRadius: _inputDecoration.borderRadius ?? BorderRadius.circular(4),
      ),
      child: MouseRegion(
        //region onEnter onExit
        onEnter: (PointerEnterEvent pointerEnterEvent){
          isMouseEnter = true;
          setState(() {  });
        },
        onExit: (PointerExitEvent pointerExitEvent){
          isMouseEnter = false;
          setState(() {  });
        },
        //endregion
        child: GestureDetector(
          onTap: () async{  },
          child: Container(
            margin: widget.margin,
            padding: const EdgeInsets.only(left: 8, right: 4, top: 4, bottom: 4),
            width: widget.width,
            height: widget.height,
            constraints: BoxConstraints(maxWidth: widget.maxWidth ?? double.infinity),
            decoration: _inputDecoration.copyWith(
              color: isMouseEnter ? Theme.of(context).inputDecorationTheme.hoverColor : Colors.transparent,
              border: Border.all(color: Colors.transparent)
            ),
            child: Row(
              children: [
                Expanded(
                  child: widget.dataList.isEmpty
                      ? hintWidget()
                      : textWidget(),
                ),
                Icon(
                  widget.suffixIcon,
                  size: widget.suffixIconSize ?? Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  color: widget.suffixIconColor ?? Theme.of(context).inputDecorationTheme.iconColor,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget hintWidget() {
    return Text(
        widget.hint,
        style: widget.hintTextStyle
            ?? effectiveDecoration.hintStyle?.copyWith(fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,)
    );
  }

  Widget textWidget() {
    return Text(widget.dataList.map((e) => e.name).join(','), style: widget.textStyle ?? Theme.of(context).textTheme.bodyLarge,);
  }


  @override
  void dispose() {
    super.dispose();
  }
}
