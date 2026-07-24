import 'package:basement/model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/inv_barcode_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///物料条码新增查看 首页
class InvBarcodePage extends BaseFormWithPageDataPage<InvBarcodeController, InventoryModel> {

  @override
  Widget headWidget(BuildContext context, InvBarcodeController _) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(
              runSpacing: 8, spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_.isDataByScan)
                  _.resetScanWidget(context),
                if (_.isShowSearchInputBox)
                  _.searchInputWidget(context, needOpenBtn: false),
              ],
            ),
          ),
          settingWidget(context, _, top: kIsWeb || GetPlatform.isWindows ? 9 : 0),
          const SizedBox(width: 6,)
        ],
      ),
    );
  }


  @override
  Widget dataItem(BuildContext context, InvBarcodeController _, InventoryModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onDoubleTap: ()  async {
            await controller.itemOnDoubleTap(item);
          },
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ///产品附件
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
                                child: Text(
                                  '【${item.invCode ?? ''}】${item.invName}',
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(width: 8,),

                              _.commandBarWidget(
                                context,
                                commandBarList: _.invBarcodeCommandBarList,
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
                                infoFormList: _.invBarcodeListInfoFormListMap[0] ?? [],
                                item: item,
                                customBuilder: (String keyName, ICloneable item){
                                  item as InventoryModel;
                                  return customField(keyName, item);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      infoFormList: _.invBarcodeListInfoFormListMap[1] ?? [],
                      item: item,
                      customBuilder: (String keyName, ICloneable item){
                        item as InventoryModel;
                        return customField(keyName, item);
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

  Map<String, dynamic>? customField(String keyName, InventoryModel item){
    switch (keyName){
      case 'Module':
        return {
          'content': item.module == 0 ? '生产模块' : item.module == 1 ? '注塑模块' : '',
        };
    }
    return null;
  }

}