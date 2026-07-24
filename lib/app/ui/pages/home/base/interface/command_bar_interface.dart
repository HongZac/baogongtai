

import 'package:basement/item_model.dart';
import 'package:basement/model.dart';
import 'package:basement/service.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/service/data_service.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_controller.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_view.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/command_bar.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///按钮组接口
mixin CommandBarInterface on GetxController {

  final _dataService = Get.find<DataService>();

  ///获取的系统对象相关属性；
  ///
  /// 基类中重写
  EditFormItem objectItem = EditFormItem();



  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {  }

  ///按钮是否显示的处理回调
  ///
  /// [True]：显示
  /// [False]：隐藏
  bool commandBarShowCallback(String keyName, ICloneable item) { return true; }


  ///[isNeedCard]、[margin]、[color]：[CommandBar]时使用
  Widget commandBarWidget(BuildContext context, {
    required List<CommandBarBtnModel> commandBarList,
    required ICloneable item,
    bool isNeedCard = false,
    EdgeInsets? margin,
    EdgeInsets? btnPadding,
    EdgeInsets? padding,
    double? width,
    Color? color,
    bool? isExpanded,
    MainAxisAlignment? commandBarMainAxisAlignment,
  }){
    final double? fontSize = Theme.of(context).textTheme.bodyLarge!.fontSize;
    final double? iconSize = Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43;
    List<CommandBarItem> primaryItems = [];
    List<Widget> btnList = [];
    commandBarList.forEach((element) {
      bool isShow = element.isShow && commandBarShowCallback(element.keyName, item);
      if (isShow){
        Color? bkgdColor;
        Color? fontColor;
        int? colorIntValue = int.tryParse(element.bkgdColorValue.toString());
        if (colorIntValue != null){
          bkgdColor = Color(colorIntValue);
        }
        else if (element.bkgdColorValue != null){
          switch (element.bkgdColorValue){
            //region
            case 'primary':
              bkgdColor = Theme.of(context).colorScheme.primary;
              fontColor = Theme.of(context).colorScheme.onPrimary;
              break;
            case 'primaryContainer':
              bkgdColor = Theme.of(context).colorScheme.primaryContainer;
              fontColor = Theme.of(context).colorScheme.onPrimaryContainer;
              break;
            case 'secondary':
              bkgdColor = Theme.of(context).colorScheme.secondary;
              fontColor = Theme.of(context).colorScheme.onSecondary;
              break;
            case 'surface':
              bkgdColor = Theme.of(context).colorScheme.surface;
              fontColor = Theme.of(context).colorScheme.onSurfaceVariant;
              break;
            case 'error':
              bkgdColor = Theme.of(context).colorScheme.error;
              fontColor = Theme.of(context).colorScheme.onError;
              break;
            case 'errorContainer':
              bkgdColor = Theme.of(context).colorScheme.errorContainer;
              fontColor = Theme.of(context).colorScheme.onErrorContainer;
              break;
            //endregion
          }
        }
        Widget childWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (element.icon != null)
              Icon(
                element.icon,
                size: iconSize,
                color: fontColor,
              ),
            if (element.icon != null)
              const SizedBox(width: 4,),
            Text(
              element.keyName.contains('-expanded')
                  ? '${isExpanded == true ? '\u00A0\u00A0收起' : '\u00A0\u00A0展开'}'
                  : element.title,
              style: TextStyle(
                fontSize: fontSize,
                color: fontColor,
                fontWeight: element.commandBarBtnType == CommandBarBtnType.text
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
            if (element.keyName.contains('-expanded'))
              AnimatedRotation(
                  turns: isExpanded == true ? 0.5 : 0,
                  duration: const Duration(milliseconds: 100),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: fontColor,
                    size: fontSize,
                  )
              ),
            if (element.keyName.contains('-expanded'))
              const SizedBox(width: 4,),
          ],
        );
        Widget spaceWidget = const SizedBox(width: 4);
        //region 按钮点击回调 + 是否有点击权限 onPressed
        Future<void> Function() onPressed = () async {
          if (element.btnPermissionKeyName != null
              && _dataService.isEnableOperatePrivilege
              && objectItem.buttons?[element.btnPermissionKeyName] == null){
            ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? '【${objectItem.progid}】【${element.btnPermissionKeyName}】' : ''}！');
            return;
          }
          await commandBarOnPressed.call(element.keyName, item);
        };
        //endregion
        switch (element.commandBarBtnType){
          case CommandBarBtnType.commandBar:
            primaryItems.add(
              CommandBarButton(
                label: element.title,
                icon: element.icon,
                fontSize: fontSize,
                iconSize: iconSize,
                onPressed: () async{
                  await onPressed.call();
                },
              )
            );
            break;
          case CommandBarBtnType.filled:
            btnList.addAll([
              FilledButton(
                onPressed: () async{
                  await onPressed.call();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(bkgdColor),
                  padding: WidgetStateProperty.all(btnPadding),
                ),
                child: childWidget,
              ),
              spaceWidget,
            ]);
            break;
          case CommandBarBtnType.outlined:
            btnList.addAll([
              OutlinedButton(
                onPressed: () async{
                  await onPressed.call();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(bkgdColor),
                  padding: WidgetStateProperty.all(btnPadding),
                ),
                child: childWidget,
              ),
              spaceWidget,
            ]);
            break;
          case CommandBarBtnType.text:
            btnList.addAll([
              TextButton(
                onPressed: () async{
                  await onPressed.call();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(bkgdColor),
                  padding: WidgetStateProperty.all(
                      btnPadding ?? (
                          kIsWeb || GetPlatform.isWindows
                              ? null
                              : const EdgeInsets.symmetric(vertical: 8, horizontal: 14))
                  ),
                ),
                child: childWidget,
              ),
              spaceWidget,
            ]);
            break;
        }
      }
    });
    if (primaryItems.isNotEmpty){
      Widget commandBar = CommandBar(
        mainAxisAlignment: commandBarMainAxisAlignment ?? MainAxisAlignment.spaceAround,
        overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
        overflowItemBuilder: (void Function()? onPressed){
          return CommandBarButton(
            label: '',
            icon: Icons.more_vert,
            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
            onPressed: onPressed,
          );
        },
        primaryItems: primaryItems,
      );
      if (isNeedCard){
        commandBar = CommandBarCard(
          color: color,
          margin: margin ?? EdgeInsets.zero,
          padding: padding ?? (kIsWeb || GetPlatform.isWindows
              ? const EdgeInsets.all(8)
              : const EdgeInsets.all(0)),
          width: width,
          child: commandBar,
        );
      }
      return commandBar;
    }
    else {
      btnList.removeLast();
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: btnList,
      );
    }
  }



  //region 设置

  ///按钮组单个项标题名称修改
  Future<void> _commandBarTitleOnChanged(CommandBarBtnModel item) async {
    var dialogRes = await DialogUtils.showCustomDialog<EditFieldController, String>(
      Get.context!,
      title: '标题名称修改',
      onConfirmName: '确认',
      barrierDismissible: false,
      initialWidth: 550, initialHeight: 260,
      contentPadding: const EdgeInsets.all(12),
      content: EditFieldView(),
      controller: EditFieldController(
          hintContent: item.title,
          initTCText: item.title,
          beforeConfirmCallback: (String str) async {
            if (str.isEmpty){
              ToastNotification(Get.overlayContext!).error('不能为空！');
              return false;
            }
            if (str.length > 5){
              ToastNotification(Get.overlayContext!).error('长度不能超过五位！');
              return false;
            }
            return true;
          }
      ),
    );
    if (dialogRes != null){
      item.title = dialogRes;
      update();
    }
  }

  ///按钮组单个项排序回调
  void _commandBarOnItemReorder({
    required int oldItemIndex,
    required int oldListIndex,
    required int newItemIndex,
    required int newListIndex,
    required List<CommandBarBtnModel> commandBarList,
  }) {
    CommandBarBtnModel item = commandBarList.removeAt(oldItemIndex);
    commandBarList.insert(newItemIndex, item);
    update();
  }

  ///按钮组单个项是否显示 选择变化
  void _commandBarIsShowOnChanged(CommandBarBtnModel item) {
    item.isShow = !item.isShow;
    update();
  }


  Widget commandBarSettingWidget(BuildContext context, List<CommandBarBtnModel> commandBarList){
    return DragAndDropLists(
      onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
        _commandBarOnItemReorder(
          oldItemIndex: oldItemIndex,
          oldListIndex: oldListIndex,
          newItemIndex: newItemIndex,
          newListIndex: newListIndex,
          commandBarList: commandBarList,
        );
      },
      onListReorder: (int oldListIndex, int newListIndex) {  },
      children: [
        DragAndDropList(
          canDrag: false,
          children: commandBarList.map((e) {
            return DragAndDropItem(
              child: SwitchListTile(
                value: e.isShow,
                onChanged: (bool boolValue){
                  _commandBarIsShowOnChanged(e);
                },
                secondary: MineIconButton(
                  icon: Icons.edit_note_outlined,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  padding: const EdgeInsets.all(8),
                  tooltip: '标题名称修改',
                  onPressed: () async {
                    await _commandBarTitleOnChanged(e);
                  },
                ),
                title: Text(
                  e.title.replaceAll('\u00A0', ' ').removeAllWhitespace,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                contentPadding: const EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 4),
              ),
            );
          }).toList(),
        )
      ],
      itemDecorationWhileDragging: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.outline.withAlpha(128),
            spreadRadius: 2,
            blurRadius: 3,
          ),
        ],
      ),
      lastItemTargetHeight: 8,
      addLastItemTargetHeightToTop: true,
      lastListTargetSize: 0,
    );
  }

  //endregion

}