import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///返回按钮（仅适用于 Desktop2）
class BackOutlinedButton extends StatefulWidget{

  final VoidCallback? onPressed;
  
  const BackOutlinedButton({super.key, this.onPressed, });

  @override
  BackOutlinedButtonState createState() => BackOutlinedButtonState();
}

class BackOutlinedButtonState extends State<BackOutlinedButton>{
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () async{
            if (widget.onPressed != null){
              widget.onPressed!.call();
              return;
            }
            if (Get.rootDelegate.currentConfiguration != null){
              await Future.doWhile(() async{
                await Get.rootDelegate.popRoute();
                var page = Get.rootDelegate.history.last;
                if (page.currentPage?.binding == null){
                  return true;
                }
                return false;
              });
            }
            else {
              Navigator.of(context).pop(null);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FluentIcons.arrow_circle_left_12_regular,
                color: IconTheme.of(context).color,
                size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
              ),
              const SizedBox(width: 4,),
              Text(
                '返回'.tr,
                style: Theme.of(context).textTheme.bodyLarge,
              )
            ],
          ),
        ),
      ],
    );
  }
}