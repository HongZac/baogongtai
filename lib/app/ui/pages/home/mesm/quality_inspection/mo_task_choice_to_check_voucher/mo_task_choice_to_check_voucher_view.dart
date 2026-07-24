import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/mo_task_choice_to_check_voucher/mo_task_choice_to_check_voucher_controller.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:desktop/app/utils/sign_color_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///质量巡检 - 派工单选择（新增自定义的检验单）
class MoTaskChoiceToCheckVoucherView extends BaseFormWithPageDataPage<MoTaskChoiceToCheckVoucherController, MoTaskModel> {



  @override
  Widget headWidget(BuildContext context, MoTaskChoiceToCheckVoucherController _) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 600, height: 50,
            child: TextField(
              controller: _.searchTC,
              focusNode: _.searchFN,
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: (String str){
                controller.searchTCOnChanged();
              },
              decoration: InputDecoration(
                hintText: '请填写产品图号/产品编号/产品名称/派工单号/员工编号，支持模糊查询',
                hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
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
              ),
            ),
          ),
          const SizedBox(width: 2,),
          MenuBar(
            style: MenuStyle(
              backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
              padding: WidgetStateProperty.all(EdgeInsets.zero)
            ),
            children: [
              SubmenuButton(
                menuChildren: _.searchBtnTypeMenuList,
                style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.zero)
                ),
                child: SizedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () async{
                          await controller.searchTCOnSearch();
                        },
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                              kIsWeb || GetPlatform.isWindows
                                  ? const EdgeInsets.only(top: 20, bottom: 20, left: 12)
                                  : const EdgeInsets.only(top: 13, bottom: 13, left: 12)
                          ),
                        ),
                        child: Text(
                          _.searchBtnTypeName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 48,
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Expanded(child: SizedBox.shrink()),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_.operationWayList.length, (index) {
              ChoiceChipModel item = _.operationWayList[index];
              return Material(
                child: InkWell(
                  onTap: (){
                    controller.checkVoucherTypeOnChanged(item);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioTheme(
                          data: const RadioThemeData(
                            splashRadius: 0,
                          ),
                          child: Radio(
                              value: item.keyName,
                              groupValue: _.checkVoucherType,
                              onChanged: (value){
                                controller.checkVoucherTypeOnChanged(item);
                              }
                          )
                      ),
                      Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: item.isSelected ? Theme.of(context).colorScheme.primary : null,
                          ), maxLines: 1, overflow: TextOverflow.ellipsis
                      ),
                      const SizedBox(width: 6,),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 16,),
        ],
      ),
    );
  }

  @override
  Widget emptyWidget(BuildContext context, MoTaskChoiceToCheckVoucherController _){
    if (_.searchTC.text.isNotEmpty){
      return const SizedBox.shrink();
    }
    return Container(
      alignment: Alignment.center,
      child: Text(
        '请先进行搜索！',
        style: Theme.of(context).textTheme.titleLarge,
      )
    );
  }

  @override
  Widget dataItem(BuildContext context, MoTaskChoiceToCheckVoucherController _, MoTaskModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () {
            controller.itemSelectedOnChanged(item);
          },
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: item.isChoice,
                          onChanged: (bool? bool) {
                            controller.itemSelectedOnChanged(item);
                          },
                        ),
                        const SizedBox(width: 8,),
                        Expanded(
                          child: SelectableText(
                            '【${item.invName ?? ''}】【${item.opName ?? ''}】${item.engineerFigNo ?? ''}',
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.w600
                            ),
                            onTap: () {
                              controller.itemSelectedOnChanged(item);
                            },
                          ),
                        ),
                        const SizedBox(width: 8,),

                        Text(
                          '${item.status}',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: SignColorUtil().getTaskSignColor(item.sign ?? 0),
                              fontWeight: FontWeight.w600
                          ),
                        ),
                        const SizedBox(width: 4,),

                        TextButton(
                          onPressed: (){
                            controller.taskItemExpandedOnChanged(item);
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
                      children: firstList(context, item),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: !item.isExpanded ? const SizedBox.shrink() : Wrap(
                    runSpacing: 4, spacing: 6,
                    children: secondList(context, item),
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

  List<Widget> firstList(BuildContext context, MoTaskModel item){
    List<Widget> list = [];
    list.add(
        itemWidget(item: item, title: '派工单号', content: item.taskCode ?? '')
    );
    list.add(
        itemWidget(
            item: item, title: '派工日期',
            content: DateUtil.getDateStrByDateTime(item.taskDate,
                format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':') ?? ''
        )
    );
    list.add(
        itemWidget(item: item, title: '产品编号', content: item.invCode ?? '')
    );
    list.add(
        itemWidget(item: item, title: '产品规格', content: item.invStd ?? '')
    );
    list.add(
        itemWidget(item: item, title: '机器名称', content: item.deviceName ?? '')
    );
    list.add(
        itemWidget(
            item: item, title: '工资定额',
            content: NumFormatUtil.qtyFormatConverter((item.pieceRate ?? 0).toString(), decimal: 2)
        )
    );
    return list;
  }
  List<Widget> secondList(BuildContext context, MoTaskModel item){
    List<Widget> list = [];
    list.add(
        itemWidget(item: item, title: '销售单号', content: item.soCode ?? '')
    );
    list.add(
        itemWidget(item: item, title: '需求跟踪号', content: item.mtoNo ?? '')
    );
    list.add(
        itemWidget(item: item, title: '生产单号', content: item.gDCode ?? '')
    );
    list.add(
        itemWidget(item: item, title: '任务单号', content: item.orderCode ?? '')
    );
    list.add(
        itemWidget(item: item, title: '产品编号', content: item.invCode ?? '')
    );
    list.add(
        itemWidget(item: item, title: '机器编号', content: item.deviceCode ?? '')
    );
    list.add(
        itemWidget(item: item, title: '生产车间', content: item.depName ?? '')
    );
    list.add(
        itemWidget(item: item, title: '包装规格', content: item.packingType ?? '')
    );
    list.add(
        itemWidget(
            item: item, title: '派工数量',
            content: NumFormatUtil.qtyFormatConverter((item.assignQty ?? 0).toString())
        )
    );
    list.add(
        itemWidget(
            item: item, title: '已生产数',
            content: NumFormatUtil.qtyFormatConverter((item.qualifiedQty ?? 0).toString())
        )
    );
    list.add(
        itemWidget(
            item: item, title: '已报产数',
            content: NumFormatUtil.qtyFormatConverter((item.submitQty ?? 0).toString())
        )
    );
    list.add(
        itemWidget(
            item: item, title: '次品数量',
            content: NumFormatUtil.qtyFormatConverter((item.disabledQty ?? 0).toString())
        )
    );
    list.add(
        itemWidget(item: item, title: '工序说明', content: item.opWorkDescription ?? '')
    );
    return list;
  }
  Widget itemWidget({double width = 310, required String title, required String content, Color? contentColor, required MoTaskModel item}){
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: width,
      titleWidth: 100,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
      contentStyle: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
        color: contentColor
      ),
      onPress: () {
        controller.itemSelectedOnChanged(item);
      },
    );
  }

}