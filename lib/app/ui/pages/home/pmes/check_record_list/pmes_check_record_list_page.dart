import 'package:basement/model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/check_record_list/pmes_check_record_list_controller.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 次品记录列表
class PMesCheckRecordListPage extends BaseFormWithPageDataPage<PMesCheckRecordListController, MoCheckRecordModel>{


  @override
  Widget headWidget(BuildContext context, PMesCheckRecordListController _) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///返回键
            if (_.showAppBar)
              Container(
                width: 90,
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: 8, top: 6),
                child: const BackOutlinedButton(),
              ),
            if (_.showAppBar)
              const SizedBox(width: 4,),


            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints){
                return Container(
                  alignment: Alignment.centerLeft,
                  margin: kIsWeb || GetPlatform.isWindows
                      ? const EdgeInsets.only(top: 9)
                      : const EdgeInsets.only(),
                  width: kIsWeb || GetPlatform.isWindows
                      ? constraints.maxWidth < 210 ? constraints.maxWidth : 210
                      : constraints.maxWidth < 220 ? constraints.maxWidth : 220,
                  child:  _.commandBarWidget(
                    context,
                    commandBarList: _.checkRecordListCommandBarList,
                    item: _.selectedCheckRecordModel,
                    btnPadding: kIsWeb || GetPlatform.isWindows
                        ? const EdgeInsets.symmetric(vertical: 18, horizontal: 8)
                        : const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  ),
                );
              },
            ),
            const SizedBox(width: 6,),

            Expanded(
              child: Wrap(
                runSpacing: 6, spacing: 6,
                alignment: WrapAlignment.start,
                children: [
                  _.dateFilterInputWidget(context),
                ],
              ),
            ),
            const SizedBox(width: 6,),
            _.checkRecordDocumentTypeFilterMenuBarWidget(context),
            const SizedBox(width: 6,),
          ],
        )
    );
  }

  @override
  Widget dataItem(BuildContext context, PMesCheckRecordListController _, MoCheckRecordModel item){
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
            elevation: 1,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
                onTap: () async{
                  await controller.checkRecordOnSelected(item);
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
                            value: item.moRecordId == _.selectedCheckRecordModel.moRecordId,
                            onChanged: (bool? bool) async{
                              await controller.checkRecordOnSelected(item);
                            },
                          ),
                          Expanded(
                            child: Text(
                              '【${item.billCode ?? ''}】${item.invName ?? ''}',
                              style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                          const SizedBox(width: 8,),

                          TextButton(
                            onPressed: (){
                              controller.checkRecordExpandedOnChanged(item);
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
                                  style: Theme.of(Get.context!).textTheme.bodyLarge,
                                ),
                                const SizedBox(width: 2,),
                                AnimatedRotation(
                                    turns: item.isExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 100),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      color: Theme.of(Get.context!).textTheme.bodyLarge!.color,
                                      size: Theme.of(Get.context!).textTheme.bodyLarge!.fontSize! * 1.43,
                                    )
                                ),
                              ],
                            ),
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
                            infoFormList: _.checkRecordListInfoFormListMap[0] ?? [],
                            item: item,
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: !item.isExpanded ?
                        const SizedBox.shrink() :
                        Wrap(
                          runSpacing: 4, spacing: 6,
                          children: _.getFieldList(
                            context,
                            infoFormList: _.checkRecordListInfoFormListMap[1] ?? [],
                            item: item,
                          ),
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

}