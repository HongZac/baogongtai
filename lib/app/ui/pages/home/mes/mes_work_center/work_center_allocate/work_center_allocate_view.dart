import 'package:basement/item_model.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/work_center_allocate/work_center_allocate_controller.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///产线、加工中心、班组 分配页面
class WorkCenterAllocateView extends BaseDialogPage<WorkCenterAllocateController> {

  Widget contentWidget(BuildContext context, WorkCenterAllocateController _) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CardWidget(
              content: detailWidget(context, _),
            ),
          ),
          const SizedBox(height: 16,),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _.scanTC,
                      focusNode: _.scanFN,
                      maxLines: 1,
                      showCursor: true,
                      autofocus: true,
                      keyboardType: TextInputType.none,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        suffixIcon: MineIconButton(
                          icon: Icons.cancel,
                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          tooltip: '清空',
                          onPressed: () async{
                            _.scanTC.clear();
                            controller.update();
                          },
                        ),
                      ),
                      onSubmitted: (String value) async {
                        await controller.onSubmitted();
                      },
                    ),
                    const SizedBox(height: 4,),
                    Text(
                      '请将输入法切换成英文模式后在进行扫码！',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.errorTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16,),

              if (_.objTypePickerList.length == 1)
                FilledButton(
                    focusNode: _.submenuBtnFN,
                    onPressed: () async {
                      await controller.objTypeMenuOnTap(_.objTypePickerList[0]);
                    },
                    style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                            kIsWeb || GetPlatform.isWindows
                                ? const EdgeInsets.symmetric(vertical: 20, horizontal: 24)
                                : const EdgeInsets.symmetric(vertical: 16, horizontal: 24)
                        )
                    ),
                    child: Text(
                      '${_.objTypePickerList[0].title}',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                      ),
                    )
                )
              else
                MenuBar(
                  style: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
                      padding: WidgetStateProperty.all(EdgeInsets.zero)
                  ),
                  children: [
                    SubmenuButton(
                      focusNode: _.submenuBtnFN,
                      menuChildren: _.objTypeMenuList,
                      style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                              kIsWeb || GetPlatform.isWindows
                                  ? const EdgeInsets.symmetric(vertical: 20)
                                  : const EdgeInsets.symmetric(vertical: 16)
                          )
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 14,),
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 48,
                            ),
                            child: Text(
                              '新增关联对象',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                              ),
                            ),
                          ),
                          const SizedBox(width: 2,),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8,),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 4,),

          Expanded(
              child: dataReport(context, _)
          ),
        ],
      ),
    );
  }

  Widget detailWidget(BuildContext context, WorkCenterAllocateController _) {
    if (_.workCenterProgId == 660022){
      return Container(
        height: 55,
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SelectableText(
                  '【${_.workCenterItem.lineCode ?? ''}】'
                      '${_.workCenterItem.lineName ?? ''}',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600
                  ), maxLines: 1,
                ),
              ],
            ),
            const SizedBox(height: 4,),

            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  interactive: false,
                  thumbVisibility: WidgetStateProperty.all(false),
                  trackVisibility: WidgetStateProperty.all(false),
                  thumbColor: WidgetStateProperty.all(Colors.transparent),
                  trackColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: SingleChildScrollView(
                  controller: _.detailScrollController,
                  child: Wrap(
                    runSpacing: 4, spacing: 6,
                    children: detailList(context, _),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    else {
      return Container(
        height: 55,
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SelectableText(
                  '【${_.beltLineItem.lineCode ?? ''}】'
                      '${_.beltLineItem.lineName ?? ''}',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600
                  ), maxLines: 1,
                ),
              ],
            ),
            const SizedBox(height: 4,),

            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  interactive: false,
                  thumbVisibility: WidgetStateProperty.all(false),
                  trackVisibility: WidgetStateProperty.all(false),
                  thumbColor: WidgetStateProperty.all(Colors.transparent),
                  trackColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: SingleChildScrollView(
                  controller: _.detailScrollController,
                  child: Wrap(
                    runSpacing: 4, spacing: 6,
                    children: detailList2(context, _),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
  List<Widget> detailList(BuildContext context, WorkCenterAllocateController _) {
    List<Widget> list = [];
    list.add(
        infoItemm(context, _, title: '部门', content: _.workCenterItem.depName ?? '')
    );
    list.add(
        infoItemm(context, _, title: '父级', content: _.workCenterItem.parentName ?? '')
    );
    return list;
  }
  List<Widget> detailList2(BuildContext context, WorkCenterAllocateController _) {
    List<Widget> list = [];
    list.add(
        infoItemm(context, _, title: '部门', content: _.beltLineItem.depName ?? '')
    );
    list.add(
        infoItemm(context, _, title: '父级', content: _.beltLineItem.parentName ?? '')
    );
    return list;
  }
  
  Widget infoItemm(BuildContext context, WorkCenterAllocateController _, {
    required String title,
    required String content,
    Color? contentColor,
    double width = 310,
    double titleWidth = 100,
    bool isBold = false,
    void Function()? onPress,
    MoBeltLineItem? item,
  }) {
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: width,
      titleWidth: titleWidth,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      contentStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: contentColor,
        fontWeight: isBold ? FontWeight.w600 : null
      ),
      onPress: onPress,
    );
  }

  Widget dataReport(BuildContext context, WorkCenterAllocateController _) {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        interactive: false,
        thumbVisibility: WidgetStateProperty.all(false),
        trackVisibility: WidgetStateProperty.all(false),
        thumbColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: ListView(
        cacheExtent: Get.height * 100,
        controller: _.dataReportScrollController,
        padding: const EdgeInsets.all(4),
        children: dataReportList(context, _),
      ),
    );
  }
  List<Widget> dataReportList(BuildContext context, WorkCenterAllocateController _) {
    List<Widget> list = [];
    if (_.workCenterProgId == 660022){
      for (var element in _.workCenterItem.entryList) {
        Color bkgdColor = Colors.transparent;
        switch (element.objType){
          case 200009: ///员工
            bkgdColor = Colors.blue.withAlpha(13);
            break;
          case 220011: ///设备
            bkgdColor = Colors.green.withAlpha(13);
            break;
          case 700201: ///模具
            bkgdColor = Colors.orange.withAlpha(13);
            break;
        }
        list.add(
            Container(
              child: Column(
                children: [
                  Container(
                    color: bkgdColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            controller.getObjTypeTitle(element.objType),
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                            ), maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${element.objCode ?? ''}',
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${element.objName ?? ''}',
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        Container(
                          width: 48,
                          alignment: Alignment.centerRight,
                          child: Tooltip(
                            message: '移除',
                            child: InkWell(
                              onTap: () async {
                                await controller.removeItem(element);
                              },
                              child: Icon(
                                FluentIcons.delete_16_regular,
                                size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                                color: IconTheme.of(context).color!.withAlpha(128),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4,),
                      ],
                    ),
                  ),
                  Divider(indent: 4, endIndent: 4,),
                ],
              ),
            )
        );
      }
    }
    else {
      for (var element in _.beltLineItem.entryList) {
        Color bkgdColor = Colors.transparent;
        switch (element.objType){
          case 200009: ///员工
            bkgdColor = Colors.blue.withAlpha(13);
            break;
          case 220011: ///设备
            bkgdColor = Colors.green.withAlpha(13);
            break;
          case 700201: ///模具
            bkgdColor = Colors.orange.withAlpha(13);
            break;
        }
        list.add(
            Container(
              child: Column(
                children: [
                  Container(
                    color: bkgdColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            controller.getObjTypeTitle(element.objType),
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                            ), maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${element.objCode ?? ''}',
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${element.objName ?? ''}',
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        MineIconButton(
                          onPressed: () async{
                            await controller.removeItem(element);
                          },
                          tooltip: '移除',
                          icon: FluentIcons.delete_16_regular,
                          iconColor: IconTheme.of(context).color!.withAlpha(128),
                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.3,
                        ),
                        const SizedBox(width: 4,),
                      ],
                    ),
                  ),
                  Divider(indent: 4, endIndent: 4,),
                ],
              ),
            )
        );
      }
    }
    return list;
  }

}