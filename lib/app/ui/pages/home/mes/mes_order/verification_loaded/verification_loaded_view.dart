import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/dfs_item_model.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/verification_loaded/verification_loaded_controller.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:flutter/material.dart';


///任务单-上料验证
class VerificationLoadedView extends BaseFormPage<VerificationLoadedController> {

  Widget contentWidget(BuildContext context, VerificationLoadedController _) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CardWidget(
              content: detailWidget(context, _),
            ),
          ),
          const SizedBox(height: 8,),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '已扫条码-物料批次号：',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(
                          width: 450,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      '请扫描条码：',
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 350,
                                    child: TextField(
                                      controller: _.scanTC,
                                      focusNode: _.scanFN,
                                      maxLines: 1,
                                      showCursor: true,
                                      autofocus: true,
                                      keyboardType: TextInputType.none,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                        suffixIcon: MineIconButton(
                                          icon: Icons.cancel,
                                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                                          tooltip: '清空',
                                          onPressed: () async{
                                            _.scanTC.clear();
                                            controller.update();
                                          },
                                        ),
                                      ),
                                      onSubmitted: (String value) async {
                                        await controller.onSubmitted();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4,),
                              Row(
                                children: [
                                  SizedBox(width: 100,),
                                  SizedBox(
                                    width: 350,
                                    child:Text(
                                        '请将输入法切换成英文模式后在进行扫码！',
                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.errorTextColor,
                                        ), maxLines: 1, overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14,),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        runSpacing: 8, spacing: 8,
                        children: _.barcodeMap.keys.map((e) {
                          return barcodeInfoItem(
                            context, _,
                            barcode: e,
                            width: 279,
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 8,),
                    Divider(indent: 0, endIndent: 0,),
                    const SizedBox(height: 8,),

                    if ((_.selectedBarcode).isNotEmpty)
                      Material(
                        elevation: 4,
                        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                        shadowColor: Colors.transparent,
                        child: Container(
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: List.generate(_.fieldList.length, (index) {
                              DFSItemModel item = _.fieldList[index];
                              if (!item.isVisible){
                                return const SizedBox.shrink();
                              }
                              return Expanded(
                                flex: item.width,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  alignment: Alignment(item.alignmentX, item.alignmentY),
                                  child: Text(
                                      item.title,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    if ((_.selectedBarcode).isNotEmpty)
                      ...List.generate(_.barcodeStockMap[_.selectedBarcode]!.length, (index) {
                        List<MoStockEntryList> stockList = _.barcodeStockMap[_.selectedBarcode]!;
                        MoStockEntryList stockItem = stockList[index];
                        BarcodeEntity? barcodeItem = _.barcodeMap[_.selectedBarcode];
                        return Column(
                          children: [
                            Container(
                                height: 55,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: List.generate(_.fieldList.length, (index2) {
                                    DFSItemModel dFSItemModel = _.fieldList[index2];
                                    if (!dFSItemModel.isVisible){
                                      return const SizedBox.shrink();
                                    }
                                    String content = '';
                                    switch (dFSItemModel.enTitle){
                                    //region
                                      case 'billCode':
                                        content = stockItem.billCode ?? '';
                                        break;
                                      case 'whName':
                                        content = stockItem.whName ?? '';
                                        break;
                                      case 'posName':
                                        content = stockItem.posName ?? '';
                                        break;
                                      case 'invName':
                                        content = stockItem.invName ?? '';
                                        break;
                                      case 'invStd':
                                        content = stockItem.invStd ?? '';
                                        break;
                                      case 'quantity':
                                        content = NumFormatUtil.qtyFormatConverter((stockItem.quantity ?? '').toString());
                                        break;
                                      case 'grossW':
                                        content = NumFormatUtil.qtyFormatConverter((stockItem.grossW ?? '').toString(), decimal: 2);
                                        break;
                                      case 'invWeight':
                                        content = NumFormatUtil.qtyFormatConverter((stockItem.invWeight ?? '').toString(), decimal: 2);
                                        break;
                                    //endregion
                                    }
                                    return Expanded(
                                      flex: dFSItemModel.width,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        alignment: Alignment(dFSItemModel.alignmentX, dFSItemModel.alignmentY),
                                        child: Text(
                                          content,
                                          style: Theme.of(context).textTheme.bodyLarge,
                                          maxLines: 2, overflow: TextOverflow.ellipsis,
                                          textAlign: dFSItemModel.alignmentX == -1
                                              ? TextAlign.start
                                              : dFSItemModel.alignmentX == 0
                                              ? TextAlign.center
                                              : TextAlign.end,
                                        ),
                                      ),
                                    );
                                  }),
                                )
                            ),
                            if (index != stockList.length - 1)
                              Divider(indent: 0, endIndent: 0, color: Theme.of(context).colorScheme.outlineVariant.withAlpha(102),),
                          ],
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }

  Widget detailWidget(BuildContext context, VerificationLoadedController _) {
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4, height: 24,
                color: Theme.of(context).colorScheme.primary,
                margin: const EdgeInsets.only(right: 6),
              ),
              Expanded(
                child: Text(
                    '当前任务 ${_.orderModel.productName ?? ''}',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ), maxLines: 1, overflow: TextOverflow.ellipsis
                ),
              ),
              const SizedBox(width: 12,),
            ],
          ),
          const SizedBox(height: 6,),
          Container(
            constraints: BoxConstraints(
              maxHeight: 180,
            ),
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                interactive: false,
                thumbVisibility: WidgetStateProperty.all(false),
                trackVisibility: WidgetStateProperty.all(false),
                thumbColor: WidgetStateProperty.all(Colors.transparent),
                trackColor: WidgetStateProperty.all(Colors.transparent),
              ),
              child: SingleChildScrollView(
                controller: _.orderDetailController,
                child: Wrap(
                  runSpacing: 4, spacing: 6,
                  children: orderList(context, _),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  List<Widget> orderList(BuildContext context, VerificationLoadedController _){
    List<Widget> list = [];
    list.add(
        infoItemm(context, _, title: '任务单号', content: _.orderModel.billCode ?? '')
    );
    list.add(
        infoItemm(context, _, title: '产品编号', content: _.orderModel.invCode ?? '')
    );
    list.add(
        infoItemm(context, _, title: '产品名称', content: _.orderModel.productName ?? '')
    );
    list.add(
        infoItemm(context, _, title: '产品规格', content: _.orderModel.productStd ?? '')
    );
    list.add(
        infoItemm(context, _, title: '生产车间', content: _.orderModel.depName ?? '', isBold: true)
    );
    list.add(
        infoItemm(context, _, 
            title: '任务数量',
            content: NumFormatUtil.qtyFormatConverter((_.orderModel.qty ?? 0).toString())
        )
    );
    list.add(
        infoItemm(context, _, 
            title: '已生产数',
            content: NumFormatUtil.qtyFormatConverter((_.orderModel.productQty ?? 0).toString())
        )
    );
    list.add(
        infoItemm(context, _, 
            title: '已报产数',
            content: NumFormatUtil.qtyFormatConverter((_.orderModel.qualifiedQty ?? 0).toString())
        )
    );
    list.add(
        infoItemm(context, _, 
            title: '剩余报工数', isBold: true,
            content: NumFormatUtil.qtyFormatConverter(
                (_.orderModel.qty ?? 0) <= (_.orderModel.qualifiedQty ?? 0) ? '0' : ((_.orderModel.qty ?? 0) - (_.orderModel.qualifiedQty ?? 0)).toStringAsFixed(0))
        )
    );
    list.add(
        infoItemm(context, _, 
            title: '次品数量',
            content: NumFormatUtil.qtyFormatConverter((_.orderModel.disabledQty ?? 0).toString())
        )
    );
    list.add(
        infoItemm(context, _, title: '销售单号', content: _.orderModel.soCode ?? '')
    );
    list.add(
        infoItemm(context, _, title: '需求跟踪号', content: _.orderModel.mtoNo ?? '')
    );

    //region InvDefine
    if (_.dataService.userDefMap['InvDefine1']?.defCaption != null){
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['InvDefine1']!.defCaption!,
              content: _.orderModel.invDefine1 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['InvDefine2']?.defCaption != null){
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['InvDefine2']!.defCaption!,
              content: _.orderModel.invDefine2 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['InvDefine3']?.defCaption != null){
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['InvDefine3']!.defCaption!,
              content: _.orderModel.invDefine3 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['InvDefine4']?.defCaption != null){
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['InvDefine4']!.defCaption!,
              content: _.orderModel.invDefine4 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['InvDefine5']?.defCaption != null){
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['InvDefine5']!.defCaption!,
              content: _.orderModel.invDefine5 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['InvDefine6']?.defCaption != null){
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['InvDefine6']!.defCaption!,
              content: _.orderModel.invDefine6 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['InvDefine7']?.defCaption != null){
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['InvDefine7']!.defCaption!,
              content: _.orderModel.invDefine7 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['InvDefine8']?.defCaption != null){
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['InvDefine8']!.defCaption!,
              content: _.orderModel.invDefine8 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['InvDefine9']?.defCaption != null){
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['InvDefine9']!.defCaption!,
              content: _.orderModel.invDefine9 ?? ''
          )
      );
    }
    if (_.dataService.userDefMap['InvDefine10']?.defCaption != null){
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['InvDefine10']!.defCaption!,
              content: _.orderModel.invDefine10 ?? ''
          )
      );
    }
    //endregion

    //region free
    if (_.orderModel.isFree1 == 1) {
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['Free1']?.defCaption ?? '',
              content: _.orderModel.free1 ?? ''
          )
      );
    }
    if (_.orderModel.isFree2 == 1) {
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['Free2']?.defCaption ?? '',
              content: _.orderModel.free2 ?? ''
          )
      );
    }
    if (_.orderModel.isFree3 == 1) {
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['Free3']?.defCaption ?? '',
              content: _.orderModel.free3 ?? ''
          )
      );
    }
    if (_.orderModel.isFree4 == 1) {
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['Free4']?.defCaption ?? '',
              content: _.orderModel.free4 ?? ''
          )
      );
    }
    if (_.orderModel.isFree5 == 1) {
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['Free5']?.defCaption ?? '',
              content: _.orderModel.free5 ?? ''
          )
      );
    }
    if (_.orderModel.isFree6 == 1) {
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['Free6']?.defCaption ?? '',
              content: _.orderModel.free6 ?? ''
          )
      );
    }
    if (_.orderModel.isFree7 == 1) {
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['Free7']?.defCaption ?? '',
              content: _.orderModel.free7 ?? ''
          )
      );
    }
    if (_.orderModel.isFree8 == 1) {
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['Free8']?.defCaption ?? '',
              content: _.orderModel.free8 ?? ''
          )
      );
    }
    if (_.orderModel.isFree9 == 1) {
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['Free9']?.defCaption ?? '',
              content: _.orderModel.free9 ?? ''
          )
      );
    }
    if (_.orderModel.isFree10 == 1) {
      list.add(
          infoItemm(context, _, 
              title: _.dataService.userDefMap['Free10']?.defCaption ?? '',
              content: _.orderModel.free10 ?? ''
          )
      );
    }
    //endregion
    return list;
  }

  Widget barcodeInfoItem(BuildContext context, VerificationLoadedController _, {required String barcode, required double width}){
    BarcodeEntity? barcodeEntity = _.barcodeMap[barcode];
    return InkWell(
      onTap: () {
        controller.selectedBarcodeOnChanged(barcode);
      },
      child: Container(
        width: width, height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: _.selectedBarcode == barcode
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          border: _.selectedBarcode == barcode
              ? null
              : Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '${barcodeEntity?.invCode ?? ''}【${barcodeEntity?.empty2 ?? ''}】',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}