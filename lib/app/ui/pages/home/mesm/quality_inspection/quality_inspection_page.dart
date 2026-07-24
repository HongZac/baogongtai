import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/quality_inspection_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_button_widget.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/sign_color_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///质量巡检首页
class QualityInspectionPage extends BaseFormPage<QualityInspectionController>{

  @override
  Widget contentWidget(BuildContext context, QualityInspectionController _) {
    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.topCenter,
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
                                  SubmenuButton(
                                    menuChildren: _.qualityInspectionCategoryMenuList,
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
                                              minWidth: 70
                                          ),
                                          child: Text(
                                            _.selectedTaskCategoryModel.sign == -1
                                                ? '（请选择）'
                                                : _.selectedTaskCategoryModel.title,
                                            style: TextStyle(
                                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6,),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                        ),
                                        const SizedBox(width: 8,),
                                      ],
                                    ),
                                  ),
                                  VerticalDivider(
                                    indent: 0, endIndent: 0,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  SubmenuButton(
                                    menuChildren: _.qualityInspectionSignMenuList,
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
                                              minWidth: 70
                                          ),
                                          child: Text(
                                            _.selectedTaskSignModel.sign == -1
                                                ? '（请选择）'
                                                : _.selectedTaskSignModel.title,
                                            style: TextStyle(
                                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6,),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                        ),
                                        const SizedBox(width: 8,),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                          ),

                          ///设备组筛选
                          PickerButtonWidget(
                            adapter: _.eamRoleAdapter,
                            pickerChoiceType: PickerChoiceType.chip,
                            pickerButtonType: PickerButtonType.text,
                            onTap: (List<PickerDataModel> selectList) async{
                              if (selectList.isNotEmpty){
                                await controller.eamRoleOnChanged(selectList[0]);
                              }
                              else {
                                await controller.eamRoleOnChanged(PickerDataModel());
                              }
                            },
                            buttonStyle: ButtonStyle(
                                padding: WidgetStateProperty.all(EdgeInsets.zero),
                                maximumSize: WidgetStateProperty.all(
                                    const Size(110, 48)
                                ),
                                minimumSize: WidgetStateProperty.all(
                                    const Size(110, 48)
                                )
                            ),
                            child: Text(
                              '设备组：${_.eamRoleAdapter?.dataList.where(
                                      (element) => element.isSelected).map(
                                      (e) => e.code).join(',') ?? ''}',
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ///车间筛选
                          PickerButtonWidget(
                            adapter: _.departmentAdapter,
                            pickerChoiceType: PickerChoiceType.checkboxListTile,
                            pickerButtonType: PickerButtonType.text,
                            onTap: (List<PickerDataModel> selectList) async{
                              if (selectList.isNotEmpty){
                                await controller.depOnChanged(selectList[0]);
                              }
                              else {
                                await controller.depOnChanged(PickerDataModel());
                              }
                            },
                            buttonStyle: ButtonStyle(
                                padding: WidgetStateProperty.all(EdgeInsets.zero),
                                maximumSize: WidgetStateProperty.all(const Size(110, 48)),
                                minimumSize: WidgetStateProperty.all(const Size(110, 48))
                            ),
                            child: Text(
                              '车间：${_.departmentAdapter?.dataList.where(
                                      (element) => element.isSelected).map(
                                      (e) => e.code).join(',') ?? ''}',
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_.isDataByScan)
                            _.resetScanWidget(context),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 50,
                                width: _.isSearchWidgetOpen
                                    ? 230
                                    : 50,
                                child: TextField(
                                  controller: _.searchTC,
                                  focusNode: _.searchFN,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  onChanged: (String? string) async{
                                    controller.searchTCOnChanged();
                                  },
                                  decoration: InputDecoration(
                                    hintText: AppConfig.qualityInspectionSearchTypeList[_.searchTypeIndex].title,
                                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle?.copyWith(
                                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                    ),
                                    contentPadding: kIsWeb || GetPlatform.isWindows
                                        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
                                        : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                                      color: Theme.of(context).inputDecorationTheme.iconColor,
                                    ),
                                    suffixIcon: _.searchTC.text.isEmpty ? null : MineIconButton(
                                      icon: Icons.cancel,
                                      iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                                      tooltip: '清空',
                                      onPressed: () async{
                                        await controller.searchTCClear();
                                      },
                                    ),
                                    enabledBorder: _.isSearchWidgetOpen
                                        ? null
                                        : const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                                  ),
                                ),
                              ),
                              if (_.isSearchWidgetOpen)
                                const SizedBox(width: 4,),
                              if (_.isSearchWidgetOpen)
                                FilledButton(
                                  onPressed: () async{
                                    await controller.searchTCOnSearch();
                                  },
                                  style: ButtonStyle(
                                    minimumSize: WidgetStateProperty.all(
                                        kIsWeb || GetPlatform.isWindows
                                            ? const Size(80, 50)
                                            : const Size(80, 46)
                                    ),
                                  ),
                                  child: Text(
                                    '查询',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                    ///新增自定义的检验单
                    MineIconButton(
                      onPressed: () async {
                        await controller.generateCustomCheckVoucher();
                      },
                      margin: kIsWeb || GetPlatform.isWindows
                          ? const EdgeInsets.only(top: 9)
                          : const EdgeInsets.only(),
                      tooltip: '派工单新增检验单',
                      icon: Icons.library_books,
                      iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    ),
                    const SizedBox(width: 6,),
                    MineIconButton(
                      onPressed: () async {
                        await controller.settingOnTap();
                      },
                      margin: kIsWeb || GetPlatform.isWindows
                          ? const EdgeInsets.only(top: 9)
                          : const EdgeInsets.only(),
                      tooltip: '设置',
                      icon: Icons.settings,
                      iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    ),
                    const SizedBox(width: 6,),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4,),

          ///列表主内容
          Expanded(
            child: dataListWidget(context, _),
          ),
          const SizedBox(height: 4,),

          ///总记录数 翻页
          Row(
            children: [
              const SizedBox(width: 4,),
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
              const SizedBox(width: 4,),
            ],
          )
        ],
      ),
    );
  }

  Widget dataListWidget(BuildContext context, QualityInspectionController _){
    if (_.selectedTaskCategoryModel.sign == 1){ ///来料检验
      switch (_.selectedTaskSignModel.sign){
        case 0: ///待检验
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
              itemCount: _.qmInspectList.length,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (BuildContext context, int index){
                QMInspectListModel item = _.qmInspectList[index];
                return qmInspectItem(context, _, item);
              },
            ),
          );
        case 1: ///待判定
        case 256: ///已检验
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
              itemCount: _.qmCheckVoucherList.length,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (BuildContext context, int index){
                QMCheckVoucherModel item = _.qmCheckVoucherList[index];
                return qmCheckVoucherItem(context, _, item);
              },
            ),
          );
        default:
          return Text(
            '数据错误',
            style: Theme.of(context).textTheme.bodyLarge,
          );
      }
    }
    switch (_.selectedTaskSignModel.sign){
      case 0: ///待检验
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
            itemCount: _.inspectList.length,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (BuildContext context, int index){
              MoInspectModel item = _.inspectList[index];
              return inspectItem(context, _, item);
            },
          ),
        );
      case 1: ///待判定
      case 256: ///已检验
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
            itemCount: _.checkVoucherList.length,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (BuildContext context, int index){
              MoCheckVoucherModel item = _.checkVoucherList[index];
              return checkVoucherItem(context, _, item);
            },
          ),
        );
      default:
        return Text(
          '数据错误',
          style: Theme.of(context).textTheme.bodyLarge,
        );
    }
  }

  Widget inspectItem(BuildContext context, QualityInspectionController _, MoInspectModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onDoubleTap: () async{
            await controller.itemOnDoubleTap(item);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ///附件查看查看
                    MineIconButton(
                      onPressed: () async{
                        await controller.getAttach(item);
                      },
                      tooltip: '检验方案附件',
                      icon: Icons.picture_as_pdf_outlined,
                      iconSize: 60,
                      iconColor: Theme.of(context).colorScheme.primary,
                      //padding: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  '【${item.invName ?? ''}】'
                                      '${item.deviceName ?? ''}'
                                      ' ${item.engineerFigNo ?? ''}',
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8,),

                              if (item.opId != null && item.opId!.isNotEmpty)
                                TextButton(
                                  onPressed: () async{
                                    await controller.getOpAttach(item);
                                  },
                                  style: ButtonStyle(
                                    minimumSize: WidgetStateProperty.all(
                                        kIsWeb || GetPlatform.isWindows
                                            ? const Size(85, 50)
                                            : const Size(85, 40)
                                    )
                                  ),
                                  child: Text(
                                    '工序图纸',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (item.opId != null && item.opId!.isNotEmpty)
                                const SizedBox(width: 2,),

                              if (item.invId != null && item.invId!.isNotEmpty)
                                TextButton(
                                  onPressed: () async{
                                    await controller.getInvAttach(item);
                                  },
                                  style: ButtonStyle(
                                    minimumSize: WidgetStateProperty.all(
                                        kIsWeb || GetPlatform.isWindows
                                            ? const Size(85, 50)
                                            : const Size(85, 40)
                                    )
                                  ),
                                  child: Text(
                                    '产品附件',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (item.invId != null && item.invId!.isNotEmpty)
                                const SizedBox(width: 8,),

                              Text(
                                SignColorUtil().getIPQCStatus(item.sign ?? 0, item.category ?? 0, type: MoInspectSign),
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: SignColorUtil().getIPQCSignColor(item.sign ?? 0, type: MoInspectSign),
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                              const SizedBox(width: 4,),

                              TextButton(
                                onPressed: () async{
                                  await controller.itemOnDoubleTap(item);
                                },
                                style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all(
                                      kIsWeb || GetPlatform.isWindows
                                          ? const Size(60, 50)
                                          : const Size(60, 40)
                                  )
                                ),
                                child: Text(
                                  '详情',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              const SizedBox(width: 2,),

                              TextButton(
                                onPressed: () async {
                                  await controller.itemExpandedOnChanged(item);
                                },
                                style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all(
                                      kIsWeb || GetPlatform.isWindows
                                          ? const Size(75, 50)
                                          : const Size(75, 40)
                                  )
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 4,),
                                    Text(
                                      item.isExpanded ? '收起' : '展开',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    AnimatedRotation(
                                        turns: item.isExpanded ? 0.5 : 0,
                                        duration: const Duration(milliseconds: 100),
                                        child: Icon(
                                          Icons.arrow_drop_down,
                                          color: Theme.of(context).textTheme.bodyLarge!.color,
                                          size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            runSpacing: 4, spacing: 6,
                            children: inspectFirstList(context, _, item),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: !item.isExpanded ? const SizedBox.shrink() : Wrap(
                    runSpacing: 4, spacing: 6,
                    children: inspectSecondList(context, _, item),
                  ),
                  crossFadeState: item.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  List<Widget> inspectFirstList(BuildContext context, QualityInspectionController _, MoInspectModel item){
    List<Widget> list = [];
    list.add(
        inspectItemWidget(_, item: item, title: '任务单号', content: item.orderCode ?? '')
    );
    list.add(
        inspectItemWidget(_, item: item, title: '工艺名称', content: item.opName ?? '')
    );
    list.add(
        inspectItemWidget(_, item: item, title: '操作人员', content: item.personName ?? '')
    );
    list.add(
        inspectItemWidget(
          _, item: item, title: '报检数量',
          content: NumFormatUtil.qtyFormatConverter((item.quantity ?? 0).toString())
        )
    );
    list.add(
        inspectItemWidget(
            _, item: item,
            title: '报检日期',
            content: DateUtil.getDateStrByDateTime(item.processDate,
                format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':') ?? ''
        )
    );
    return list;
  }
  List<Widget> inspectSecondList(BuildContext context, QualityInspectionController _, MoInspectModel item){
    List<Widget> list = [];
    list.add(
        inspectItemWidget(_, item: item, title: '工艺说明', content: item.opDescription)
    );
    //region
    if (item.isFree1 == 1) {
      list.add(
          inspectItemWidget(
            _, item: item,
            title: _.dataService.userDefMap['Free1']?.defCaption ?? '',
            content: item.free1 ?? ''
          )
      );
    }
    if (item.isFree2 == 1) {
      list.add(
          inspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free2']?.defCaption ?? '',
              content: item.free2 ?? ''
          )
      );
    }
    if (item.isFree3 == 1) {
      list.add(
          inspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free3']?.defCaption ?? '',
              content: item.free3 ?? ''
          )
      );
    }
    if (item.isFree4 == 1) {
      list.add(
          inspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free4']?.defCaption ?? '',
              content: item.free4 ?? ''
          )
      );
    }
    if (item.isFree5 == 1) {
      list.add(
          inspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free5']?.defCaption ?? '',
              content: item.free5 ?? ''
          )
      );
    }
    if (item.isFree6 == 1) {
      list.add(
          inspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free6']?.defCaption ?? '',
              content: item.free6 ?? ''
          )
      );
    }
    if (item.isFree7 == 1) {
      list.add(
          inspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free7']?.defCaption ?? '',
              content: item.free7 ?? ''
          )
      );
    }
    if (item.isFree8 == 1) {
      list.add(
          inspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free8']?.defCaption ?? '',
              content: item.free8 ?? ''
          )
      );
    }
    if (item.isFree9 == 1) {
      list.add(
          inspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free9']?.defCaption ?? '',
              content: item.free9 ?? ''
          )
      );
    }
    if (item.isFree10 == 1) {
      list.add(
          inspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free10']?.defCaption ?? '',
              content: item.free10 ?? ''
          )
      );
    }
    //endregion
    return list;
  }
  Widget inspectItemWidget(QualityInspectionController _, {required String title, required String content, Color? contentColor, required MoInspectModel item}){
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: 310,
      titleWidth: 100,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
      contentStyle: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
          color: contentColor
      ),
      onPress: () async{  },
    );
  }

  Widget checkVoucherItem(BuildContext context, QualityInspectionController _, MoCheckVoucherModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onDoubleTap: () async{
            await controller.itemOnDoubleTap(item);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ///附件查看查看
                    MineIconButton(
                      onPressed: () async{
                        await controller.getAttach(item);
                      },
                      tooltip: '检验方案附件',
                      icon: Icons.picture_as_pdf_outlined,
                      iconSize: 60,
                      iconColor: Theme.of(context).colorScheme.primary,
                      //padding: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  '【${item.invName ?? ''}】'
                                      '${item.deviceName ?? ''}'
                                      ' ${item.engineerFigNo ?? ''}',
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8,),

                              if (item.opId != null && item.opId!.isNotEmpty)
                                TextButton(
                                  onPressed: () async{
                                    await controller.getOpAttach(item);
                                  },
                                  style: ButtonStyle(
                                      minimumSize: WidgetStateProperty.all(
                                          kIsWeb || GetPlatform.isWindows
                                              ? const Size(85, 50)
                                              : const Size(85, 40)
                                      )
                                  ),
                                  child: Text(
                                    '工序图纸',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (item.opId != null && item.opId!.isNotEmpty)
                                const SizedBox(width: 2,),

                              if (item.invId != null && item.invId!.isNotEmpty)
                                TextButton(
                                  onPressed: () async{
                                    await controller.getInvAttach(item);
                                  },
                                  style: ButtonStyle(
                                      minimumSize: WidgetStateProperty.all(
                                          kIsWeb || GetPlatform.isWindows
                                              ? const Size(85, 50)
                                              : const Size(85, 40)
                                      )
                                  ),
                                  child: Text(
                                    '产品附件',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (item.invId != null && item.invId!.isNotEmpty)
                                const SizedBox(width: 8,),

                              Text(
                                SignColorUtil().getIPQCStatus(item.sign ?? 0, item.category ?? 0),
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: SignColorUtil().getIPQCSignColor(item.sign ?? 0),
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                              const SizedBox(width: 4,),

                              if (_.selectedTaskCategoryModel.sign == 1 || _.selectedTaskCategoryModel.sign == 16)
                                FilledButton(
                                  onPressed: () async{
                                    await controller.deleteCheckVoucher(item);
                                  },
                                  style: ButtonStyle(
                                      minimumSize: WidgetStateProperty.all(
                                          kIsWeb || GetPlatform.isWindows
                                              ? const Size(64, 44)
                                              : const Size(64, 40)
                                      ),
                                      backgroundColor: WidgetStateProperty.all(
                                          Theme.of(context).colorScheme.primaryContainer
                                      )
                                  ),
                                  child: Text(
                                    '删除',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              if (_.selectedTaskCategoryModel.sign == 1 || _.selectedTaskCategoryModel.sign == 16)
                                const SizedBox(width: 2,),

                              TextButton(
                                onPressed: () async{
                                  await controller.itemOnDoubleTap(item);
                                },
                                style: ButtonStyle(
                                    minimumSize: WidgetStateProperty.all(
                                        kIsWeb || GetPlatform.isWindows
                                            ? const Size(60, 50)
                                            : const Size(60, 40)
                                    )
                                ),
                                child: Text(
                                  '详情',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              const SizedBox(width: 2,),

                              TextButton(
                                onPressed: () async {
                                  await controller.itemExpandedOnChanged(item);
                                },
                                style: ButtonStyle(
                                    minimumSize: WidgetStateProperty.all(
                                        kIsWeb || GetPlatform.isWindows
                                            ? const Size(75, 50)
                                            : const Size(75, 40)
                                    )
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(width: 4,),
                                    Text(
                                      item.isExpanded ? '收起' : '展开',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    AnimatedRotation(
                                        turns: item.isExpanded ? 0.5 : 0,
                                        duration: const Duration(milliseconds: 100),
                                        child: Icon(
                                          Icons.arrow_drop_down,
                                          color: Theme.of(context).textTheme.bodyLarge!.color,
                                          size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            runSpacing: 4, spacing: 6,
                            children: checkVoucherFirstList(context, _, item),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: !item.isExpanded ? const SizedBox.shrink() : Wrap(
                    runSpacing: 4, spacing: 6,
                    children: checkVoucherSecondList(context, _, item),
                  ),
                  crossFadeState: item.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  List<Widget> checkVoucherFirstList(BuildContext context, QualityInspectionController _, MoCheckVoucherModel item){
    List<Widget> list = [];
    list.add(
        checkVoucherItemWidget(_, item: item, title: '任务单号', content: item.orderCode ?? '')
    );
    list.add(
        checkVoucherItemWidget(_, item: item, title: '派工单号', content: item.taskCode ?? '')
    );
    list.add(
        checkVoucherItemWidget(_, item: item, title: '工艺名称', content: item.opName ?? '')
    );
    list.add(
        checkVoucherItemWidget(_, item: item, title: '检验人员', content: item.inspector ?? '')
    );
    list.add(
        checkVoucherItemWidget(_, item: item, title: '操作人员', content: item.personName ?? '')
    );

    if (item.progid == 811021){ ///首巡末自检验
      list.add(
          checkVoucherItemWidget(
              _, item: item, title: '检验件数',
              content: NumFormatUtil.qtyFormatConverter((item.num ?? 0).toString())
          )
      );
      list.add(
          checkVoucherItemWidget(
              _, item: item, title: '报检数量',
              content: NumFormatUtil.qtyFormatConverter((item.quantity ?? 0).toString())
          )
      );
    }
    else if (item.progid == 811032){ ///完检
      list.add(
          checkVoucherItemWidget(
              _, item: item, title: '报检数量',
              content: NumFormatUtil.qtyFormatConverter((item.inspectionQty ?? 0).toString())
          )
      );
      list.add(
          checkVoucherItemWidget(
              _, item: item, title: '遗失数量',
              content: NumFormatUtil.qtyFormatConverter((item.lostQty ?? 0).toString())
          )
      );
    }

    list.add(
        checkVoucherItemWidget(
            _, item: item,
            title: '检验日期',
            content: DateUtil.getDateStrByDateTime(item.checkDate,
                format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':') ?? ''
        )
    );
    return list;
  }
  List<Widget> checkVoucherSecondList(BuildContext context, QualityInspectionController _, MoCheckVoucherModel item){
    List<Widget> list = [];
    list.add(
        checkVoucherItemWidget(_, item: item, title: '工艺说明', content: item.opDescription)
    );
    //region
    if (item.isFree1 == 1) {
      list.add(
          checkVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free1']?.defCaption ?? '',
              content: item.free1 ?? ''
          )
      );
    }
    if (item.isFree2 == 1) {
      list.add(
          checkVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free2']?.defCaption ?? '',
              content: item.free2 ?? ''
          )
      );
    }
    if (item.isFree3 == 1) {
      list.add(
          checkVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free3']?.defCaption ?? '',
              content: item.free3 ?? ''
          )
      );
    }
    if (item.isFree4 == 1) {
      list.add(
          checkVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free4']?.defCaption ?? '',
              content: item.free4 ?? ''
          )
      );
    }
    if (item.isFree5 == 1) {
      list.add(
          checkVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free5']?.defCaption ?? '',
              content: item.free5 ?? ''
          )
      );
    }
    if (item.isFree6 == 1) {
      list.add(
          checkVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free6']?.defCaption ?? '',
              content: item.free6 ?? ''
          )
      );
    }
    if (item.isFree7 == 1) {
      list.add(
          checkVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free7']?.defCaption ?? '',
              content: item.free7 ?? ''
          )
      );
    }
    if (item.isFree8 == 1) {
      list.add(
          checkVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free8']?.defCaption ?? '',
              content: item.free8 ?? ''
          )
      );
    }
    if (item.isFree9 == 1) {
      list.add(
          checkVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free9']?.defCaption ?? '',
              content: item.free9 ?? ''
          )
      );
    }
    if (item.isFree10 == 1) {
      list.add(
          checkVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free10']?.defCaption ?? '',
              content: item.free10 ?? ''
          )
      );
    }
    //endregion
    return list;
  }
  Widget checkVoucherItemWidget(QualityInspectionController _, {required String title, required String content, Color? contentColor, required MoCheckVoucherModel item}){
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: 310,
      titleWidth: 100,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
      contentStyle: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
          color: contentColor
      ),
      onPress: () async{  },
    );
  }

  Widget qmInspectItem(BuildContext context, QualityInspectionController _, QMInspectListModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onDoubleTap: () async{
            await controller.itemOnDoubleTap(item);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ///附件查看查看
                    MineIconButton(
                      onPressed: () async{
                        await controller.getAttach(item);
                      },
                      tooltip: '检验方案附件',
                      icon: Icons.picture_as_pdf_outlined,
                      iconSize: 60,
                      iconColor: Theme.of(context).colorScheme.primary,
                      //padding: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  '【${item.invName ?? ''}】'
                                      ' ${item.engineerFigNo ?? ''}',
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8,),

                              if (item.invID != null && item.invID!.isNotEmpty)
                                TextButton(
                                  onPressed: () async{
                                    await controller.getInvAttach(item);
                                  },
                                  style: ButtonStyle(
                                      minimumSize: WidgetStateProperty.all(
                                          kIsWeb || GetPlatform.isWindows
                                              ? const Size(85, 50)
                                              : const Size(85, 40)
                                      )
                                  ),
                                  child: Text(
                                    '产品附件',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (item.invID != null && item.invID!.isNotEmpty)
                                const SizedBox(width: 8,),

                              Text(
                                '待检验',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: SignColorUtil().getIPQCSignColor(MoInspectSign.djy.sign, type: MoInspectSign),
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                              const SizedBox(width: 4,),

                              TextButton(
                                onPressed: () async{
                                  await controller.itemOnDoubleTap(item);
                                },
                                style: ButtonStyle(
                                    minimumSize: WidgetStateProperty.all(
                                        kIsWeb || GetPlatform.isWindows
                                            ? const Size(60, 50)
                                            : const Size(60, 40)
                                    )
                                ),
                                child: Text(
                                  '详情',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              const SizedBox(width: 2,),

                              TextButton(
                                onPressed: () async{
                                  await controller.itemExpandedOnChanged(item);
                                },
                                style: ButtonStyle(
                                    minimumSize: WidgetStateProperty.all(
                                        kIsWeb || GetPlatform.isWindows
                                            ? const Size(75, 50)
                                            : const Size(75, 40)
                                    )
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 4,),
                                    Text(
                                      item.isExpanded ? '收起' : '展开',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    AnimatedRotation(
                                        turns: item.isExpanded ? 0.5 : 0,
                                        duration: const Duration(milliseconds: 100),
                                        child: Icon(
                                          Icons.arrow_drop_down,
                                          color: Theme.of(context).textTheme.bodyLarge!.color,
                                          size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            runSpacing: 4, spacing: 6,
                            children: qmInspectFirstList(context, _, item),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: !item.isExpanded ? const SizedBox.shrink() : Wrap(
                    runSpacing: 4, spacing: 6,
                    children: qmInspectSecondList(context, _, item),
                  ),
                  crossFadeState: item.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  List<Widget> qmInspectFirstList(BuildContext context, QualityInspectionController _, QMInspectListModel item){
    List<Widget> list = [];
    list.add(
        qmInspectItemWidget(_, item: item, title: '单据类型', content: item.vouchType ?? '')
    );
    list.add(
        qmInspectItemWidget(_, item: item, title: '供应商', content: item.venName ?? '')
    );
    list.add(
        qmInspectItemWidget(_, item: item, title: '操作人员', content: item.maker ?? '')
    );
    list.add(
        qmInspectItemWidget(
            _, item: item, title: '报检数量',
            content: NumFormatUtil.qtyFormatConverter((item.quantity ?? 0).toString())
        )
    );
    list.add(
        qmInspectItemWidget(
            _, item: item,
            title: '报检日期',
            content: DateUtil.getDateStrByDateTime(item.billDate,
                format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':') ?? ''
        )
    );
    return list;
  }
  List<Widget> qmInspectSecondList(BuildContext context, QualityInspectionController _, QMInspectListModel item){
    List<Widget> list = [];
    //region
    if (item.isFree1 == 1) {
      list.add(
          qmInspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free1']?.defCaption ?? '',
              content: item.free1 ?? ''
          )
      );
    }
    if (item.isFree2 == 1) {
      list.add(
          qmInspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free2']?.defCaption ?? '',
              content: item.free2 ?? ''
          )
      );
    }
    if (item.isFree3 == 1) {
      list.add(
          qmInspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free3']?.defCaption ?? '',
              content: item.free3 ?? ''
          )
      );
    }
    /*if (item.isFree4 == 1) {
      list.add(
          qmInspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free4']?.defCaption ?? '',
              content: item.free4 ?? ''
          )
      );
    }
    if (item.isFree5 == 1) {
      list.add(
          qmInspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free5']?.defCaption ?? '',
              content: item.free5 ?? ''
          )
      );
    }
    if (item.isFree6 == 1) {
      list.add(
          qmInspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free6']?.defCaption ?? '',
              content: item.free6 ?? ''
          )
      );
    }
    if (item.isFree7 == 1) {
      list.add(
          qmInspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free7']?.defCaption ?? '',
              content: item.free7 ?? ''
          )
      );
    }
    if (item.isFree8 == 1) {
      list.add(
          qmInspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free8']?.defCaption ?? '',
              content: item.free8 ?? ''
          )
      );
    }
    if (item.isFree9 == 1) {
      list.add(
          qmInspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free9']?.defCaption ?? '',
              content: item.free9 ?? ''
          )
      );
    }
    if (item.isFree10 == 1) {
      list.add(
          qmInspectItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free10']?.defCaption ?? '',
              content: item.free10 ?? ''
          )
      );
    }*/
    //endregion
    return list;
  }
  Widget qmInspectItemWidget(QualityInspectionController _, {required String title, required String content, Color? contentColor, required QMInspectListModel item}){
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: 310,
      titleWidth: 100,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
      contentStyle: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
          color: contentColor
      ),
      onPress: () async{  },
    );
  }

  Widget qmCheckVoucherItem(BuildContext context, QualityInspectionController _, QMCheckVoucherModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onDoubleTap: () async{
            await controller.itemOnDoubleTap(item);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ///附件查看查看
                    MineIconButton(
                      onPressed: () async{
                        await controller.getAttach(item);
                      },
                      tooltip: '检验方案附件',
                      icon: Icons.picture_as_pdf_outlined,
                      iconSize: 60,
                      iconColor: Theme.of(context).colorScheme.primary,
                      //padding: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  '【${item.invName ?? ''}】'
                                      ' ${item.engineerFigNo ?? ''}',
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8,),


                              if (item.invID != null && item.invID!.isNotEmpty)
                                TextButton(
                                  onPressed: () async{
                                    await controller.getInvAttach(item);
                                  },
                                  style: ButtonStyle(
                                      minimumSize: WidgetStateProperty.all(
                                          kIsWeb || GetPlatform.isWindows
                                              ? const Size(85, 50)
                                              : const Size(85, 40)
                                      )
                                  ),
                                  child: Text(
                                    '产品附件',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (item.invID != null && item.invID!.isNotEmpty)
                                const SizedBox(width: 8,),

                              Text(
                                '已检验',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: SignColorUtil().getIPQCSignColor(MoCheckVoucherSign.ywg.sign),
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                              const SizedBox(width: 4,),

                              if (_.selectedTaskCategoryModel.sign == 1 || _.selectedTaskCategoryModel.sign == 16)
                                FilledButton(
                                  onPressed: () async{
                                    await controller.deleteCheckVoucher(item);
                                  },
                                  style: ButtonStyle(
                                      minimumSize: WidgetStateProperty.all(
                                          kIsWeb || GetPlatform.isWindows
                                              ? const Size(64, 44)
                                              : const Size(64, 40)
                                      ),
                                      backgroundColor: WidgetStateProperty.all(
                                          Theme.of(context).colorScheme.primaryContainer
                                      )
                                  ),
                                  child: Text(
                                    '删除',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              if (_.selectedTaskCategoryModel.sign == 1 || _.selectedTaskCategoryModel.sign == 16)
                                const SizedBox(width: 2,),

                              TextButton(
                                onPressed: () async{
                                  await controller.itemOnDoubleTap(item);
                                },
                                style: ButtonStyle(
                                    minimumSize: WidgetStateProperty.all(
                                        kIsWeb || GetPlatform.isWindows
                                            ? const Size(60, 50)
                                            : const Size(60, 40)
                                    )
                                ),
                                child: Text(
                                  '详情',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              const SizedBox(width: 2,),

                              TextButton(
                                onPressed: () async {
                                  await controller.itemExpandedOnChanged(item);
                                },
                                style: ButtonStyle(
                                    minimumSize: WidgetStateProperty.all(
                                        kIsWeb || GetPlatform.isWindows
                                            ? const Size(75, 50)
                                            : const Size(75, 40)
                                    )
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(width: 4,),
                                    Text(
                                      item.isExpanded ? '收起' : '展开',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    AnimatedRotation(
                                        turns: item.isExpanded ? 0.5 : 0,
                                        duration: const Duration(milliseconds: 100),
                                        child: Icon(
                                          Icons.arrow_drop_down,
                                          color: Theme.of(context).textTheme.bodyLarge!.color,
                                          size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            runSpacing: 4, spacing: 6,
                            children: qmCheckVoucherFirstList(context, _, item),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: !item.isExpanded ? const SizedBox.shrink() : Wrap(
                    runSpacing: 4, spacing: 6,
                    children: qmCheckVoucherSecondList(context, _, item),
                  ),
                  crossFadeState: item.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  List<Widget> qmCheckVoucherFirstList(BuildContext context, QualityInspectionController _, QMCheckVoucherModel item){
    List<Widget> list = [];
    list.add(
        qmCheckVoucherItemWidget(_, item: item, title: '单据类型', content: item.vouchType ?? '')
    );
    list.add(
        qmCheckVoucherItemWidget(_, item: item, title: '供应商', content: item.venName ?? '')
    );
    list.add(
        qmCheckVoucherItemWidget(_, item: item, title: '检验人员', content: item.personName ?? '')
    );
    list.add(
        qmCheckVoucherItemWidget(_, item: item, title: '操作人员', content: item.inspectPerson ?? '')
    );
    list.add(
        qmCheckVoucherItemWidget(
            _, item: item, title: '检验数量',
            content: NumFormatUtil.qtyFormatConverter((item.dTQuantity ?? 0).toString())
        )
    );
    list.add(
        qmCheckVoucherItemWidget(
            _, item: item, title: '报检数量',
            content: NumFormatUtil.qtyFormatConverter((item.quantity ?? 0).toString())
        )
    );
    list.add(
        qmCheckVoucherItemWidget(
            _, item: item,
            title: '检验日期',
            content: DateUtil.getDateStrByDateTime(item.billDate,
                format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':') ?? ''
        )
    );
    return list;
  }
  List<Widget> qmCheckVoucherSecondList(BuildContext context, QualityInspectionController _, QMCheckVoucherModel item){
    List<Widget> list = [];
    //region
    if (item.isFree1 == 1) {
      list.add(
          qmCheckVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free1']?.defCaption ?? '',
              content: item.free1 ?? ''
          )
      );
    }
    if (item.isFree2 == 1) {
      list.add(
          qmCheckVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free2']?.defCaption ?? '',
              content: item.free2 ?? ''
          )
      );
    }
    if (item.isFree3 == 1) {
      list.add(
          qmCheckVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free3']?.defCaption ?? '',
              content: item.free3 ?? ''
          )
      );
    }
    /*if (item.isFree4 == 1) {
      list.add(
          qmCheckVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free4']?.defCaption ?? '',
              content: item.free4 ?? ''
          )
      );
    }
    if (item.isFree5 == 1) {
      list.add(
          qmCheckVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free5']?.defCaption ?? '',
              content: item.free5 ?? ''
          )
      );
    }
    if (item.isFree6 == 1) {
      list.add(
          qmCheckVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free6']?.defCaption ?? '',
              content: item.free6 ?? ''
          )
      );
    }
    if (item.isFree7 == 1) {
      list.add(
          qmCheckVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free7']?.defCaption ?? '',
              content: item.free7 ?? ''
          )
      );
    }
    if (item.isFree8 == 1) {
      list.add(
          qmCheckVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free8']?.defCaption ?? '',
              content: item.free8 ?? ''
          )
      );
    }
    if (item.isFree9 == 1) {
      list.add(
          qmCheckVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free9']?.defCaption ?? '',
              content: item.free9 ?? ''
          )
      );
    }
    if (item.isFree10 == 1) {
      list.add(
          qmCheckVoucherItemWidget(
              _, item: item,
              title: _.dataService.userDefMap['Free10']?.defCaption ?? '',
              content: item.free10 ?? ''
          )
      );
    }*/
    //endregion
    return list;
  }
  Widget qmCheckVoucherItemWidget(QualityInspectionController _, {required String title, required String content, Color? contentColor, required QMCheckVoucherModel item}){
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: 310,
      titleWidth: 100,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
      contentStyle: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
          color: contentColor
      ),
      onPress: () async{  },
    );
  }

}