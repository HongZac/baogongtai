import 'package:basement/utils.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid_button/flutter_grid_button.dart';
import 'package:get/get.dart';


///数字键盘输入后的界面回调函数
///
///val：当前按键值
///
///keyName：onPressed后的input对象key值
///
///text：onPressed处理后的input对象text值
typedef OnPressed = void Function(String val, String keyName, String text);


///数字软键盘
class NumPad extends StatefulWidget{

  final List<NumPadController> nPCList;
  final OnPressed? onPressed;
  final double width;
  final double height;

  ///进入页面后，程序会延迟10毫秒，然后将焦点自动设置到指定的输入框上
  final String defaultNumPadKey;

  const NumPad({
    super.key,
    required this.nPCList,
    this.onPressed,
    this.width = 340,
    this.height = 340,
    this.defaultNumPadKey = '',
  });

  @override
  State<StatefulWidget> createState() => NumPadState();
}

class NumPadState extends State<NumPad>{

  ///当前激活的焦点输入框
  String activeTextCtlKey = '';

  @override
  void initState() {
    super.initState();

    ///关联焦点获取事件
    for (var element in widget.nPCList) {
      element.onFocusChange = _onFocusChange;
    }

    Future.delayed(const Duration(milliseconds: 10), (){
      if (widget.defaultNumPadKey.isNotEmpty){
        ///执行到这一步时，软键盘的焦点已经在指定输入框上了；
        ///后面的代码注释掉是为了不跟扫码监听冲突（2025.4.15 扫码监听可以用串口模式，取消注释）
        activeTextCtlKey = widget.defaultNumPadKey;
        FocusManager.instance.primaryFocus?.unfocus();
        NumPadController? numPadController = NumPadUtil().getNumPadController(widget.defaultNumPadKey, widget.nPCList);
        if (numPadController != null){
          FocusScope.of(context).requestFocus(numPadController.focusNode);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width, height: widget.height,
      alignment: Alignment.center,
      child: GridButton(
        onPressed: onPressed,
        items: [
          //region
          [
            textItem(title: '7', ),
            textItem(title: '8', ),
            textItem(title: '9', ),
            iconItem(iconData: FluentIcons.backspace_24_filled, value: 'backSpace'), ///回退
          ],
          [
            textItem(title: '4', ),
            textItem(title: '5', ),
            textItem(title: '6', ),
            iconItem(iconData: FluentIcons.delete_24_filled, value: 'clear'), ///清空
          ],
          [
            textItem(title: '1', ),
            textItem(title: '2', ),
            textItem(title: '3', ),
            textItem(title: '.', ),
          ],
          [
            textItem(title: '0'),
            textItem(title: 'Next', flex: 3, value: 'next'), ///下一个
          ],
          //endregion
        ],
      )
    );
  }

  GridButtonItem textItem({required String title, int flex = 1, String? value}){
    return GridButtonItem(
      title: title,
      textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.onSurface,
      ),
      flex: flex,
      value: value ?? title,
      color: Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).colorScheme.onPrimaryContainer
          : Theme.of(context).colorScheme.onInverseSurface
    );
  }

  GridButtonItem iconItem({required IconData iconData, int flex = 1, required String value}){
    return GridButtonItem(
      child: Icon(
        iconData,
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.onSurface,
        size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
      ),
      value: value,
      flex: flex,
        color: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onInverseSurface
    );
  }

  void onPressed(dynamic value){
    NumPadController? nowNumPadController = NumPadUtil().getNumPadController(activeTextCtlKey, widget.nPCList);
    if (nowNumPadController == null){
      ToastNotification(Get.overlayContext!).warn("请选中要修改输入框！");
      return;
    }
    bool? enabled = NumPadUtil().getEnabled(activeTextCtlKey, widget.nPCList);
    if (!enabled! && value != 'next'){
      ToastNotification(Get.overlayContext!).warn("该输入框（${nowNumPadController.zhName}）不能修改，请重新选择！");
      return;
    }
    TextEditingController nowTextEditingController = nowNumPadController.controller;
    ///重新获取焦点，点击数字键，焦点可能会转移
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(Get.context!).requestFocus(nowNumPadController.focusNode);
    switch (value){
      //region
      case 'backSpace':
        //region 回退
        String current = nowTextEditingController.text;
        if (current.length == 1){
          current = '';
        }
        else if (current.length > 1){
          current = current.substring(0, current.length - 1);
        }
        nowTextEditingController.text = current;
        nowTextEditingController.selection = TextSelection.fromPosition(TextPosition(offset: (current).length));
        //endregion
        break;
      case 'clear':
        //region 清空
        nowTextEditingController.text = '';
        //endregion
        break;
      case 'next':
        //region 下一个
        Future.delayed(const Duration(milliseconds: 10), (){
          FocusManager.instance.primaryFocus?.unfocus();
          FocusNode? nextFN = NumPadUtil().getNextFocusNode(activeTextCtlKey, widget.nPCList);
          if (nextFN != null){
            PrintUtil.printDebug(nextFN.debugLabel ?? '');
            FocusScope.of(context).requestFocus(nextFN);
          }
        });
        //endregion
        break;
      case '.':
        //region 小数点
        if (nowTextEditingController.text.contains('.')){
          ToastNotification(Get.overlayContext!).warn("该输入框（${nowNumPadController.zhName}）已有小数点！");
          return;
        }
        String current = nowTextEditingController.text + value.toString();
        nowTextEditingController.text = current;
        nowTextEditingController.selection = TextSelection.fromPosition(TextPosition(offset: (current).length));
        //endregion
        break;
      default:
        //region 其他数字型
        String current = nowTextEditingController.text + value.toString();
        nowTextEditingController.text = current;
        ///把光标移动到最后位置
        nowTextEditingController.selection = TextSelection.fromPosition(TextPosition(offset: (current).length));
        //endregion
        break;
      //endregion
    }
    ///回调函数
    widget.onPressed?.call(value.toString(), nowNumPadController.key, nowTextEditingController.text);
  }


  ///焦点切换事件
  void _onFocusChange(String key, bool focused){
    //PrintUtil.printDebug('_onFocusChange:focused $key $focused');
    if(focused){
      activeTextCtlKey = key;
    }
  }

}