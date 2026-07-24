import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/check_record/mes_order_check_record_controller.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产任务单 报次品页面
class MesOrderCheckRecordPage extends BaseFormPage<MesOrderCheckRecordController>{

  Widget contentWidget(BuildContext context, MesOrderCheckRecordController _){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CardWidget(
            content: orderWidget(context, _),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 0),
            child: checkRecordWidget(context, _),
          ),
        )
      ],
    );
  }

  Widget orderWidget(BuildContext context, MesOrderCheckRecordController _){
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
                  '当前报次品任务 ${_.orderModel.productName ?? ''}',
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
              maxHeight: _.orderOpenType == 1 ? 200 : 140,
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
                    infoFormList: _.orderInfoFormList,
                    item: _.orderModel,
                    customBuilder: (String keyName, ICloneable item){
                      String? content;
                      bool isBold = false;
                      if (_.orderOpenType == 1){
                        InfoFormModel? infoFormModel = _.orderInfoFormList.firstWhereOrNull((element) => element.keyName == keyName);
                        if (infoFormModel != null){
                          /// [groupType]：== 0 时，数据源来自 [MoOpOrderModel]
                          /// [groupType]：== 1 时，数据源来自 [MoDeviceWorkBillList]
                          Map<String, dynamic> deviceTaskMap = _.deviceWBModelWithGetxController?.model.toJson() ?? {};
                          switch (infoFormModel.groupType){
                            case 1:
                              isBold = true;
                              switch (keyName){
                                case 'OpSubmitQty':
                                  content = NumFormatUtil.qtyFormatConverter(_.deviceWBModelWithGetxController?.model.submitQty.toString() ?? '');
                                  break;
                                case 'OpDisabledQty':
                                  content = NumFormatUtil.qtyFormatConverter(_.deviceWBModelWithGetxController?.model.disabledQty.toString() ?? '');
                                  break;
                                case 'OpAcceptQty':
                                  content = NumFormatUtil.qtyFormatConverter(_.deviceWBModelWithGetxController?.model.acceptQty.toString() ?? '');
                                  break;
                                default:
                                  content = _.getInfoFormContent(deviceTaskMap[keyName]);
                                  break;
                              }
                              break;
                          }
                        }
                      }

                      switch (keyName){
                        case 'DepName': ///生产车间
                          return {
                            'isBold': true,
                          };
                        case 'RemainingQty':
                          //region 剩余报工数
                          return {
                            'content': NumFormatUtil.qtyFormatConverter(
                                (_.orderModel.qty ?? 0) <= (_.orderModel.qualifiedQty ?? 0)
                                    ? '0'
                                    : ((_.orderModel.qty ?? 0) - (_.orderModel.qualifiedQty ?? 0)).toStringAsFixed(0)
                            ),
                          };
                          //endregion
                        case 'UnStockQty':
                          //region 未入库数量
                          return {
                            'content': NumFormatUtil.qtyFormatConverter(
                                (_.orderModel.qty ?? 0) <= (_.orderModel.stockQty ?? 0)
                                    ? '0'
                                    : ((_.orderModel.qty ?? 0) - (_.orderModel.stockQty ?? 0)).toStringAsFixed(0)
                            ),
                          };
                          //endregion
                        default:
                          if (content != null){
                            return {
                              'content': content,
                              'isBold': isBold,
                            };
                          }
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

  Widget checkRecordWidget(BuildContext context, MesOrderCheckRecordController _){
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ///标题
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
                  margin: const EdgeInsets.only(right: 6),
                ),
                Text(
                  '数据填报',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600
                  ), maxLines: 1, overflow: TextOverflow.ellipsis
                ),

                ///报次品方式选择控件
                if (_.isShowDataReportTypeBtn)
                  _.operationWayWidget(context),

                ///“补打”按钮
                if (_.isShowMakeUpBtn && !_.isProductDateChangedByNightTeam)
                  _.makeUpBtnWidget(context),

                ///处理方式
                _.disposeFlowWidget(context),

                ///序列号扫码历史提示信息
                if (_.checkRecordType == AppConfig.serialNumberCheckRecord)
                  _.serialNumberBarcodeMsgWidget(context),
              ],
            ),
          ),

          ///报次品填单区域
          Expanded(
            child: _.checkRecordAreaWidget(context),
          ),
        ],
      ),
    );
  }

}