import 'package:desktop/app/ui/widget/popup_menu/popup_menu_position_delegate.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart' hide PopupMenuPosition;


///颜色选择页面
class MineColorPicker extends StatefulWidget{

  final Widget? child;
  final double? iconSize;
  final Color color;
  final ValueChanged<Color>? onChanged;
  final Size boxSize;
  final PopupMenuPosition position;
  final double verticalOffset;
  final double horizontalOffset;

  const MineColorPicker({
    super.key,
    this.child,
    this.iconSize,
    this.color = const Color(0xff000000),
    this.onChanged,
    this.boxSize = Size.zero,
    this.position = PopupMenuPosition.RIGHT,
    this.verticalOffset = 0,
    this.horizontalOffset = 4,
  });

  @override
  State<StatefulWidget> createState() => MineColorPickerState();

}

class MineColorPickerState extends State<MineColorPicker>{

  late OverlayEntry entry;

  bool onWheel = false;
  late Color pickerColor;


  @override
  void initState() {
    super.initState();
    pickerColor = widget.color;
  }

  @override
  void didUpdateWidget(covariant MineColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    Color color = widget.color;
    if (pickerColor != color){
      pickerColor = color;
    }
  }

  void removeOverlay(){
    entry.remove();
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        child: widget.child ?? Icon(
          Icons.square,
          size: widget.iconSize ?? 20,
          color: pickerColor,
        ),
        onTap: () {
          OverlayState overlayState = Overlay.of(
              context,
              debugRequiredFor: const Text('debugRequiredFor')
          );
          RenderBox box = context.findRenderObject()! as RenderBox;
          Offset target = box.localToGlobal(
            box.size.center(Offset.zero),
            ancestor: overlayState.context.findRenderObject(),
          );

          entry = OverlayEntry(builder: (BuildContext context) {
            return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: (){
                  ///关闭颜色选择器
                  removeOverlay();
                },
                child: Directionality(
                    textDirection: Directionality.of(context),
                    child: CustomSingleChildLayout(
                        delegate: PopupMenuPositionDelegate(
                          target: target,
                          boxSize: widget.boxSize,
                          verticalOffset: widget.verticalOffset,
                          horizontalOffset: widget.horizontalOffset,
                          position: widget.position,
                        ),
                        child: Material(
                          //type: MaterialType.transparency,
                          elevation: 4,
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 180, height: 180,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: ColorWheelPicker(
                              color: pickerColor,
                              wheelSquarePadding: 4,
                              wheelSquareBorderRadius: 0,
                              wheelWidth: 16,
                              shouldUpdate: true,
                              shouldRequestsFocus: true,
                              onChangeStart: (Color color){  },
                              onChangeEnd: (Color color){  },
                              onChanged: (Color color){
                                if (!mounted){
                                  return;
                                }
                                ///onWheel如果false,color是最初值原始颜色值
                                if (onWheel){
                                  overlayState.setState(() {  });
                                  setState(() {
                                    pickerColor = color;
                                    widget.onChanged?.call(color);
                                  });
                                }
                              },
                              onWheel: (bool bool){
                                onWheel = bool;
                              },
                            ),
                          ),
                        )
                    )
                )
            );
          });

          overlayState.insert(entry);
        },
      ),
    );
    /*return Material(
      child: InkWell(
        child: widget.child,
        onTap: () async{
          ///弹窗是否打开
          bool isOpen = true;
          ///是否正在提交数据
          bool isLoading = false;
          pickerColor = widget.pickerColor;

          Color? res = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext){
                return DraggableDialog(
                  caption: '颜色拾取',
                  initialWidth: 400,
                  initialHeight: 400,
                  contentPadding: const EdgeInsets.all(0),
                  content: SizedBox(
                    width: 400, height: 400,
                    child: ColorWheelPicker(
                      color: pickerColor,
                      wheelSquarePadding: 4,
                      wheelSquareBorderRadius: 0,
                      wheelWidth: 42,
                      shouldUpdate: true,
                      shouldRequestsFocus: true,
                      onChangeStart: (Color color){  },
                      onChangeEnd: (Color color){  },
                      onChanged: (Color color){
                        pickerColor = color;
                        setState(() {  });
                      },
                      onWheel: (bool bool){
                        //setState(() {  });
                      },
                    ),
                  ),
                  actions: [
                    ///【确认】按钮
                      FilledButton(
                        child: Text(
                          '确认',
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                          ),
                        ),
                        onPressed: () async {
                          if (isLoading) {
                            ToastNotification(Get.overlayContext!).warn('正在执行！');
                            return;
                          }
                          isLoading = true;

                          if (isOpen){
                            Navigator.of(dialogContext).pop(pickerColor);
                          }
                          isLoading = false;
                        },
                      ),
                    OutlinedButton(
                      child: Text(
                        '取消',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                        ),
                      ),
                      onPressed: () async {
                        if (isLoading) {
                          ToastNotification(Get.overlayContext!).warn('正在执行！');
                          return;
                        }
                        isLoading = true;

                        if (isOpen){
                          Navigator.of(dialogContext).pop(null);
                        }
                        isLoading = false;
                      },
                    ),
                  ],
                );
              }
          ).then((value) async{
            ///弹窗关闭后执行（可能会出现提交数据返回前，已经关闭弹窗的情况）
            isOpen = false;
            return value;
          });

          if (res != null){
            widget.callBack?.call(res);
          }
        },
      ),
    );*/
  }
}