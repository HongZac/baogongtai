import 'package:basement/model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/list/inv_barcode_list_controller.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///物料条码新增查看 条码列表页面 230004
class InvBarcodeListPage extends BaseFormWithPageDataPage<InvBarcodeListController, BarcodeMainModel> {


  @override
  Widget headWidget(BuildContext context, InvBarcodeListController _) {
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
                  width: constraints.maxWidth < 320 ? constraints.maxWidth : 320,
                  child:  _.commandBarWidget(
                    context,
                    commandBarList: _.invBarcodeListCommandBarList,
                    item: BarcodeMainModel(),
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
                alignment: WrapAlignment.end,
                children: [
                  if (_.isShowSearchInputBox)
                    _.searchInputWidget(context),
                  _.dateFilterInputWidget(context),
                ],
              ),
            ),
            const SizedBox(width: 6,),
          ],
        )
    );
  }

  @override
  Widget dataItem(BuildContext context, InvBarcodeListController _, BarcodeMainModel item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: (){
            controller.itemChanged(item);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              color: item.isChoice
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: item.isChoice,
                      onChanged: (bool? bool) {
                        controller.itemChanged(item);
                      },
                    ),
                    Expanded(
                      child: Text(
                        '${item.barcode ?? ''}',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600
                        ),
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
                      infoFormList: _.invBarcodeListInfoFormListMap[0] ?? [],
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
                      infoFormList: _.invBarcodeListInfoFormListMap[1] ?? [],
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

}