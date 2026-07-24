import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_button_widget.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'device_check_record_controller.dart';


///机台报工 报次品
class DeviceCheckRecordPage extends BaseFormPage<DeviceCheckRecordController>{

  @override
  Widget contentWidget(BuildContext context, DeviceCheckRecordController _) {
    return Column(
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
                    onPressed: () {
                      Get.rootDelegate.toNamed(
                        AppRoutes.PMES_REAL_TIME_MONITOR_CHECK_RECORD_SETTING_PAGE,
                        parameters: {
                          'noPermission': _.noPermission ? '1' : '0',
                          'permissionInfo': _.permissionInfo,
                        }
                      );
                    },
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

  Widget taskWidget(BuildContext context, DeviceCheckRecordController _){
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
                    '当前报次品任务 ${_.taskModel.invName ?? ''}',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600
                    ), maxLines: 1, overflow: TextOverflow.ellipsis
                ),
              ),

              PickerButtonWidget(
                adapter: _.taskAdapter,
                pickerChoiceType: PickerChoiceType.pmesTask,
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
                  '该机台下其他任务报次品',
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
                    infoFormList: _.taskInfoFormList,
                    item: _.taskModel,
                    customBuilder: (String keyName, ICloneable item){
                      String? content;
                      InfoFormModel? infoFormModel = _.taskInfoFormList.firstWhereOrNull((element) => element.keyName == keyName);
                      if (infoFormModel != null){
                        /// [groupType]：== 0 时，数据源来自 [MoTaskModel]
                        /// [groupType]：== 1 时，数据源来自 [DeviceTaskModel]
                        /// [groupType]：== 2 时，数据源来自 [InventoryModel]
                        Map<String, dynamic> deviceTaskMap = _.deviceTaskModelWithGetxController.model.toJson();
                        Map<String, dynamic> inventoryMap = _.inventoryModel.toJson();
                        switch (infoFormModel.groupType){
                          case 1:
                            content = _.getInfoFormContent(deviceTaskMap[keyName]);
                            break;
                          case 2:
                            content = _.getInfoFormContent(inventoryMap[keyName]);
                            break;
                        }
                      }
                      switch (keyName){
                        case 'DepName': ///生产车间
                          return {
                            'isBold': true,
                          };
                        case 'DeviceName': ///设备名称
                          return {
                            'isBold': true,
                          };
                        case 'InvWeight': ///标准单重
                          return {
                            'isBold': true,
                            'content': content,
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
                        default:
                          if (content != null){
                            return {
                              'content': content,
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

  Widget checkRecordReportWidget(BuildContext context, DeviceCheckRecordController _) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
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