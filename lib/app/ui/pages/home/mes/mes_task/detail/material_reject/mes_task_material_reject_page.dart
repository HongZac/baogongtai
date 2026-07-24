import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/material_reject/mes_task_material_reject_controller.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_button_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 派工单不良品上报页面
class MesTaskMaterialRejectPage extends BaseFormPage<MesTaskMaterialRejectController> {

  Widget contentWidget(BuildContext context, MesTaskMaterialRejectController _){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CardWidget(
            content: taskWidget(context, _),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 0),
            child: checkRecordReportWidget(context, _),
          ),
        )
      ],
    );
  }

  Widget taskWidget(BuildContext context, MesTaskMaterialRejectController _){
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
                    '当前上报任务 ${_.taskModel.invName ?? ''}',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ), maxLines: 1, overflow: TextOverflow.ellipsis
                ),
              ),

              if ((_.taskModel.opId ?? '').isNotEmpty)
                TextButton(
                  onPressed: () async{
                    await controller.getOpSop(_.taskModel);
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                        kIsWeb || GetPlatform.isWindows
                            ? const EdgeInsets.symmetric(vertical: 16, horizontal: 8)
                            : const EdgeInsets.symmetric(vertical: 12, horizontal: 8)
                    ),
                  ),
                  child: Text(
                      '工序图纸',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                        fontWeight: FontWeight.w600,
                      )
                  ),
                ),
              if ((_.taskModel.opId ?? '').isNotEmpty)
                const SizedBox(width: 8,),

              if ((_.taskModel.invId ?? '').isNotEmpty)
                TextButton(
                  onPressed: () async{
                    await controller.itemInvAttach(_.taskModel);
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                        kIsWeb || GetPlatform.isWindows
                            ? const EdgeInsets.symmetric(vertical: 16, horizontal: 8)
                            : const EdgeInsets.symmetric(vertical: 12, horizontal: 8)
                    ),
                  ),
                  child: Text(
                      '产品附件',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                        fontWeight: FontWeight.w600,
                      )
                  ),
                ),
              if ((_.taskModel.invId ?? '').isNotEmpty)
                const SizedBox(width: 8,),

              PickerButtonWidget(
                adapter: _.taskAdapter,
                pickerChoiceType: PickerChoiceType.mesTask,
                onTap: (List<PickerDataModel> selectList) async{
                  if (selectList.isNotEmpty){
                    await controller.taskOnChanged(selectList[0]);
                  }
                  else {
                    await controller.taskOnChanged(PickerDataModel());
                  }
                },
                buttonStyle: ButtonStyle(
                  padding: WidgetStateProperty.all(
                      kIsWeb || GetPlatform.isWindows
                          ? const EdgeInsets.symmetric(vertical: 16, horizontal: 8)
                          : const EdgeInsets.symmetric(vertical: 12, horizontal: 8)
                  ),
                ),
                child: Text(
                  '选择其他任务上报不良品',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4,),
          Container(
            constraints: BoxConstraints(
              maxHeight: 140,
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
                    infoFormList: _.taskInfoFormList,
                    item: _.taskModel,
                    customBuilder: (String keyName, ICloneable item){
                      switch (keyName){
                        case 'OpName': ///工序名称
                          return {
                            'isBold': true,
                          };
                        case 'DepName': ///生产车间
                          return {
                            'isBold': true,
                          };
                        case 'DeviceName': ///设备名称
                          return {
                            'isBold': true,
                          };
                        case 'RemainingQty':
                          //region 剩余报工数
                          return {
                            'content': NumFormatUtil.qtyFormatConverter(
                                (_.taskModel.assignQty ?? 0) <= (_.taskModel.submitQty ?? 0)
                                    ? '0'
                                    : ((_.taskModel.assignQty ?? 0) - (_.taskModel.submitQty ?? 0)).toStringAsFixed(0)
                            ),
                          };
                          //endregion
                        case 'UnStockQty':
                          //region 未入库数量
                          return {
                            'content': NumFormatUtil.qtyFormatConverter(
                                (_.taskModel.assignQty ?? 0) <= (_.taskModel.stockQty ?? 0)
                                    ? '0'
                                    : ((_.taskModel.assignQty ?? 0) - (_.taskModel.stockQty ?? 0)).toStringAsFixed(0)
                            ),
                          };
                          //endregion
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

  Widget checkRecordReportWidget(BuildContext context, MesTaskMaterialRejectController _){
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

                ///上报不良品方式选择控件
                if (_.isShowDataReportTypeBtn)
                  _.operationWayWidget(context, hintStr: '（请选择上报方式）'),

                ///“补打”按钮
                if (_.isShowMakeUpBtn && !_.isProductDateChangedByNightTeam)
                  _.makeUpBtnWidget(context),
              ],
            ),
          ),

          ///上报不良品填单区域
          Expanded(
            child: _.checkRecordAreaWidget(context),
          ),
        ],
      ),
    );
  }

}