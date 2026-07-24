import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/submit_list/mo_mixture_submit_list_controller.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/command_bar.dart';
import 'package:desktop/app/ui/widget/prefix_text_field.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///拌料报工单列表 651073 OR 粉料报工单列表 651078
class MoMixtureSubmitListPage extends BaseFormWithPageDataPage<MoMixtureSubmitListController, MoMixSubmitModel>{

  @override
  Widget headWidget(BuildContext context, MoMixtureSubmitListController _) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints){
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 210,
                      child: CommandBar(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        primaryItems: _.commandBarList,
                      )
                    )
                  );
                },
              ),
            ),
            const SizedBox(width: 6,),

            dataReportItem1(
                title: '生产日期',
                customizeContent: PrefixTextField(
                  object: 3, height: 60, readOnly: true,
                  contentPadding: kIsWeb || GetPlatform.isWindows
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
                      : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  initText: _.startDate == null || _.endDate == null
                      ? ''
                      : '${DateUtil.formatDateTime(_.startDate.toString(), DateFormat.YEAR_MONTH_DAY)}'
                      '到'
                      '${DateUtil.formatDateTime(_.endDate.toString(), DateFormat.YEAR_MONTH_DAY)}',
                  valueOnChanged: (String string) async{
                    await controller.dateChanged(string);
                  },
                )
            ),
            const SizedBox(width: 6,),
          ],
        )
    );
  }

  @override
  Widget dataItem(BuildContext context, MoMixtureSubmitListController _, MoMixSubmitModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () async{
            await controller.submitOnSelected(item);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: item.isChoice,
                      onChanged: (bool? bool) async{
                        await controller.submitOnSelected(item);
                      },
                    ),
                    const SizedBox(width: 8,),
                    Expanded(
                      child: Text(
                        '【${item.billCode ?? ''}】${item.invName ?? ''}',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    const SizedBox(width: 8,),

                    TextButton(
                      onPressed: (){
                        controller.submitExpandedOnChanged(item);
                      },
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                            kIsWeb || GetPlatform.isWindows
                                ? const EdgeInsets.symmetric(vertical: 18, horizontal: 8)
                                : const EdgeInsets.symmetric(vertical: 8, horizontal: 8)
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.isExpanded ? '收起' : '展开',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(width: 2,),
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
                AnimatedCrossFade(
                  firstChild: item.isExpanded ? const SizedBox.shrink() : Wrap(
                    runSpacing: 4, spacing: 6,
                    children: submitItemContentFirstList(context, item),
                  ),
                  secondChild: !item.isExpanded ? const SizedBox.shrink() : Wrap(
                    runSpacing: 4, spacing: 6,
                    children: submitItemContentSecondList(context, item),
                  ),
                  crossFadeState: item.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          )
        )
      )
    );
  }
  List<Widget> submitItemContentFirstList(BuildContext context, MoMixSubmitModel item) {
    List<Widget> list = [];
    list.add(
        submitItemWidget(item: item, title: '材料批号', content: item.invBatch ?? '',)
    );
    list.add(
        submitItemWidget(item: item, title: '配方', content: item.formula ?? '',)
    );
    list.add(
        submitItemWidget(item: item, title: '色粉', content: item.toner ?? '',)
    );
    list.add(
        submitItemWidget(item: item, title: '生产人员', content: item.employee ?? '',)
    );
    list.add(
        submitItemWidget(
            item: item, title: '报工总重',
            content: NumFormatUtil.qtyFormatConverter((item.qty ?? 0).toString(), decimal: 2)
        )
    );
    list.add(
        submitItemWidget(
            item: item, title: '报工件数',
            content: NumFormatUtil.qtyFormatConverter((item.number ?? 0).toString())
        )
    );
    list.add(
        submitItemWidget(
            item: item, title: '报工包重',
            content: NumFormatUtil.qtyFormatConverter((item.boxQty ?? 0).toString(), decimal: 2)
        )
    );
    list.add(
        submitItemWidget(
            item: item, title: '单据日期',
            content: DateUtil.getDateStrByDateTime(item.billDate,
                format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':') ?? ''
        )
    );
    return list;
  }
  List<Widget> submitItemContentSecondList(BuildContext context, MoMixSubmitModel item) {
    var _ = Get.find<MoMixtureSubmitListController>();
    List<Widget> list = [];
    list.addAll(submitItemContentFirstList(context, item));
    list.add(
        submitItemWidget(item: item, title: '产品编号', content: item.productCode ?? '',)
    );
    list.add(
        submitItemWidget(item: item, title: '产品规格', content: item.productStd ?? '',)
    );
    list.add(
        submitItemWidget(item: item, title: '材料编码', content: item.invCode ?? '',)
    );
    list.add(
        submitItemWidget(item: item, title: '材料规格', content: item.invStd ?? '',)
    );
    list.add(
        submitItemWidget(item: item, title: '设备编号', content: item.deviceCode ?? '',)
    );
    list.add(
        submitItemWidget(item: item, title: '设备名称', content: item.deviceName ?? '',)
    );
    list.add(
        submitItemWidget(item: item, title: '设备简称', content: item.deviceAddCode ?? '',)
    );
    list.add(
        submitItemWidget(item: item, title: '${_.typeTitle}单号', content: item.moMixCode ?? '',)
    );
    list.add(
        submitItemWidget(item: item, title: '批次号', content: item.batch ?? '',)
    );
    return list;
  }
  Widget submitItemWidget({required String title, required String content, Color? contentColor, required MoMixSubmitModel item}){
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: 1000,
      titleWidth: 150,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
      contentStyle: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
          color: contentColor
      ),
      onPress: () async{
        await controller.submitOnSelected(item);
      },
    );
  }

  Widget dataReportItem1({required String title, required Widget customizeContent}){
    return TitleTextBoxWidget(
      title: title,
      customizeContent: customizeContent,
      titleWidth: 150, width: 550,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
  
}