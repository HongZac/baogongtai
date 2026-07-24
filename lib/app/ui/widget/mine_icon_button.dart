import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///图标按钮（默认关闭按钮）
class MineIconButton extends StatefulWidget{
  final VoidCallback? onPressed;
  final ValueChanged<BuildContext>? onPressedDialog;
  final IconData icon;
  late final double iconSize;
  final Color? iconColor;
  final OutlinedBorder? shape;
  final String tooltip;
  ///是否可点击
  final bool clickable;
  final EdgeInsets padding;
  final bool isNeedBadges;
  final Widget? badgesWidget;
  ///clickable = true 时使用
  final EdgeInsets? margin;
  final bool preferBelow;

  MineIconButton({
    Key? key,
    this.onPressed,
    this.onPressedDialog,
    this.icon = Icons.close,
    this.tooltip = '关闭',
    this.iconColor,
    double? iconSize,
    this.shape, //const CircleBorder(),
    this.clickable = true,
    this.padding = const EdgeInsets.all(4),
    this.isNeedBadges = false,
    this.badgesWidget,
    this.margin,
    this.preferBelow = true,
  }){
    this.iconSize = iconSize ?? (kIsWeb || GetPlatform.isWindows ? 16 : 22);
  }

  @override
  MineIconButtonState createState() => MineIconButtonState();
}

class MineIconButtonState extends State<MineIconButton>{
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.clickable,
      replacement: Padding(
          padding: widget.padding,
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: widget.iconColor ?? IconTheme.of(context).color,
          )
      ),
      child: Tooltip(
        preferBelow: widget.preferBelow,
        message: widget.tooltip,
        child: Padding(
          padding: widget.margin ?? EdgeInsets.zero,
          child: TextButton(
              style: ButtonStyle(
                alignment: Alignment.center,
                shape: WidgetStateProperty.all(widget.shape),
              ),
              onPressed: (){
                if (widget.onPressed != null){
                  widget.onPressed!.call();
                  return;
                }
                else if (widget.onPressedDialog != null){
                  widget.onPressedDialog!.call(context);
                  return;
                }

                if (Get.rootDelegate.currentConfiguration != null){
                  Get.rootDelegate.popRoute();
                }
                else {
                  Navigator.of(context).pop(null);
                }
              },
              child: Padding(
                padding: widget.padding,
                child: widget.isNeedBadges ? Badge(
                  label: widget.badgesWidget,
                  child: Icon(
                    widget.icon,
                    size: widget.iconSize,
                    color: widget.iconColor ?? IconTheme.of(context).color,
                  ),
                ) :
                Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: widget.iconColor ?? IconTheme.of(context).color,
                ),
              )
          ),
        )
      ),
    );
  }

}