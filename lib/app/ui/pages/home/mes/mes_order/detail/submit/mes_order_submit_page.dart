import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/submit/mes_order_submit_controller.dart';
import 'package:desktop/app/ui/widget/blink_widget.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产任务单 报工页面
class MesOrderSubmitPage extends BaseFormPage<MesOrderSubmitController> {

  @override
  Widget contentWidget(BuildContext context, MesOrderSubmitController _) {
    return Stack(
      children: [
        Column(
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
                child: submitWidget(context, _),
              ),
            ),
          ],
        ),

        ///自动提交是否成功的闪烁反馈
        if ((_.submitType == AppConfig.serialNumberSubmit || _.submitType == AppConfig.singleBoxSerialNumberSubmit)
            && _.autoCommitSubmit
            && _.isAutoCommitSuccess != null)
          Positioned.fill(
            child: BlinkWidget(
              isBlink: true,
              rate: 700,
              blinkColor: _.isAutoCommitSuccess! ? AppColors.runColor : null,
              child: const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }

  Widget orderWidget(BuildContext context, MesOrderSubmitController _){
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
                  '当前报工任务 ${_.orderModel.productName ?? ''}',
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

  Widget submitWidget(BuildContext context, MesOrderSubmitController _){
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

                  ///报工方式选择控件
                  if (_.isShowDataReportTypeBtn)
                    _.operationWayWidget(context),

                  ///“补打”按钮
                  if (_.isShowMakeUpBtn && !_.isBillDateChangedByNightTeam)
                    _.makeUpBtnWidget(context),

                  ///“需要检验”按钮
                  if (_.isShowInspectFlagBtn && _.isCanClickInspectFlagBtn)
                    _.inspectFlagBtnWidget(context)
                  else if (_.isShowInspectFlagBtn && _.submitModel.inspectFlag == 1)
                    _.inspectFlagStrWidget(context),

                  ///“自检确认”按钮
                  if (_.isShowSelfInspectionBtn)
                    _.selfInspectionBtnWidget(context),

                  ///“互检确认”按钮
                  if (_.isShowMutualInspectionBtn)
                    _.mutualInspectionBtnWidget(context),

                  ///自动提交（按序列号报工时使用）
                  if ((_.submitType == AppConfig.serialNumberSubmit
                      || _.submitType == AppConfig.singleBoxSerialNumberSubmit)
                      && _.isShowAutoCommitBtn)
                    _.autoCommitSubmitBtnWidget(context),

                  ///首检单提示
                  if (_.cannotSubmitWhenNotPassFirstInspection && (_.submitModel.moOrderId ?? '').isNotEmpty)
                    _.firstInspectionWidget(context),

                  ///序列号扫码历史提示信息
                  if (_.submitType == AppConfig.serialNumberSubmit
                      || _.submitType == AppConfig.singleBoxSerialNumberSubmit)
                    _.serialNumberBarcodeMsgWidget(context),
                ],
              )
          ),

          ///报工填单区域
          Expanded(
            child: _.submitAreaWidget(context),
          ),
        ],
      ),
    );
  }
}