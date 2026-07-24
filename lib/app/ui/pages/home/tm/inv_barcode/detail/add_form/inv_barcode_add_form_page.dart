

import 'package:basement/model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/add_form/inv_barcode_add_form_controller.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';


///物料条码新增查看 新增条码页面
class InvBarcodeAddFormPage extends BaseFormPage<InvBarcodeAddFormController> {

  @override
  Widget contentWidget(BuildContext context, InvBarcodeAddFormController _) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Column(
        children: [
          if (_.showAppBar)
            const SizedBox(height: 4,),
          ///TabBar、返回键、设置键
          if (_.showAppBar)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 250, height: 48,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 8),
                  child: const BackOutlinedButton(),
                ),
                const Expanded(child: SizedBox.shrink()),
                Container(
                    width: 250,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 12),
                    child: MineIconButton(
                      onPressed: () {  },
                      tooltip: '设置',
                      icon: Icons.settings,
                      iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    )
                ),
              ],
            ),

          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CardWidget(
                content: taskWidget(context, _),
              )
          ),
          Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 0),
                child: dataSaveWidget(context, _),
              )
          ),
        ],
      ),
    );
  }

  Widget taskWidget(BuildContext context, InvBarcodeAddFormController _){
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
                    '当前物料 ${_.inventoryModel.invName ?? ''}【${_.inventoryModel.invCode ?? ''}】',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ), maxLines: 1, overflow: TextOverflow.ellipsis
                ),
              ),
            ],
          ),
          const SizedBox(height: 4,),

          Container(
            constraints: BoxConstraints(
              maxHeight: 200,
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
                child: Wrap(
                  runSpacing: 4, spacing: 6,
                  children: _.getFieldList(
                    context,
                    infoFormList: _.invInfoFormList,
                    item: _.inventoryModel,
                    customBuilder: (String keyName, ICloneable item){
                      item as InventoryModel;
                      switch (keyName){
                        case 'Module':
                          return {
                            'content': item.module == 0 ? '生产模块' : item.module == 1 ? '注塑模块' : '',
                          };
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget dataSaveWidget(BuildContext context, InvBarcodeAddFormController _){
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          ///标题、填报方式选择
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(bottom: 4),
            child: Wrap(
              spacing: 8, runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  width: 4, height: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(
                    '数据填报',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ), maxLines: 1, overflow: TextOverflow.ellipsis
                ),

                ///填报方式选择
                if (_.isShowSaveTypeBtn)
                  _.operationWayWidget(context),

                ///按数量（多箱）填报时，是否显示称重消息传递过来的单箱重量、预计单箱数量
                if (_.isShowExpectSingleBoxQty && (_.saveType == AppConfig.qtyBoxSubmit || _.saveType == AppConfig.weightBoxSubmit))
                  _.expectSingleBoxQtyWidget(context)
              ],
            ),
          ),

          ///填单区域
          Expanded(
            child: _.submitAreaWidget(context),
          ),
        ],
      ),
    );
  }

}