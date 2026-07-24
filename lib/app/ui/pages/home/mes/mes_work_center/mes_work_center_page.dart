import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/mes_work_center_controller.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/utils/sign_color_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 加工中心（可选择派工单报工 OR 任务单报工）
class MesWorkCenterPage extends BaseFormPage<MesWorkCenterController> {

  Widget contentWidget(BuildContext context, MesWorkCenterController _) {
    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.topCenter,
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: CardWidget(
              content: workCenterWidget(context, _),
            ),
          ),
          Expanded(
            child: CardWidget(
              content: dataAreaWidget(context, _),
            ),
          )
        ],
      ),
    );
  }

  Widget workCenterWidget(BuildContext context, MesWorkCenterController _){
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: TextField(
              controller: _.wcSearchTC,
              focusNode: _.wcSearchFN,
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: (String? string) async{
                await controller.wcSearchTCOnSearch();
              },
              decoration: InputDecoration(
                hintText: '加工中心编号...',
                hintStyle: Theme.of(context).inputDecorationTheme.hintStyle?.copyWith(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                prefixIcon: Icon(
                  Icons.search,
                  size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  color: Theme.of(context).inputDecorationTheme.iconColor,
                ),
                suffixIcon: _.wcSearchTC.text.isNotEmpty ?
                MineIconButton(
                  icon: Icons.cancel,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  tooltip: '清空',
                  onPressed: () async{
                    await controller.wcSearchTCClear();
                  },
                ) :
                null,
              ),
            ),
          ),
          const SizedBox(height: 12,),

          Expanded(
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                interactive: false,
                thumbVisibility: WidgetStateProperty.all(false),
                trackVisibility: WidgetStateProperty.all(false),
                thumbColor: WidgetStateProperty.all(Colors.transparent),
                trackColor: WidgetStateProperty.all(Colors.transparent),
              ),
              child: ListView.builder(
                controller: _.workCenterScrollController,
                itemCount: _.workCenterFilterList.length,
                itemBuilder: (BuildContext context, int index){
                  MoWorkCenterModel item = _.workCenterFilterList[index];
                  return workCenterItem(context, _, item);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget workCenterItem(BuildContext context, MesWorkCenterController _, MoWorkCenterModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        shadowColor: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: (){
            controller.wcItemOnTap(item);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: item.isChoice
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${(item.lineCode ?? '').isNotEmpty ? item.lineCode : ' '}',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: item.isChoice
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : null,
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis
                        ),
                      ),
                    ),

                    Tooltip(
                      message: '分配',
                      child: InkWell(
                        onTap: () async {
                          await controller.wcAllocate(item);
                        },
                        child: Icon(
                          Icons.add_box_outlined,
                          size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        ),
                      ),
                    ),
                  ],
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                      '${(item.lineName ?? '').isNotEmpty ? item.lineName : ' '}',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: item.isChoice
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : null,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dataAreaWidget(BuildContext context, MesWorkCenterController _){
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(6),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints){
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        runSpacing: 4, spacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ///单据类型选择、单据状态选择
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: MenuBar(
                              style: MenuStyle(
                                elevation: WidgetStateProperty.all(0),
                                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                                shadowColor: WidgetStateProperty.all(Colors.transparent),
                                side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).colorScheme.onSurface)),
                                padding: WidgetStateProperty.all(EdgeInsets.zero),
                              ),
                              children: [
                                if (_.isShowCategory)
                                  SubmenuButton(
                                    menuChildren: _.categoryList.map((e){
                                      return MenuItemButton(
                                        onPressed: () async {
                                          await controller.categoryOnChanged(e);
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
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(width: 14,),
                                        Container(
                                          constraints: const BoxConstraints(
                                            minWidth: 48,
                                          ),
                                          child: Text(
                                            _.selectedCategoryTitle,
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
                                if (_.isShowCategory || _.isShowSignFilter)
                                VerticalDivider(
                                  indent: 0, endIndent: 0,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                if (_.isShowSignFilter)
                                  _.signMenuWidget(context),
                              ],
                            ),
                          ),

                          if (_.isShowDatePicker)
                            _.dateFilterInputWidget(context),
                          if (_.isDataByScan)
                            _.resetScanWidget(context),
                          if (_.isShowSearchInputBox)
                            _.searchInputWidget(context),
                        ],
                      ),
                    ),

                    settingWidget(context, _, top: kIsWeb || GetPlatform.isWindows ? 9 : 0),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: dataListWidget(context, _),
          ),
          const SizedBox(height: 4,),

          ///总记录数 翻页
          Row(
            children: [
              RichText(
                text: TextSpan(
                    text: '共 ',
                    style: Theme.of(context).textTheme.bodyLarge,
                    children: [
                      TextSpan(
                          text: _.total.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43
                          )
                      ),
                      const TextSpan(
                          text: ' 条记录'
                      )
                    ]
                ),
                textScaler: TextScaler.linear(FontFamilyConfig.textScale),
              ),
              const Expanded(child: SizedBox.shrink()),
              const SizedBox(width: 8,),

              OutlinedButton(
                onPressed: () async{
                  await controller.pageChanged(pageIndex: 1);
                  controller.update();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FluentIcons.arrow_sync_circle_16_regular,
                      color: IconTheme.of(context).color,
                      size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    ),
                    const SizedBox(width: 4,),
                    Text(
                      '刷新',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8,),

              OutlinedButton(
                onPressed: () async{
                  if (_.nowPage == 1 || _.nowPage == 0 || _.totalPage == 0){
                    ToastNotification(Get.overlayContext!).warn("当前已经是首页！");
                    return;
                  }
                  await controller.pageChanged(pageIndex: _.nowPage - 1);
                  controller.update();
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
                      '上一页',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 16,),

              Text(
                '${_.nowPage} / ${_.totalPage}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(width: 16,),

              OutlinedButton(
                onPressed: () async{
                  if (_.nowPage == _.totalPage || _.nowPage == 0 || _.totalPage == 0){
                    ToastNotification(Get.overlayContext!).warn("当前已经是最后一页！");
                    return;
                  }
                  await controller.pageChanged(pageIndex: _.nowPage + 1);
                  controller.update();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FluentIcons.arrow_circle_right_12_regular,
                      color: IconTheme.of(context).color,
                      size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    ),
                    const SizedBox(width: 4,),
                    Text(
                      '下一页',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget dataListWidget(BuildContext context, MesWorkCenterController _){
    if (_.selectedCategorySign == 610001){ ///任务单
      return ScrollbarTheme(
        data: ScrollbarThemeData(
          interactive: false,
          thumbVisibility: WidgetStateProperty.all(false),
          trackVisibility: WidgetStateProperty.all(false),
          thumbColor: WidgetStateProperty.all(Colors.transparent),
          trackColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: ListView.builder(
          controller: _.listScrollController,
          itemCount: _.orderList.length,
          itemBuilder: (BuildContext context, int index){
            MoOpOrderModel item = _.orderList[index];
            return orderItem(context, _, item);
          },
        ),
      );
    }
    else if (_.selectedCategorySign == 650011){ ///派工单
      if (_.selectedWorkCenterId.isEmpty){
        return Center(
          child: Text(
            '请选择左侧的加工中心！',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600
            ),
          ),
        );
      }
      return ScrollbarTheme(
        data: ScrollbarThemeData(
          interactive: false,
          thumbVisibility: WidgetStateProperty.all(false),
          trackVisibility: WidgetStateProperty.all(false),
          thumbColor: WidgetStateProperty.all(Colors.transparent),
          trackColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: ListView.builder(
          controller: _.listScrollController,
          itemCount: _.taskList.length,
          itemBuilder: (BuildContext context, int index){
            MoTaskModel item = _.taskList[index];
            return taskItem(context, _, item);
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget orderItem(BuildContext context, MesWorkCenterController _, MoOpOrderModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () async{
            await controller.itemOnTap(item);
          },
          onDoubleTap: () async{
            await controller.itemOnDoubleTap(item);
          },
          onLongPress: () async{
            await controller.itemOnLongPress(item);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ///产品附件查看
                    MineIconButton(
                      onPressed: () async{
                        await controller.getInvAttach(item);
                      },
                      tooltip: '产品附件',
                      icon: Icons.picture_as_pdf_outlined,
                      iconSize: 60,
                      iconColor: Theme.of(context).colorScheme.primary,
                      //padding: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                    ),

                    ///产品名称 + 按钮组 + 详细信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SelectableText.rich(
                                  TextSpan(
                                      text: '【${item.productName ?? ''}】',
                                      children: [
                                        TextSpan(
                                          text: item.status ?? '',
                                          style: TextStyle(
                                            color: SignColorUtil().getOrderSignColor(item.sign ?? 0),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '（${NumFormatUtil.qtyFormatConverter((item.qualifiedQty ?? 0).toString())}'
                                              '/'
                                              '${NumFormatUtil.qtyFormatConverter((item.qty ?? 0).toString())}）',
                                        ),
                                      ]
                                  ),
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600
                                  ),
                                  maxLines: 2,
                                  onTap: () async{
                                    await controller.itemOnTap(item);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8,),

                              _.commandBarWidget(
                                context,
                                commandBarList: _.orderCommandBarList,
                                item: item,
                                btnPadding: kIsWeb || GetPlatform.isWindows
                                    ? const EdgeInsets.symmetric(vertical: 18, horizontal: 8)
                                    : const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                isExpanded: item.isExpanded,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 4),
                            constraints: BoxConstraints(
                              minHeight: 40,
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.end,
                              runSpacing: 4, spacing: 6,
                              children: _.getFieldList(
                                context,
                                infoFormList: _.orderListInfoFormListMap[0] ?? [],
                                item: item,
                                customBuilder: (String keyName, ICloneable item){
                                  item as MoOpOrderModel;
                                  return customFieldOrder(keyName, item);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: !item.isExpanded ?
                  const SizedBox.shrink() :
                  Wrap(
                    //alignment: WrapAlignment.start,
                    //runAlignment: WrapAlignment.end,
                    runSpacing: 4, spacing: 6,
                    children: _.getFieldList(
                      context,
                      infoFormList: _.orderListInfoFormListMap[1] ?? [],
                      item: item,
                      customBuilder: (String keyName, ICloneable item){
                        item as MoOpOrderModel;
                        return customFieldOrder(keyName, item);
                      },
                    ),
                  ),
                  crossFadeState: item.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget taskItem(BuildContext context, MesWorkCenterController _, MoTaskModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () async{
            await controller.itemOnTap(item);
          },
          onDoubleTap: () async{
            await controller.itemOnDoubleTap(item);
          },
          onLongPress: () async{
            await controller.itemOnLongPress(item);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ///产品附件查看
                    MineIconButton(
                      onPressed: () async{
                        await controller.getInvAttach(item);
                      },
                      tooltip: '产品附件',
                      icon: Icons.picture_as_pdf_outlined,
                      iconSize: 60,
                      iconColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                    ),

                    ///产品名称 + 工序 + 按钮组 + 详细信息0
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SelectableText.rich(
                                  TextSpan(
                                      text: '【${item.invName ?? ''}】',
                                      children: [
                                        TextSpan(
                                          text: (item.opName ?? '').isEmpty
                                              ? ''
                                              : '【${item.opName ?? ''}】',
                                        ),
                                        TextSpan(
                                          text: item.status ?? '',
                                          style: TextStyle(
                                            color: SignColorUtil().getTaskSignColor(item.sign ?? 0),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '（${NumFormatUtil.qtyFormatConverter((item.submitQty ?? 0).toString())}'
                                              '/'
                                              '${NumFormatUtil.qtyFormatConverter((item.assignQty ?? 0).toString())}）',
                                        ),
                                      ]
                                  ),
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600
                                  ),
                                  onTap: () async{
                                    await controller.itemOnTap(item);
                                  },
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(width: 8,),

                              _.commandBarWidget(
                                context,
                                commandBarList: _.taskCommandBarList,
                                item: item,
                                btnPadding: kIsWeb || GetPlatform.isWindows
                                    ? const EdgeInsets.symmetric(vertical: 18, horizontal: 8)
                                    : const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                isExpanded: item.isExpanded,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 4),
                            constraints: BoxConstraints(
                              minHeight: 40,
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.end,
                              runSpacing: 4, spacing: 6,
                              children: _.getFieldList(
                                context,
                                infoFormList: _.taskListInfoFormListMap[0] ?? [],
                                item: item,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: !item.isExpanded ?
                  const SizedBox.shrink() :
                  Wrap(
                    runSpacing: 4, spacing: 6,
                    children: _.getFieldList(
                      context,
                      infoFormList: _.taskListInfoFormListMap[1] ?? [],
                      item: item,
                    ),
                  ),
                  crossFadeState: item.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Map<String, dynamic>? customFieldOrder(String keyName, MoOpOrderModel item){
    switch (keyName){
      case 'OrderSN':
        return {
          'content': item.orderSN,
        };
    }
    return null;
  }

}