import 'package:basement/model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/pages/home/tm/submit_barcode/submit_barcode_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///报工记录的条码列表
class SubmitBarcodePage extends BaseFormWithPageDataPage<SubmitBarcodeController, BarcodeMainModel>{

  @override
  Widget headWidget(BuildContext context, SubmitBarcodeController _) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _.searchInputWidget(
            context,
            needOpenBtn: false,
          ),
          const SizedBox(width: 6,),

          if (_.isDataByScan)
            _.resetScanWidget(context),
          if (_.isDataByScan)
          const SizedBox(width: 6,),

          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints){
                return Container(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: kIsWeb || GetPlatform.isWindows
                          ? constraints.maxWidth < 250 ? constraints.maxWidth : 250
                          : constraints.maxWidth < 260 ? constraints.maxWidth : 260,
                      child:  _.commandBarWidget(
                        context,
                        commandBarList: _.commandBarList,
                        item: BarcodeMainModel(),
                        btnPadding: kIsWeb || GetPlatform.isWindows
                            ? const EdgeInsets.symmetric(vertical: 18, horizontal: 8)
                            : const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      ),
                    )
                );
              },
            ),
          ),
          const SizedBox(width: 6,),
        ],
      ),
    );
  }

  Widget emptyWidget(BuildContext context, SubmitBarcodeController _){
    return Center(
      child: Text(
        '没有符合条件数据或未进行搜索。\n请输入单号并点击查询按钮，或扫码！',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }


  @override
  Widget dataListWidget(BuildContext context, SubmitBarcodeController _){
    return super.dataListWidget(context, _);
  }

  @override
  Widget dataItem(BuildContext context, SubmitBarcodeController _, BarcodeMainModel item){
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
                      value: item.isChoice, //item.moOpSubmitId == _.selectedSubmitModel.moOpSubmitId,
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
                      infoFormList: _.submitBarcodeListInfoFormListMap[0] ?? [],
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
                      infoFormList: _.submitBarcodeListInfoFormListMap[1] ?? [],
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