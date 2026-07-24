import 'package:desktop/app/ui/pages/edit_field/edit_field_controller.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_view.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///表单填写项显示接口
mixin FormInterface on GetxController {

  //region 设置

  ///表单填写项显示 标题名称修改
  Future<void> _formTitleMapTitleOnChanged(String key, Map<String, String> formTitleMap) async {
    var dialogRes = await DialogUtils.showCustomDialog<EditFieldController, String>(
      Get.context!,
      title: '标题名称修改',
      onConfirmName: '确认',
      barrierDismissible: false,
      initialWidth: 550, initialHeight: 260,
      contentPadding: const EdgeInsets.all(12),
      content: EditFieldView(),
      controller: EditFieldController(
          hintContent: formTitleMap[key]!,
          initTCText: formTitleMap[key]!,
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
      formTitleMap[key] = dialogRes;
      update();
    }
  }

  ///表单填写项显示 排序回调
  void _formTitleMapOnItemReorder({
    required int oldItemIndex,
    required int newItemIndex,
    required Map<String, String> formTitleMap,
  }) {
    List<String> keyList = formTitleMap.keys.toList();
    String key = keyList.removeAt(oldItemIndex);
    keyList.insert(newItemIndex, key);
    Map<String,String> map = {};
    map.addAll(formTitleMap);
    formTitleMap.clear();
    keyList.forEach((element) {
      formTitleMap.addAll({element: map[element]!});
    });
    update();
  }

  ///表单填写项样式 修改
  void _formStyleMapOnChanged({
    required String key,
    required String styleType,
    required dynamic value,
    required Map<String, Map<String, dynamic>> formStyleMap,
  }){
    if (!formStyleMap.containsKey(key)){
      formStyleMap.addAll({key: {}});
    }
    formStyleMap[key]!.addAll({styleType: value});
    update();
  }


  Widget formSettingWidget(BuildContext context, {
    required Map<String, String> formTitleMap,
    required Map<String, Map<String, dynamic>> formStyleMap,
    required String numPadFocusField,
    required ValueSetter<String> numPadFocusFieldOnChanged,
  }){
    return DragAndDropLists(
      onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
        _formTitleMapOnItemReorder(
          oldItemIndex: oldItemIndex, 
          newItemIndex: newItemIndex,
          formTitleMap: formTitleMap,
        );
      },
      onListReorder: (int oldListIndex, int newListIndex) {  },
      children: [
        DragAndDropList(
          canDrag: false,
          children: formTitleMap.keys.map((key) {
            String value = formTitleMap[key]!;
            bool isHighlight = formStyleMap[key]?[AppConfig.isHighlight] == true
                || numPadFocusField == key;
            return DragAndDropItem(
              child: ExpansionTile(
                leading: MineIconButton(
                  icon: Icons.edit_note_outlined,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  padding: const EdgeInsets.all(8),
                  tooltip: '标题名称修改',
                  onPressed: () async {
                    await _formTitleMapTitleOnChanged(key, formTitleMap);
                  },
                ),
                title: Container(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                        text: '',
                        style: Theme.of(context).textTheme.bodyLarge,
                        children: [
                          TextSpan(
                              text: value.replaceAll('\u00A0', ' ').removeAllWhitespace,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              )
                          ),
                          if (isHighlight)
                            TextSpan(
                                text: '\n',
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                                )
                            ),
                          TextSpan(
                              text: ''
                                  '${formStyleMap[key]?[AppConfig.isHighlight] == true
                                  ? '内容突出显示；'
                                  : ''}'
                                  '${numPadFocusField == key
                                  ? '输入框自动获取焦点；'
                                  : ''}',
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                              )
                          )
                        ]
                    ),
                  ),
                ),
                tilePadding: EdgeInsets.only(
                  top: isHighlight ? 0 : 8,
                  bottom: isHighlight ? 0 : 8,
                  right: 8,
                  left: 4,
                ),
                children: [
                  SwitchListTile(
                    title: Text(
                      '内容突出显示',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: formStyleMap[key]?[AppConfig.isHighlight] == true,
                    onChanged: (bool? bool) {
                      _formStyleMapOnChanged(
                        key: key,
                        styleType: AppConfig.isHighlight,
                        value: formStyleMap[key]?[AppConfig.isHighlight] != true,
                        formStyleMap: formStyleMap,
                      );
                    },
                  ),
                  if (NumPadUtil().isFieldDefined(key))
                    SwitchListTile(
                      title: Text(
                        '输入框自动获取焦点',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      value: numPadFocusField == key,
                      onChanged: (bool? bool) {
                        if (numPadFocusField == key){
                          numPadFocusFieldOnChanged.call('');
                        }
                        else {
                          numPadFocusFieldOnChanged.call(key);
                        }
                        update();
                      },
                    )
                ],
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

  Widget customScrollFormGroupSettingWidget(BuildContext context, {
    required ScrollController scrollController,
    List<Widget> sliverList = const [],
    required Map<String, String> formTitleMap,
    required Map<String, Map<String, dynamic>> formStyleMap,
    required String numPadFocusField,
    required ValueSetter<String> numPadFocusFieldOnChanged,
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
              _formTitleMapOnItemReorder(
                oldItemIndex: oldItemIndex,
                newItemIndex: newItemIndex,
                formTitleMap: formTitleMap,
              );
            },
            onListReorder: (int oldListIndex, int newListIndex) {  },
            children: [
              DragAndDropList(
                canDrag: false,
                children: formTitleMap.keys.map((key) {
                  String value = formTitleMap[key]!;
                  bool isHighlight = formStyleMap[key]?[AppConfig.isHighlight] == true
                      || numPadFocusField == key;
                  return DragAndDropItem(
                    child: ExpansionTile(
                      leading: MineIconButton(
                        icon: Icons.edit_note_outlined,
                        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        padding: const EdgeInsets.all(8),
                        tooltip: '标题名称修改',
                        onPressed: () async {
                          await _formTitleMapTitleOnChanged(
                            key,
                            formTitleMap
                          );
                        },
                      ),
                      title: Container(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            text: '',
                            style: Theme.of(context).textTheme.bodyLarge,
                            children: [
                              TextSpan(
                                text: value.replaceAll('\u00A0', ' ').removeAllWhitespace,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                )
                              ),
                              if (isHighlight)
                                TextSpan(
                                  text: '\n',
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                                  )
                                ),
                              TextSpan(
                                text: ''
                                    '${formStyleMap[key]?[AppConfig.isHighlight] == true
                                    ? '内容突出显示；'
                                    : ''}'
                                    '${numPadFocusField == key
                                    ? '输入框自动获取焦点；'
                                    : ''}',
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                                )
                              )
                            ]
                          ),
                        ),
                      ),
                      tilePadding: EdgeInsets.only(
                        top: isHighlight ? 0 : 8,
                        bottom: isHighlight ? 0 : 8,
                        right: 8,
                        left: 4,
                      ),
                      children: [
                        SwitchListTile(
                          title: Text(
                            '内容突出显示',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          value: formStyleMap[key]?[AppConfig.isHighlight] == true,
                          onChanged: (bool? bool) {
                            _formStyleMapOnChanged(
                              key: key,
                              styleType: AppConfig.isHighlight,
                              value: formStyleMap[key]?[AppConfig.isHighlight] != true,
                              formStyleMap: formStyleMap,
                            );
                          },
                        ),
                        if (NumPadUtil().isFieldDefined(key))
                          SwitchListTile(
                            title: Text(
                              '输入框自动获取焦点',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            controlAffinity: ListTileControlAffinity.trailing,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            value: numPadFocusField == key,
                            onChanged: (bool? bool) {
                              if (numPadFocusField == key){
                                numPadFocusFieldOnChanged.call('');
                              }
                              else {
                                numPadFocusFieldOnChanged.call(key);
                              }
                              update();
                            },
                          )
                      ],
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
          ),
        ),
      ],
    );
  }

  //endregion

}