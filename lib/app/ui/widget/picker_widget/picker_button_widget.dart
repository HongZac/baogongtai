import 'package:basement/picker.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

///按钮的类型
enum PickerButtonType{
  filled,
  text,
  inkWell,
}

class PickerButtonWidget extends StatefulWidget{

  final PickerButtonType pickerButtonType;
  final ButtonStyle? buttonStyle;
  final Widget child;
  final IPickerAdapter<PickerDataModel>? adapter;
  final PickerChoiceType pickerChoiceType;
  ///选单之后点确认，回调此函数,用来调整相关的字段值改变
  final ShowPickerCallback<PickerDataModel>? callback;
  final ValueChanged<List<PickerDataModel>>? onTap;
  final bool isNeedLoadStr;

  const PickerButtonWidget({
    super.key,
    this.pickerButtonType = PickerButtonType.filled,
    this.buttonStyle,
    required this.child,
    this.adapter,
    this.pickerChoiceType = PickerChoiceType.checkboxListTile,
    this.callback,
    this.onTap,
    this.isNeedLoadStr = true,
  });

  @override
  State<StatefulWidget> createState() => PickerButtonWidgetState();

}

class PickerButtonWidgetState extends State<PickerButtonWidget>{

  final effectiveDecoration = const InputDecoration().applyDefaults(Theme.of(Get.context!).inputDecorationTheme);

  ///是否正在刷新数据
  bool isLoadData = false;
  bool isFirstLoading = true;
  bool isOnPressed = false;

  @override
  void initState() {
    super.initState();
    if (widget.adapter != null){
      isFirstLoading = false;
    }
  }

  @override
  void didUpdateWidget(covariant PickerButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.adapter != null){
      isFirstLoading = false;
    }
  }


  Widget loadWidget() {
    if (!widget.isNeedLoadStr){
      return SizedBox(
          width: 30,
          child: SpinKitCircle(
            color: Colors.grey,
            size: 18,
          )
      );
    }
    return SizedBox(
      width: 160,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
              width: 30,
              child: SpinKitCircle(
                color: Colors.grey,
                size: 18,
              )
          ),
          Expanded(
              child: Text(
                '数据源加载中...',
                style: TextStyle(
                  fontSize: 16,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              )
          )
        ],
      )
    );
  }

  Widget build(BuildContext context) {
    switch (widget.pickerButtonType){
      case PickerButtonType.text:
        return TextButton(
          onPressed: () async{
            await onPressed();
          },
          style: widget.buttonStyle,
          child: (widget.adapter == null || isLoadData)
              ? loadWidget() : widget.child,
        );
      case PickerButtonType.inkWell:
        return InkWell(
          onTap: () async{
            await onPressed();
          },
          child: (widget.adapter == null || isLoadData)
              ? loadWidget() : widget.child,
        );
      case PickerButtonType.filled:
      default:
        return FilledButton(
          onPressed: () async{
            await onPressed();
          },
          style: widget.buttonStyle,
          child: (widget.adapter == null || isLoadData)
              ? loadWidget() : widget.child,
        );
    }
  }

  Future<void> onPressed() async{
    if (isOnPressed || widget.adapter == null){
      return;
    }
    isOnPressed = true;
    if (!widget.adapter!.isRefresh){
      isLoadData = true;
      setState(() {  });
      await widget.adapter!.loadData().then((value) {
        //region 执行[loadData]前，可能已经获取了初始选中值，此时，再执行[loadData]，会出现重复项，这里需要把最后的重复项删除
        Set<String> dataSet = {};
        List<PickerDataModel> dataList = [];
        dataList.addAll(widget.adapter!.dataList);
        dataList.forEach((element) {
          if (!dataSet.contains(element.id)){
            dataSet.add(element.id);
          }
          else {
            widget.adapter!.dataList.remove(element);
          }
        });
        Set<String> visibleSet = {};
        List<PickerDataModel> visibleItems = [];
        visibleItems.addAll(widget.adapter!.visibleItems);
        visibleItems.forEach((element) {
          if (!visibleSet.contains(element.id)){
            visibleSet.add(element.id);
          }
          else {
            widget.adapter!.visibleItems.remove(element);
          }
        });
        widget.adapter!.totalRecords = widget.adapter!.dataList.length;
        //endregion
        isLoadData = false;
        setState(() {  });
        openPicker(widget.adapter!);
      });
    }
    else {
      openPicker(widget.adapter!);
    }
    isOnPressed = false;
  }

  void openPicker(IPickerAdapter<PickerDataModel> adapter){
    Picker(
      adapter: adapter
    ).showPickerDialog(Get.context!, pickerChoiceType: widget.pickerChoiceType).then((value){
      if (value == null){
        return;
      }
      widget.onTap?.call(value);
      setState(() {  });
    });
  }

}