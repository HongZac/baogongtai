import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/submit/device_submit_controller.dart';
import 'package:desktop/app/ui/widget/back_outlined_button.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_button_widget.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';

import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///机台报工页
class DeviceSubmitPage extends BaseFormPage<DeviceSubmitController>{

  @override
  Widget contentWidget(BuildContext context, DeviceSubmitController _) {
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
                      onPressed: () {
                        Get.rootDelegate.toNamed(
                          AppRoutes.PMES_REAL_TIME_MONITOR_SUBMIT_SETTING_PAGE,
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
              )
          ),
          Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 0),
                child: submitWidget(context, _),
              )
          ),
        ],
      ),
    );
  }

  Widget taskWidget(BuildContext context, DeviceSubmitController _){
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
                  '当前报工任务 ${_.taskModel.invName ?? ''}',
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
                  '该机台下其他任务报工',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  ),
                ),
              )
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
                        case 'ContainerPackingDescription':
                          return {
                            'content': _.containerPackingDescription,
                          };
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

  Widget submitWidget(BuildContext context, DeviceSubmitController _){
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          ///标题、报工方式选择
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

                ///报工方式选择
                if (_.isShowDataReportTypeBtn)
                  _.operationWayWidget(context),

                ///“补打”按钮
                if (_.isShowMakeUpBtn && !_.isBillDateChangedByNightTeam && _.submitType != AppConfig.weight)
                  _.makeUpBtnWidget(context),

                ///“需要检验”按钮
                if (_.isShowInspectFlagBtn && _.isCanClickInspectFlagBtn && _.submitType != AppConfig.weight)
                  _.inspectFlagBtnWidget(context)
                else if (_.isShowInspectFlagBtn && _.submitModel.inspectFlag == 1 && _.submitType != AppConfig.weight)
                  _.inspectFlagStrWidget(context),

                ///首检单提示
                if (_.cannotSubmitWhenNotPassFirstInspection && (_.submitModel.taskId ?? '').isNotEmpty)
                  _.firstInspectionWidget(context),

                ///获取根据首检生成的单重数据（获取实际单重数据）
                if (_.isShowGetPieceWeightBtn && _.submitType != AppConfig.weight)
                  _.pieceWeightBtn(context),

                ///按多箱报工时，是否显示称重消息传递过来的单箱重量、预计单箱数量
                if (_.isShowExpectSingleBoxQty && (_.submitType == AppConfig.qtyBoxSubmit || _.submitType == AppConfig.weightBoxSubmit))
                  _.expectSingleBoxQtyWidget(context)
              ],
            ),
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