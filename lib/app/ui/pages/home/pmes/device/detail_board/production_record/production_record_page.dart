
import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/production_record/production_record_controller.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///生产记录 670006
class ProductionRecordPage extends BaseFormWithPageDataPage<ProductionRecordController, MoProcessTeamData>{

  @override
  Widget headWidget(BuildContext context, ProductionRecordController _) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _.dateFilterInputWidget(context),
        ],
      ),
    );
  }

  @override
  Widget dataItem(BuildContext context, ProductionRecordController _, MoProcessTeamData item){
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
            elevation: 1,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '【${item.taskCode ?? ''}】${item.invName ?? ''}',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                          const SizedBox(width: 8,),

                          TextButton(
                            onPressed: (){
                              controller.itemExpandedOnChanged(item);
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
                          children: pressTeamDataContentFirstList(context, item),
                        ),
                        secondChild: !item.isExpanded ? const SizedBox.shrink() : Wrap(
                          runSpacing: 4, spacing: 6,
                          children: pressTeamDataContentSecondList(context, item),
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
  List<Widget> pressTeamDataContentFirstList(BuildContext context, MoProcessTeamData item) {
    ///班次良品率
    double standardNumPercent = (item.submitQty == null || item.submitQty == 0)
        ? 0 : item.standardNum! / item.submitQty!;

    List<Widget> list = [];
    list.add(
        pressTeamDataItemWidget(context, item: item, title: '订单编号', content: '${item.soCode ?? ''}',)
    );
    list.add(
        pressTeamDataItemWidget(context, item: item, title: '模具名称', content: '${item.mouldName ?? ''}',)
    );
    list.add(
        pressTeamDataItemWidget(context, item: item, title: '班次名称', content: '${item.teamName ?? ''}',)
    );
    list.add(
        pressTeamDataItemWidget(context, item: item, title: '生产人员', content: '${item.empPerson ?? ''}',)
    );
    list.add(
        pressTeamDataItemWidget(context, item: item, title: '班次良品率', content: '${(standardNumPercent * 100).toStringAsFixed(2)}%',)
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '实际单重',
            content: '${NumFormatUtil.qtyFormatConverter((item.weight ?? 0).toString(), decimal: 4)}g'
        )
    );
    return list;
  }
  List<Widget> pressTeamDataContentSecondList(BuildContext context, MoProcessTeamData item) {
    List<Widget> list = [];

    list.addAll(pressTeamDataContentFirstList(context, item));

    list.add(
        pressTeamDataItemWidget(context, item: item, title: '任务编号', content: '${item.orderCode ?? ''}',)
    );
    list.add(
        pressTeamDataItemWidget(context, item: item, title: '产品编号', content: '${item.invCode ?? ''}',)
    );
    list.add(
        pressTeamDataItemWidget(context, item: item, title: '模具编号', content: '${item.mouldCode ?? ''}',)
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '生产数量',
            content: NumFormatUtil.qtyFormatConverter((item.proQty ?? 0).toString())
        )
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '合模数量',
            content: NumFormatUtil.qtyFormatConverter((item.proTicks ?? 0).toString())
        )
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '任务数量',
            content: NumFormatUtil.qtyFormatConverter((item.assignQty ?? 0).toString())
        )
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '班次报工差额',
            content: NumFormatUtil.qtyFormatConverter((item.remindStockInputNum ?? 0).toString())
        )
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '任务剩余生产数',
            content: NumFormatUtil.qtyFormatConverter((item.remindAssignQty ?? 0).toString())
        )
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '标准/实际模穴',
            content: '${(item.standOutput ?? 0).toStringAsFixed(0)}'
                '/${(item.realOutput ?? 0).toStringAsFixed(0)}'
        )
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '标准/平均周期',
            content: '${NumFormatUtil.qtyFormatConverter((item.standPeriod ?? 0).toStringAsFixed(2))}'
                '/${NumFormatUtil.qtyFormatConverter((item.period ?? 0).toStringAsFixed(2))}'
        )
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '生产日期',
            content: DateUtil.getDateStrByDateTime(item.processDate,
                format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':') ?? ''
        )
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '实际开工日期',
            content: DateUtil.getDateStrByDateTime(item.startDate,
                format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':') ?? ''
        )
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '实际完工日期',
            content: DateUtil.getDateStrByDateTime(item.finishDate,
                format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':') ?? ''
        )
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '报合格数',
            content: NumFormatUtil.qtyFormatConverter((item.standardNum ?? 0).toString())
        )
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '次品数量',
            content: NumFormatUtil.qtyFormatConverter((item.disabledQty ?? 0).toString())
        )
    );
    list.add(
        pressTeamDataItemWidget(
            context,
            item: item, title: '报产数量',
            content: NumFormatUtil.qtyFormatConverter((item.submitQty ?? 0).toString())
        )
    );
    list.add(
        pressTeamDataItemWidget(
          context,
            item: item, title: '标准单重',
            content: '${NumFormatUtil.qtyFormatConverter((item.invWeight ?? 0).toString(), decimal: 4)}g'
        )
    );
    return list;
  }
  Widget pressTeamDataItemWidget(BuildContext context, {
    required String title, required String content,
    Color? contentColor, required MoProcessTeamData item,
  }){
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: 310,
      titleWidth: 135,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      contentStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: contentColor
      ),
    );
  }

}