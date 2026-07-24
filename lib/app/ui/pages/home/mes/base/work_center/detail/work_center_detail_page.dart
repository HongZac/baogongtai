import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mes/base/work_center/detail/work_center_detail_controller.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///加工中心 详情页面
class WorkCenterDetailPage extends BaseFormPage<WorkCenterDetailController>{

  Widget contentWidget(BuildContext context, WorkCenterDetailController _) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ///返回键
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 400, height: 54,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 8),
                child: const BackOutlinedButton(),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    _.progId == 660022
                        ? '【${_.workCenterItem.lineCode ?? ''}】'
                        '${_.workCenterItem.lineName ?? ''}'
                        : '【${_.beltLineItem.lineCode ?? ''}】'
                        '${_.beltLineItem.lineName ?? ''}',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ), maxLines: 1,
                  ),
                ),
              ),
              Container(
                width: 400, height: 54,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: MenuBar(
                          style: MenuStyle(
                            elevation: WidgetStateProperty.all(0),
                            backgroundColor: WidgetStateProperty.all(Colors.transparent),
                            shadowColor: WidgetStateProperty.all(Colors.transparent),
                            side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).colorScheme.onSurface)),
                            padding: WidgetStateProperty.all(EdgeInsets.zero),
                          ),
                          children: [
                            SubmenuButton(
                              focusNode: _.objTypeMenuBtnFN,
                              menuChildren: _.objTypeList.map((e){
                                return MenuItemButton(
                                  onPressed: () async {
                                    controller.objTypeOnChanged(e.sign);
                                  },
                                  style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                        const EdgeInsets.only(top: 22, bottom: 22, left: 12, right: 44)
                                    ),
                                  ),
                                  child: MenuAcceleratorLabel(e.title),
                                );
                              }).toList(),
                              style: ButtonStyle(
                                  padding: WidgetStateProperty.all(
                                      kIsWeb || GetPlatform.isWindows
                                          ? const EdgeInsets.symmetric(vertical: 20)
                                          : const EdgeInsets.symmetric(vertical: 12)
                                  )
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 14,),
                                    Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 48,
                                      ),
                                      child: Text(
                                        '${_.selectedObjTypeModel == null
                                            ? '（请选择）'
                                            : _.selectedObjTypeModel?.title}',
                                        style: TextStyle(
                                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2,),
                                    const Icon(
                                      Icons.arrow_drop_down,
                                    ),
                                    const SizedBox(width: 8,),
                                  ],
                                ),
                              ),
                            ),
                            VerticalDivider(
                              indent: 0, endIndent: 0,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            SubmenuButton(
                                focusNode: _.objClassIdMenuBtnFN,
                                menuChildren: _.objClassIdList.map((e){
                                  return MenuItemButton(
                                    onPressed: () async {
                                      controller.objClassIdOnChanged(e.content);
                                    },
                                    style: ButtonStyle(
                                      padding: WidgetStateProperty.all(
                                          const EdgeInsets.only(top: 22, bottom: 22, left: 12, right: 44)
                                      ),
                                    ),
                                    child: MenuAcceleratorLabel(e.title),
                                  );
                                }).toList(),
                                style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                        kIsWeb || GetPlatform.isWindows
                                            ? const EdgeInsets.symmetric(vertical: 20)
                                            : const EdgeInsets.symmetric(vertical: 12)
                                    )
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(width: 14,),
                                      Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 48,
                                        ),
                                        child: Text(
                                          '${_.selectedObjClassIdModel == null
                                              ? '（请选择）'
                                              : _.selectedObjClassIdModel?.title}',
                                          style: TextStyle(
                                              fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 2,),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                      ),
                                      const SizedBox(width: 8,),
                                    ],
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),
                    ),

                    if(!_.isEdit)
                      const SizedBox(width: 8,),
                    if (!_.isEdit)
                      FilledButton(
                          onPressed: () async {
                            await controller.doEditData();
                          },
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                                kIsWeb || GetPlatform.isWindows
                                    ? const EdgeInsets.symmetric(vertical: 18, horizontal: 38)
                                    : const EdgeInsets.symmetric(vertical: 12, horizontal: 38)
                            ),
                          ),
                          child: Text(
                            '编辑',
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                            ),
                          )
                      )
                  ],
                ),
              ),
            ],
          ),

          ///扫码区域
          if (_.isEdit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: scanWidget(context, _),
            ),
          if (_.isEdit)
            const SizedBox(height: 4,),

          ///表体
          Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: dataReport(context, _)
            ),
          ),
          const SizedBox(height: 8,),

          ///提交按钮
          if (_.isEdit)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: editAndSaveWidget(context, _),
            ),
        ],
      ),
    );
  }

  Widget dataReport(BuildContext context, WorkCenterDetailController _) {
    bool isNeedTimeColumn = _.filterEntryList.firstWhereOrNull((element) => element.objType == 220011) != null;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          ///标题
          Material(
            elevation: 4,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            shadowColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '类型',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ), maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '关联对象编码',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ), maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '关联对象名称',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ), maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: isNeedTimeColumn ?
                    Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '设计寿命',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ), maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ) :
                    const SizedBox.shrink(),
                  ),
                  Expanded(
                    flex: 1,
                    child: isNeedTimeColumn ?
                    Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '预警寿命',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ), maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ) :
                    const SizedBox.shrink(),
                  ),
                  Expanded(
                    flex: 1,
                    child: isNeedTimeColumn ?
                    Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '剩余寿命',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ), maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ) :
                    const SizedBox.shrink(),
                  ),

                  if (_.isEdit)
                    const SizedBox(width: 48,),

                  const SizedBox(width: 4,),
                ],
              ),
            ),
          ),

          ///内容
          Expanded(
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                interactive: false,
                thumbVisibility: WidgetStateProperty.all(false),
                trackVisibility: WidgetStateProperty.all(false),
                thumbColor: WidgetStateProperty.all(Colors.transparent),
                trackColor: WidgetStateProperty.all(Colors.transparent),
              ),
              child: ListView(
                cacheExtent: Get.height * 100,
                children: dataReportList(context, _),
              ),
            ),
          ),
        ],
      ),
    );
  }
  List<Widget> dataReportList(BuildContext context, WorkCenterDetailController _) {
    List<Widget> list = [];
    for (var element in _.filterEntryList) {
      Color bkgdColor = Colors.transparent;
      switch (element.objType){
        case 200009: ///员工
          bkgdColor = Colors.blue.withAlpha(12);
          break;
        case 220011: ///设备
          bkgdColor = Colors.green.withAlpha(12);
          break;
        case 700201: ///模具
          bkgdColor = Colors.orange.withAlpha(12);
          break;
      }
      ///剩余寿命
      int surplusTime =  (element.lifeTime ?? 0) > (element.loadTime ?? 0)
          ? ((element.lifeTime ?? 0) - (element.loadTime ?? 0))
          : 0;
      ///剩余 小于 预警时，标红
      bool isOverTime = ((element.lifeTime ?? 0) - (element.loadTime ?? 0)) < (element.advancedTime ?? 0);
      list.add(
          Container(
            child: Column(
              children: [
                Container(
                  color: isOverTime ? AppColors.errorColor : bkgdColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${controller.getObjTypeTitle(element.objType)}'
                                '${(element.objClassName ?? '').isNotEmpty ? ' / ' : ''}'
                                '${element.objClassName ?? ''}',
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isOverTime ? Theme.of(context).colorScheme.surface : null,
                            ), maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${element.objCode ?? ''}',
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: isOverTime ? Theme.of(context).colorScheme.surface : null,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${element.objName ?? ''}',
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: isOverTime ? Theme.of(context).colorScheme.surface : null,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      ///设计寿命 / 剩余寿命 / 预警寿命
                      Expanded(
                        flex: 1,
                        child: element.objType == 220011 ?
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            element.lifeTime == null ? '0' : element.lifeTime.toString(),
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: isOverTime ? Theme.of(context).colorScheme.surface : null,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ) :
                        const SizedBox.shrink(),
                      ),
                      Expanded(
                        flex: 1,
                        child: element.objType == 220011 ?
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            element.advancedTime == null ? '0' : element.advancedTime.toString(),
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: isOverTime ? Theme.of(context).colorScheme.surface : null,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ) :
                        const SizedBox.shrink(),
                      ),
                      Expanded(
                        flex: 1,
                        child: element.objType == 220011 ?
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            surplusTime.toString(),
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: isOverTime ? Theme.of(context).colorScheme.surface : null,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ) :
                        const SizedBox.shrink(),
                      ),

                      if (_.isEdit)
                        Container(
                          width: 48,
                          alignment: Alignment.centerRight,
                          child: Tooltip(
                            message: '移除',
                            child: InkWell(
                              onTap: () {
                                controller.removeItem(element);
                              },
                              child: Icon(
                                FluentIcons.delete_16_regular,
                                size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                                color: isOverTime
                                    ? Theme.of(context).colorScheme.surface
                                    : IconTheme.of(context).color!.withAlpha(127),
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
    return list;
  }

  ///扫码控件
  Widget scanWidget(BuildContext context, WorkCenterDetailController _){
    return Row(
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
      ],
    );
  }

  Widget editAndSaveWidget(BuildContext context, WorkCenterDetailController _){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () async {
            await controller.doBrowseData();
          },
          style: ButtonStyle(
              padding: WidgetStateProperty.all(
                  kIsWeb || GetPlatform.isWindows
                      ? const EdgeInsets.symmetric(vertical: 20, horizontal: 24)
                      : const EdgeInsets.symmetric(vertical: 16, horizontal: 24)
              )
          ),
          child: Text(
            '取消编辑',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          )
        ),
        const SizedBox(width: 8,),
        FilledButton(
          onPressed: () async {
            await controller.doSaveData();
          },
          style: ButtonStyle(
              padding: WidgetStateProperty.all(
                  kIsWeb || GetPlatform.isWindows
                      ? const EdgeInsets.symmetric(vertical: 20, horizontal: 24)
                      : const EdgeInsets.symmetric(vertical: 16, horizontal: 24)
              )
          ),
          child: Text(
            '\u00A0\u00A0\u00A0\u00A0提交\u00A0\u00A0\u00A0\u00A0',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          )
        ),
      ],
    );
  }

}