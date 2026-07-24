
import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/service/data_service.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_controller.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_view.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef CustomBuilder = Map<String, dynamic>? Function(String keyName, ICloneable item);

///数据字段显示接口
mixin InfoFormInterface on GetxController {

  final _dataService = Get.find<DataService>();


  ///需要重写
  Future<void> infoItemOnTap(ICloneable item) async{  }

  Widget infoItem(BuildContext context, {
    required String title,
    required String content,
    Color? contentColor,
    int? width,
    double titleWidth = 100,
    bool isBold = false,
    AsyncValueSetter<ICloneable>? widgetInfoItemOnTap,
    ICloneable? item,
  }) {
    width ??= 320;
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: width.toDouble(),
      titleWidth: titleWidth,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      contentStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: contentColor,
        fontWeight: isBold ? FontWeight.w600 : null
      ),
      onPress: () async {
        if (item != null){
          if (widgetInfoItemOnTap != null){
            await widgetInfoItemOnTap.call(item);
          }
          else {
            await infoItemOnTap.call(item);
          }
        }
      },
    );
  }


  List<Widget> getFieldList(BuildContext context, {
    required List<InfoFormModel> infoFormList,
    required ICloneable item,
    CustomBuilder? customBuilder,
    AsyncValueSetter<ICloneable>? widgetInfoItemOnTap,
    bool isMaterialReject = false,
  }){
    List<Widget> list = [];

    infoFormList.forEach((element) {
      Map<String, dynamic> jsonData = item.toJson();
      bool isShow = element.isShow;
      String title = isMaterialReject
          && !element.title.contains('@') && element.title.contains('次品')
          ? element.title.replaceAll('次品', '不良品')
          : element.title;
      if (element.title.contains('@')){
        ///是自定义项
        if (element.keyName.startsWith('Free')){
          /// Free 自由项要用 IsFree 来控制
          isShow = isShow && jsonData['Is${element.keyName}'] == 1;
          title = _dataService.userDefMap[element.keyName]?.defCaption ?? '';
        }
        else if (element.keyName.startsWith('OrderDefine')){
          /// OrderDefine 自定义项对应任务单的 Define
          String keyName = element.keyName.replaceAll('Order', '');
          isShow = isShow && _dataService.userDefMap[keyName] != null;
          title = _dataService.userDefMap[keyName]?.defCaption ?? '';
        }
        else {
          isShow = isShow && _dataService.userDefMap[element.keyName] != null;
          title = _dataService.userDefMap[element.keyName]?.defCaption ?? '';
        }
      }
      if (isShow){
        String content = _getInfoFormContent(jsonData[element.keyName]);
        Color? color = element.isHighlight ? AppColors.errorColor : null;
        bool isBold = element.isHighlight;
        Map<String, dynamic>? customMap = customBuilder?.call(element.keyName, item);
        if (customMap != null){
          content = customMap['content'] ?? content;
          if (customMap.containsKey('color')){
            color = customMap['color'];
          }
          if (customMap.containsKey('isBold')){
            isBold = customMap['isBold'];
          }
        }
        list.add(
          infoItem(
            context,
            title: title,
            content: content,
            contentColor: color,
            width: element.width,
            isBold: isBold,
            widgetInfoItemOnTap: widgetInfoItemOnTap,
            item: item,
          )
        );
      }
    });

    return list;
  }

  ///获取显示在前台的数据
  String _getInfoFormContent(dynamic data) {
    String content = '';
    if (data is DateTime){
      content = DateUtil.getDateStrByDateTime(
          data,
          format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':'
      ) ?? '';
    }
    else if (data is num){
      int decimal = 0;
      if (data != data.toInt()){
        String str = data.toString();
        decimal = str.split('.')[1].length;
      }
      content = NumFormatUtil.qtyFormatConverter(data.toString(), decimal: decimal);
    }
    else {
      content = data?.toString() ?? '';
    }
    return content;
  }
  ///获取显示在前台的数据
  String Function(dynamic data) get getInfoFormContent => _getInfoFormContent;



  //region 设置

  ///列表视图字段 标题名称修改
  Future<void> _infoFormTitleOnChanged(InfoFormModel item) async {
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

  ///列表视图字段 宽度修改
  Future<void> _infoFormWidthOnChanged(InfoFormModel item) async {
    var dialogRes = await DialogUtils.showCustomDialog<EditFieldController, String>(
      Get.context!,
      title: '宽度修改',
      onConfirmName: '确认',
      barrierDismissible: false,
      initialWidth: 550, initialHeight: 260,
      contentPadding: const EdgeInsets.all(12),
      content: EditFieldView(),
      controller: EditFieldController(
          hintContent: item.width.toString(),
          initTCText: item.width.toString(),
          beforeConfirmCallback: (String str) async {
            if (str.isEmpty && int.tryParse(str) == null){
              ToastNotification(Get.overlayContext!).error('宽度值输入有误！');
              return false;
            }
            return true;
          }
      ),
    );
    if (dialogRes != null){
      item.width = int.tryParse(dialogRes) ?? 0;
      update();
    }
  }

  ///列表组视图字段 排序回调（有多个组时）
  void _infoFormGroupOnItemReorder({
    required int oldItemIndex, required int oldListIndex,
    required int newItemIndex, required int newListIndex,
    required Map<int, List<InfoFormModel>> infoFormListMap,
  }) {
    InfoFormModel item = infoFormListMap[oldListIndex]!.removeAt(oldItemIndex);
    item.groupType = newListIndex;
    infoFormListMap[newListIndex]!.insert(newItemIndex, item);
    update();
  }

  ///列表视图字段 排序回调
  void _infoFormOnItemReorder({
    required int oldItemIndex,
    required int newItemIndex,
    required List<InfoFormModel> infoFormList,
  }) {
    InfoFormModel item = infoFormList.removeAt(oldItemIndex);
    infoFormList.insert(newItemIndex, item);
    update();
  }

  ///列表视图字段 是否显示 选择变化
  void _infoFormIsShowOnChanged(InfoFormModel item) {
    item.isShow = !item.isShow;
    update();
  }


  Widget infoFormGroupSettingWidget(BuildContext context, Map<int, List<InfoFormModel>> infoFormListMap){
    return DragAndDropLists(
      onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
        _infoFormGroupOnItemReorder(
          oldItemIndex: oldItemIndex, oldListIndex: oldListIndex,
          newItemIndex: newItemIndex, newListIndex: newListIndex,
          infoFormListMap: infoFormListMap,
        );
      },
      onListReorder: (int oldListIndex, int newListIndex) {  },
      children: infoFormListMap.keys.map((key) {
        return DragAndDropList(
          canDrag: false,
          header: ListTile(
            contentPadding: const EdgeInsets.only(left: 8, bottom: 8),
            title: Text(
              '第${key + 1}视图',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          children: infoFormListMap[key]!.map((e) {
            return DragAndDropItem(
              child: ListTile(
                leading: e.title.contains('@') ?
                null :
                MineIconButton(
                  icon: Icons.edit_note_outlined,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  padding: const EdgeInsets.all(8),
                  tooltip: '标题名称修改',
                  onPressed: () async {
                    await _infoFormTitleOnChanged(e);
                  },
                ),
                title: Text(
                  e.title.contains('@')
                      ? (_dataService.userDefMap[e.keyName]?.defCaption ?? e.title)
                      : e.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                contentPadding: const EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 4),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MineIconButton(
                      icon: Icons.edit_note_outlined,
                      iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                      padding: const EdgeInsets.all(8),
                      tooltip: '宽度修改',
                      onPressed: () async {
                        await _infoFormWidthOnChanged(e);
                      },
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                          '宽度：${e.width.toString()}',
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1, overflow: TextOverflow.ellipsis
                      ),
                    ),
                    const SizedBox(width: 24,),
                    Switch(
                      value: e.isShow,
                      onChanged: (bool? bool) {
                        _infoFormIsShowOnChanged(e);
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
      listPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      itemDivider: Divider(
        indent: 0, endIndent: 0,
        color: Theme.of(context).colorScheme.surface,
      ),
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
      listInnerDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceTint.withAlpha(18),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
      lastItemTargetHeight: 8,
      addLastItemTargetHeightToTop: true,
      lastListTargetSize: 0,
    );
  }

  Widget infoFormSettingWidget(BuildContext context, List<InfoFormModel> infoFormList){
    return DragAndDropLists(
      onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
        _infoFormOnItemReorder(
          oldItemIndex: oldItemIndex,
          newItemIndex: newItemIndex,
          infoFormList: infoFormList,
        );
      },
      onListReorder: (int oldListIndex, int newListIndex) {  },
      children: [
        DragAndDropList(
          canDrag: false,
          children: infoFormList.map((e) {
            return DragAndDropItem(
              child: ListTile(
                leading: e.title.contains('@') ?
                null :
                MineIconButton(
                  icon: Icons.edit_note_outlined,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  padding: const EdgeInsets.all(8),
                  tooltip: '标题名称修改',
                  onPressed: () async {
                    await _infoFormTitleOnChanged(e);
                  },
                ),
                title: Text(
                  e.title.contains('@')
                      ? (_dataService.userDefMap[e.keyName]?.defCaption ?? e.title)
                      : e.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                contentPadding: const EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 4),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MineIconButton(
                      icon: Icons.edit_note_outlined,
                      iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                      padding: const EdgeInsets.all(8),
                      tooltip: '宽度修改',
                      onPressed: () async {
                        await _infoFormWidthOnChanged(e);
                      },
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                          '宽度：${e.width.toString()}',
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1, overflow: TextOverflow.ellipsis
                      ),
                    ),
                    const SizedBox(width: 24,),
                    Switch(
                      value: e.isShow,
                      onChanged: (bool? bool) {
                        _infoFormIsShowOnChanged(e);
                      },
                    ),
                  ],
                ),
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

  Widget customScrollInfoFormGroupSettingWidget(BuildContext context, {
    required ScrollController scrollController,
    List<Widget> sliverList = const [],
    required Map<int, List<InfoFormModel>> infoFormListMap,
  }){
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        if (sliverList.isNotEmpty)
          SliverList(
            delegate: SliverChildListDelegate(sliverList),
          ),
        SliverPadding(
          padding: const EdgeInsets.all(0),
          sliver: DragAndDropLists(
            sliverList: true,
            scrollController: scrollController,
            onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
              _infoFormGroupOnItemReorder(
                oldItemIndex: oldItemIndex, oldListIndex: oldListIndex,
                newItemIndex: newItemIndex, newListIndex: newListIndex,
                infoFormListMap: infoFormListMap,
              );
            },
            onListReorder: (int oldListIndex, int newListIndex) {  },
            children: infoFormListMap.keys.map((key) {
              return DragAndDropList(
                canDrag: false,
                header: ListTile(
                  contentPadding: const EdgeInsets.only(left: 8, bottom: 8),
                  title: Text(
                    '第${key + 1}视图',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                children: infoFormListMap[key]!.map((e) {
                  return DragAndDropItem(
                    child: ListTile(
                      leading: e.title.contains('@') ?
                      null :
                      MineIconButton(
                        icon: Icons.edit_note_outlined,
                        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        padding: const EdgeInsets.all(8),
                        tooltip: '标题名称修改',
                        onPressed: () async {
                          await _infoFormTitleOnChanged(e);
                        },
                      ),
                      title: Text(
                        e.title.contains('@')
                            ? (_dataService.userDefMap[e.keyName]?.defCaption ?? e.title)
                            : e.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      contentPadding: const EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 4),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MineIconButton(
                            icon: Icons.edit_note_outlined,
                            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                            padding: const EdgeInsets.all(8),
                            tooltip: '宽度修改',
                            onPressed: () async {
                              await _infoFormWidthOnChanged(e);
                            },
                          ),
                          SizedBox(
                            width: 90,
                            child: Text(
                                '宽度：${e.width.toString()}',
                                style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 1, overflow: TextOverflow.ellipsis
                            ),
                          ),
                          const SizedBox(width: 24,),
                          Switch(
                            value: e.isShow,
                            onChanged: (bool? bool) {
                              _infoFormIsShowOnChanged(e);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
            listPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            itemDivider: Divider(
              indent: 0, endIndent: 0,
              color: Theme.of(context).colorScheme.surface,
            ),
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
            listInnerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceTint.withAlpha(18),
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            ),
            lastItemTargetHeight: 8,
            addLastItemTargetHeightToTop: true,
            lastListTargetSize: 0,
          ),
        ),
      ],
    );
  }

  //endregion

}