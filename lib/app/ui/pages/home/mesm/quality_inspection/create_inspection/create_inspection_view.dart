import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/create_inspection/create_inspection_controller.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/prefix_text_field.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生成报检单（首巡末完自 检）
class CreateInspectionView extends BaseFormPage<CreateInspectionController> {

  @override
  Widget contentWidget(BuildContext context, CreateInspectionController _) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(),
            child: CardWidget(
              content: detailWidget(context, _),
            ),
          ),
          const SizedBox(height: 16,),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: dataReport(context, _),
            ),
          )
        ],
      ),
    );
  }

  Widget detailWidget(BuildContext context, CreateInspectionController _){
    return Container(
      height: 110,
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                '【${_.inspectModel.sourceCode ?? ''}】'
                    '${_.inspectModel.invName ?? ''}',
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
  List<Widget> detailList(BuildContext context, CreateInspectionController _) {
    List<Widget> list = [];
    list.add(
        detailItemWidget(
            context, _,
            title: '单据来源',
            content: _.sourceTitle,
        )
    );
    list.add(
        detailItemWidget(
          context, _,
          title: '检验类型',
          content: _.categoryTitle,
        )
    );
    list.add(
        detailItemWidget(
          context, _,
          title: '源单单号',
          content: _.inspectModel.sourceCode ?? '',
        )
    );
    list.add(
        detailItemWidget(
          context, _,
          title: '产品编号',
          content: _.inspectModel.invCode ?? '',
        )
    );
    list.add(
        detailItemWidget(
          context, _,
          title: '产品名称',
          content: _.inspectModel.invName ?? '',
        )
    );
    list.add(
        detailItemWidget(
          context, _,
          title: '产品规格',
          content: _.inspectModel.invStd ?? '',
        )
    );
    if (_.sourceProgid == 651011 || _.sourceProgid == 650011){
      list.add(
          detailItemWidget(
            context, _,
            title: '工序名称',
            content: _.inspectModel.opName ?? '',
          )
      );
    }
    list.add(
        detailItemWidget(
          context, _,
          title: '需求跟踪号',
          content: _.inspectModel.mtoNo ?? '',
        )
    );
    return list;
  }
  Widget detailItemWidget(BuildContext context, CreateInspectionController _,
      {required String title, required String content,
        Color? titleColor, Color? contentColor,
        bool isBold = false, double width = 310}){
    return TitleTextBoxWidget(
      title: title,
      content: content,
      width: width,
      titleWidth: 100,
      titleStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: titleColor,
      ),
      contentStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: contentColor,
          overflow: TextOverflow.ellipsis,
          fontWeight: isBold ? FontWeight.w600 : null
      ),
    );
  }

  Widget dataReport(BuildContext context, CreateInspectionController _) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '报检数量：',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(
                  width: 220, height: 60,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                          elevation: 1,
                          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                          child: InkWell(
                              onTap: () async{
                                await controller.changeToLastIndex();
                              },
                              child: Container(
                                width: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant,),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 2,
                                ),
                              )
                          )
                      ),
                      Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Theme.of(context).colorScheme.surface,),
                                  bottom: BorderSide(color: Theme.of(context).colorScheme.surface,),
                                )
                            ),
                            child: TextField(
                              focusNode: _.quantityFN,
                              controller: _.quantityTC,
                              minLines: 1, maxLines: 1,
                              keyboardType: TextInputType.none,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                //fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent)
                                ),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent)
                                ),
                              ),
                            ),
                          )
                      ),
                      Material(
                        elevation: 1,
                        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        child: InkWell(
                            onTap: () async{
                              await controller.changeToNextIndex();
                            },
                            child: Container(
                              width: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant,),
                              ),
                              child: Icon(
                                Icons.add,
                                size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 2,
                              ),
                            )
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            dataReportItem(context, _,
              title: '预计完成时间',
              titleWidth: 120,
              width: 400,
              customizeContent: PrefixTextField(
                object: 1, readOnly: true,
                hintText: '选填',
                initText: DateUtil.formatDateTime(
                    (_.inspectModel.dueFinishDate ?? '').toString(),
                    DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE
                ),
                valueOnChanged: (String string) async{
                  await controller.dueFinishDateOnChanged(DateTime.tryParse(string));
                },
              )
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 42),
            child: Container(
              alignment: Alignment.topLeft,
              child: _.processAdapter == null ?
              const SizedBox.shrink() :
              Wrap(
                runSpacing: 6, spacing: 6,
                children: List.generate(_.processAdapter!.dataList.length, (index) {
                  MoWorkBillEntryModel item = _.processAdapter!.dataList[index];
                  MoRoutingEntryModel? routingEntryModel = _.processAdapter!.routingEntryList.firstWhereOrNull((element) => element.opId == item.opId);
                  return Material(
                      color: Colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _.opDescription = '[${item.opName ?? ''}]${item.opDescription ?? ' '}';
                            controller.processOnChanged(item);
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 220, height: 80,
                            padding: const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: item.isSelected
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : null,
                              border: item.isSelected ? null : Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                  width: 1
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                MineIconButton(
                                  onPressed: () async{
                                    await controller.processItemAttach(item, routingEntryModel);
                                  },
                                  tooltip: '工序图纸',
                                  isNeedBadges: routingEntryModel != null && routingEntryModel.sop != null && routingEntryModel.sop != 0,
                                  badgesWidget: Text(
                                    (routingEntryModel?.sop ?? '').toString(),
                                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                        color: Theme.of(context).colorScheme.surface
                                    ),
                                  ),
                                  icon: Icons.attach_file_outlined,
                                  iconSize: 22,
                                  iconColor: Theme.of(context).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
                                ),
                                const SizedBox(width: 4,),

                                Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              '${(item.opName ?? '').isNotEmpty ? item.opName : ' '}',
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                  fontWeight: FontWeight.w600
                                              ),
                                              maxLines: 1, overflow: TextOverflow.ellipsis
                                          ),
                                        ),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              '检 ${NumFormatUtil.qtyFormatConverter((item.acceptQty ?? 0).toStringAsFixed(0))}'
                                                  ' / '
                                                  '次 ${NumFormatUtil.qtyFormatConverter((item.disabledQty ?? 0).toStringAsFixed(0))}',
                                              style: Theme.of(context).textTheme.bodyLarge,
                                              maxLines: 1, overflow: TextOverflow.ellipsis
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                              ],
                            ),
                          )
                      )
                  );
                }).toList(),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget infoItemm(BuildContext context, CreateInspectionController _, {
    required String title,
    required String content,
    Color? contentColor,
    double width = 310,
    double titleWidth = 130,
    bool isBold = false,
    void Function()? onPress,
    ICloneable? item,
  }) {
    return super.infoItemm(
      context, _, title: title, content: content,
      contentColor: contentColor,
      width: width, titleWidth: titleWidth,
      isBold: isBold, onPress: onPress,
      item: item,
    );
  }

}