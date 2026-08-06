
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';


class TouchSpin extends StatefulWidget {

  ///中间的数据是否可修改（数字型专用）
  final bool canInput;
  ///共几位小数点（数字型专用）
  final int point;
  ///中间数据的当前值（数字型专用）
  final double? numValue;
  ///中间数据的最大值（数字型专用）
  final double? numMin;
  ///中间数据的最小值（数字型专用）
  final double? numMax;
  ///点击按钮时，数据改变的差值（数字型专用）
  final double? step;
  final NumberFormat? displayFormat;
  final bool? enabled;
  final ValueChanged<double>? numOnChanged;

  final FocusNode? focusNode;
  final FocusNode? addIconFocusNode;
  final FocusNode? subtractIconFocusNode;
  ///两边的按钮外面是否包裹着Expanded
  final bool isIconExpanded;
  final double? iconSize;
  final Icon? subtractIcon;
  final Icon? addIcon;
  final EdgeInsetsGeometry? iconPadding;
  final TextStyle? textStyle;
  final Color? iconActiveColor;
  final Color? iconDisabledColor;

  final double? width;

  const TouchSpin({
    Key? key,
    this.numValue = 1,
    this.numOnChanged,
    this.numMin = 1,
    this.numMax = 9999999,
    this.step = 1,
    this.iconSize = 24.0,
    this.displayFormat,
    this.subtractIcon = const Icon(Icons.remove),
    this.addIcon = const Icon(Icons.add),
    this.iconPadding = const EdgeInsets.all(4.0),
    this.textStyle = const TextStyle(fontSize: 24),
    this.iconActiveColor,
    this.iconDisabledColor,
    this.enabled = true,
    this.focusNode,
    this.addIconFocusNode,
    this.subtractIconFocusNode,
    this.canInput = true,
    this.point = 0,
    this.isIconExpanded = false,
    this.width,
  }) : super(key: key);

  @override
  _TouchSpinState createState() => _TouchSpinState();
}

class _TouchSpinState extends State<TouchSpin> {

  //region 数字型
  late double? _value;

  bool get minusBtnDisabled =>
      _value! <= widget.numMin! ||
          _value! - widget.step! < widget.numMin! ||
          !widget.enabled!;

  bool get addBtnDisabled =>
      _value! >= widget.numMax! ||
          _value! + widget.step! > widget.numMax! ||
          !widget.enabled!;

  static TextEditingController textEditingController = TextEditingController();
  //endregion

  @override
  void initState() {
    super.initState();
    _value = widget.numValue;
    textEditingController.text = widget.displayFormat == null ? _value.toString() : widget.displayFormat!.format(_value);
  }

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;
    Widget subtractIconBtnWidget = IconButton(
      padding: widget.iconPadding!,
      iconSize: widget.iconSize!,
      color: minusBtnDisabled
          ? widget.iconDisabledColor ?? Theme.of(context).disabledColor
          : widget.iconActiveColor ?? Theme.of(context).colorScheme.primary,
      icon: widget.subtractIcon!,
      focusNode: widget.subtractIconFocusNode,
      onPressed: (){
        if (minusBtnDisabled){
          return;
        }
        double newVal = _value! - widget.step!;
        setState(() {
          _value = double.tryParse(NumFormatUtil.numPointConverter(newVal, widget.point, rounding: true));
          textEditingController.text = widget.displayFormat == null ? _value.toString() : widget.displayFormat!.format(_value);
        });
        if (widget.numOnChanged != null) widget.numOnChanged!(_value!);
        PrintUtil.printDebug(_value.toString());
      },
    );
    Widget addIconBtnWidget = IconButton(
      padding: widget.iconPadding!,
      iconSize: widget.iconSize!,
      color: addBtnDisabled
          ? widget.iconDisabledColor ?? Theme.of(context).disabledColor
          : widget.iconActiveColor ?? Theme.of(context).colorScheme.primary,
      icon: widget.addIcon!,
      focusNode: widget.addIconFocusNode,
      onPressed: (){
        if (addBtnDisabled){
          return;
        }
        double newVal = _value! + widget.step!;
        setState(() {
          _value = double.tryParse(NumFormatUtil.numPointConverter(newVal, widget.point, rounding: true));
          textEditingController.text = widget.displayFormat == null ? _value.toString() : widget.displayFormat!.format(_value);
        });
        if (widget.numOnChanged != null) widget.numOnChanged!(_value!);
        PrintUtil.printDebug(_value.toString());
      },
    );
    Widget valueWidget = Container(
      width: widget.width,
      alignment: Alignment.center,
      child: Text(
        '${widget.displayFormat ?? NumFormatUtil.numPointConverter(_value!, widget.point, rounding: true)}',
        style: widget.textStyle,
      ),
    );
    Widget inputWidget = Container(
      width: widget.width,
      alignment: Alignment.center,
      child: TextField(
        controller: textEditingController,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        style: widget.textStyle,
        onChanged: (String value){
          double? newValue = double.tryParse(value);
          ///内容错误
          if (newValue == null && value.isNotEmpty){
            ToastNotification(Get.overlayContext!).error("输入格式错误！");
            textEditingController.text = _value.toString();
            ///把光标移动到最后位置
            textEditingController.selection = TextSelection.fromPosition(
                TextPosition(
                    affinity: TextAffinity.downstream,
                    offset: textEditingController.text.length
                )
            );
          }
          ///内容为空
          else if (newValue == null && value.isEmpty){
            _value = 0;
            textEditingController.text = _value.toString();
            ///把光标移动到最后位置
            textEditingController.selection = TextSelection.fromPosition(
                TextPosition(
                    affinity: TextAffinity.downstream,
                    offset: textEditingController.text.length
                )
            );
          }
          ///大于可输入最大值
          else if (newValue != null && newValue > widget.numMax!){
            ToastNotification(Get.overlayContext!).error("大于可输入最大值！");
            _value = widget.numMax;
            textEditingController.text = _value.toString();
            ///把光标移动到最后位置
            textEditingController.selection = TextSelection.fromPosition(
                TextPosition(
                    affinity: TextAffinity.downstream,
                    offset: textEditingController.text.length
                )
            );
          }
          ///小于可输入最小值
          else if (newValue != null && newValue < widget.numMin!){
            ToastNotification(Get.overlayContext!).error("小于可输入最小值！");
            _value = widget.numMin;
            textEditingController.text = _value.toString();
            ///把光标移动到最后位置
            textEditingController.selection = TextSelection.fromPosition(
                TextPosition(
                    affinity: TextAffinity.downstream,
                    offset: textEditingController.text.length
                )
            );
          }
          ///最前面的数字为0
          else if (value.substring(0, 1) == '0'){
            _value = newValue;
            textEditingController.text = _value.toString();
            ///把光标移动到最后位置
            textEditingController.selection = TextSelection.fromPosition(
                TextPosition(
                    affinity: TextAffinity.downstream,
                    offset: textEditingController.text.length
                )
            );
          }
          else {
            _value = newValue;
          }
          if (widget.numOnChanged != null) widget.numOnChanged!(_value!);
          setState(() {});
        },
      ),
    );
    if (widget.isIconExpanded){
      contentWidget = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: subtractIconBtnWidget,
          ),
          if (widget.canInput)
            inputWidget
          else
            valueWidget,
          Expanded(
              child: addIconBtnWidget
          ),
        ],
      );
    }
    else {
      contentWidget = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          subtractIconBtnWidget,
          Visibility(
            visible: widget.canInput,
            replacement: valueWidget,
            child: inputWidget,
          ),
          addIconBtnWidget,
        ],
      );
    }

    return contentWidget;

  }
}