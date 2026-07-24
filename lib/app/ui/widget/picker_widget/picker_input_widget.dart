import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

typedef CustomContentBuilder = String Function(PickerDataModel item);
typedef ProcessItemAttachBuilder = Future<void>Function(MoWorkBillEntryModel item, MoRoutingEntryModel? routingEntryModel);


///弹窗选择器
class PickerInputWidget extends StatefulWidget{

  final bool isReadOnly;
  final ValueChanged<List<PickerDataModel>>? onTap;
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
  final CustomContentBuilder? customContent;
  final int maxLines;

  final IPickerAdapter<PickerDataModel>? adapter;
  final PickerChoiceType pickerChoiceType;

  ///查看工序的技术指导书 函数回调
  final ProcessItemAttachBuilder? processItemAttach;
  ///工序选单页面的岗位筛选 函数回调
  final AsyncValueSetter<List<PickerDataModel>>? processPostOnChanged;

  const PickerInputWidget({
    super.key,
    this.isReadOnly = false,
    this.onTap,
    this.width,
    this.height = 65,
    this.maxWidth = 400,
    this.margin,
    this.hint = '',
    this.hintTextStyle,
    this.textStyle,
    this.suffixIcon = Icons.arrow_drop_down, //my_library_books_outlined,
    this.suffixIconSize,
    this.suffixIconColor,
    this.adapter,
    this.pickerChoiceType = PickerChoiceType.checkboxListTile,
    this.customContent,
    this.maxLines = 1,
    this.processItemAttach,
    this.processPostOnChanged,
  });

  @override
  State<StatefulWidget> createState() => PickerInputWidgetState();
}

class PickerInputWidgetState extends State<PickerInputWidget>{

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

  final BoxDecoration _disabledInputDecoration = BoxDecoration(
    color: Theme.of(Get.context!).disabledColor,
    border: Border.all(
        color: Theme.of(Get.context!).colorScheme.onSurface.withAlpha(97),
        width: 1
    ),
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

  List<PickerDataModel> selectList = [];

  bool isFirstLoading = true;
  bool isOnPressed = false;


  @override
  void initState() {
    super.initState();
    if (widget.adapter != null){
      selectList = widget.adapter!.dataList.where((element) => element.isSelected).toList();
      isFirstLoading = false;
    }
  }

  @override
  void didUpdateWidget(covariant PickerInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.adapter != null){
      selectList = widget.adapter!.dataList.where((element) => element.isSelected).toList();
      isFirstLoading = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: widget.isReadOnly
          ? _disabledInputDecoration.color
          : isMouseEnter
          ? _hoveredInputDecoration.color
          : _inputDecoration.color,
      shape: RoundedRectangleBorder(
        side: widget.isReadOnly
            ? (_disabledInputDecoration.border?.bottom ?? BorderSide.none)
            : isMouseEnter
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
          onTap: () async{
            await onPressed();
          },
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
                  child: (widget.adapter == null || isLoadData)
                      ? loadWidget()
                      : selectList.isEmpty
                      ? hintWidget()
                      : textWidget(),
                ),
                AnimatedRotation(
                  turns: selectionMode ? 0.5 : 0,
                  duration: const Duration(milliseconds: 100),
                  child: Icon(
                    widget.suffixIcon,
                    size: widget.suffixIconSize ?? Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    color: widget.suffixIconColor ?? Theme.of(context).inputDecorationTheme.iconColor,
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loadWidget() {
    return Row(
      children: [
        SizedBox(
            width: 30,
            child: SpinKitCircle(
              color: widget.textStyle?.color ?? Colors.grey,
              size: widget.textStyle?.fontSize == null ? 18 : widget.textStyle!.fontSize! * 1.3,
            )
        ),
        Expanded(
            child: Text(
              '数据源加载中...',
              style: effectiveDecoration.hintStyle,
              maxLines: 1, overflow: TextOverflow.ellipsis,
            )
        )
      ],
    );
  }

  Widget hintWidget() {
    return Text(
        widget.hint,
        style: widget.hintTextStyle
            ?? effectiveDecoration.hintStyle?.copyWith(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              color: Theme.of(context).hintColor
            )
    );
  }

  Widget textWidget() {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        interactive: false,
        thumbVisibility: WidgetStateProperty.all(false),
        trackVisibility: WidgetStateProperty.all(false),
        thumbColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: Text(
        selectList.map((e) => widget.customContent?.call(e) ?? e.name).join(','),
        style: widget.textStyle ?? Theme.of(context).textTheme.bodyLarge,
        maxLines: widget.maxLines,
        /*onTap: () async {
          await onPressed();
        },*/
      ),
    );
  }

  Future<void> onPressed() async{
    if (isOnPressed || widget.isReadOnly || widget.adapter == null){
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
        openPicker(widget.adapter!, widget.processItemAttach, widget.processPostOnChanged);
      });
    }
    else {
      openPicker(widget.adapter!, widget.processItemAttach, widget.processPostOnChanged);
    }
    isOnPressed = false;
  }

  void openPicker(
      IPickerAdapter<PickerDataModel> adapter,
      ProcessItemAttachBuilder? processItemAttach,
      AsyncValueSetter<List<PickerDataModel>>? processPostOnChanged){
    Picker(
      adapter: adapter,
      processItemAttach: processItemAttach,
      processPostOnChanged: processPostOnChanged
    ).showPickerDialog(Get.context!, pickerChoiceType: widget.pickerChoiceType).then((value) {
      if (value == null){
        return;
      }
      widget.onTap?.call(value);
      setState(() {  });
    });
  }


  @override
  void dispose() {
    super.dispose();
  }
}
