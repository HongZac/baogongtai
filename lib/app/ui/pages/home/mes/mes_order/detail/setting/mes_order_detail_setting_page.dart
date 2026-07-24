
import 'package:basement/model.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/setting/mes_order_detail_setting_controller.dart';
import 'package:desktop/app/ui/widget/fluent_ui/tree_view/tree_view.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/touch_spin.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///生产任务单 详情页 设置页面
class MesOrderDetailSettingPage extends BaseSettingPage<MesOrderDetailSettingController>{

  @override
  List<Widget> tabPageView(BuildContext context, MesOrderDetailSettingController _) {
    return [
      if (_.type == 'tab')
        initialIndexWidget(context, _),

      if (_.type == 'tab' || _.type == 'submit')
        ...[
          submitInfoFormWidget(context, _),
          submitBtnWidget(context, _),
          submitFormWidget(context, _),
          submitFormSettingWidget(context, _),
          submitFormDeviceDepFilterWidget(context, _),
          submitFormDeviceClassFilterWidget(context, _),
          submitInvClassTemplateWidget(context, _),
        ],
      if (_.type == 'tab' || _.type == 'submitList')
        ...[
          submitListWidget(context, _),
        ],

      if (_.type == 'tab' || _.type == 'checkRecord')
        ...[
          checkRecordInfoFormWidget(context, _),
          checkRecordBtnWidget(context, _),
          checkRecordFormWidget(context, _),
          checkRecordFormSettingWidget(context, _),
          checkRecordFormDeviceDepFilterWidget(context, _),
          checkRecordFormDeviceClassFilterWidget(context, _),
          //checkRecordInvClassTemplateWidget(context, _),
        ],
      if (_.type == 'tab' || _.type == 'materialReject')
        ...[
          materialRejectInfoFormWidget(context, _),
          materialRejectBtnWidget(context, _),
          materialRejectFormWidget(context, _),
          materialRejectFormSettingWidget(context, _),
          //materialRejectInvClassTemplateWidget(context, _),
        ],
      if (_.type == 'tab' || _.type == 'checkRecordList')
        ...[
          checkRecordListWidget(context, _),
        ],
    ];
  }

  ///默认选项卡设置
  Widget initialIndexWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
              itemCount: _.detailTabList.length,
              itemBuilder: (BuildContext context, int index){
                ChoiceChipModel item = _.detailTabList[index];
                return RadioListTile(
                  title: Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  value: index,
                  groupValue: _.initialTabIndex,
                  onChanged: (int? int){
                    controller.initialIndexOnChanged(index);
                  },
                );
              },
            )
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.initialIndexSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
                const Size(2000, 70)
            ),
          ),
          child: Text(
            '确认修改',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ),
      ],
    );
  }

  ///生产报工-任务信息显示设置
  Widget submitInfoFormWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.infoFormSettingWidget(context, _.orderInfoFormListSubmit),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.submitInfoFormSave();
          },
        ),
      ],
    );
  }

  ///生产报工-按钮显示设置
  Widget submitBtnWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowDataReportTypeBtnSubmit,
                onChanged: (bool? bool) {
                  controller.isShowDataReportTypeBtnSubmitOnChanged();
                },
                title: Text(
                  '显示报工方式切换按钮',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '报工方式',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: List.generate(AppConfig.mesOrderSubmitOperationWayList.length, (index) {
                  ChoiceChipModel item = AppConfig.mesOrderSubmitOperationWayList[index];
                  return RadioListTile(
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: item.keyName,
                    groupValue: _.submitType,
                    onChanged: (String? string){
                      controller.submitTypeOnChanged(item);
                    },
                  );
                }).toList(),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowMakeUpBtnSubmit,
                onChanged: (bool? bool) {
                  controller.isShowMakeUpBtnSubmitOnChanged();
                },
                title: Text(
                  '显示“补打”按钮（当报工日期受班次影响时，始终不显示该按钮）',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowSelfInspectionBtn,
                onChanged: (bool? bool) {
                  controller.isShowSelfInspectionBtnOnChanged();
                },
                title: Text(
                  '显示“自检确认”按钮',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowMutualInspectionBtn,
                onChanged: (bool? bool) {
                  controller.isShowMutualInspectionBtnOnChanged();
                },
                title: Text(
                  '显示“互检确认”按钮',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowInspectFlagBtn,
                onChanged: (bool? bool) {
                  controller.isShowInspectFlagBtnOnChanged();
                },
                title: Text(
                  '显示“需要检验”按钮',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isCanClickInspectFlagBtn,
                onChanged: (bool? bool) {
                  controller.isCanClickInspectFlagBtnOnChanged();
                },
                title: Text(
                  '“需要检验”按钮可以点击修改',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '“需要检验”按钮的选中状态的默认值',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: Wrap(
                  runSpacing: 6, spacing: 6,
                  children: [
                    FilterChip(
                      selected: _.inspectFlagDefaultValue == null,
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      onSelected: (bool bool) {
                        controller.inspectFlagDefaultValueOnChanged(null);
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                      label: Text(
                        '无默认值',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    FilterChip(
                      selected: _.inspectFlagDefaultValue == true,
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      onSelected: (bool bool) {
                        controller.inspectFlagDefaultValueOnChanged(true);
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                      label: Text(
                        '默认选中',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    FilterChip(
                      selected: _.inspectFlagDefaultValue == false,
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      onSelected: (bool bool) {
                        controller.inspectFlagDefaultValueOnChanged(false);
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                      label: Text(
                        '默认不选中',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  ],
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowAutoCommitBtn,
                onChanged: (bool? bool) {
                  controller.isShowAutoCommitBtnOnChanged();
                },
                title: Text(
                  '按序列号报工时，显示“自动提交”按钮',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.autoCommitSubmit,
                onChanged: (bool? bool) {
                  controller.autoCommitSubmitOnChanged();
                },
                title: Text(
                  '按序列号报工时，默认选中“自动提交”按钮（扫描序列号后，自动提交报工数据）',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowOpTgSubmitQty,
                onChanged: (bool? bool) {
                  controller.isShowOpTgSubmitQtyOnChanged();
                },
                title: Text(
                  '显示报工汇总信息',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowOpDescriptionSubmit,
                onChanged: (bool? bool) {
                  controller.isShowOpDescriptionSubmitOnChanged();
                },
                title: Text(
                  '显示工序说明',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '报工提交按钮的显示',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: List.generate(AppConfig.submitBtnList.length, (index){
                  ChoiceChipModel item = AppConfig.submitBtnList[index];
                  return SwitchListTile(
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: _.submitBtnIndex & item.sign == item.sign,
                    onChanged: (bool boolValue){
                      controller.submitBtnIndexOnChanged(item.sign);
                    },
                  );
                }).toList(),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowWeightOverlay,
                onChanged: (bool? bool) {
                  controller.isShowWeightOverlayOnChanged();
                },
                title: Text(
                  '显示总重称重数据的强调显示窗口',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.submitBtnSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
                const Size(2000, 70)
            ),
          ),
          child: Text(
            '确认修改',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ),
      ],
    );
  }

  ///生产报工-表单填写项显示设置
  Widget submitFormWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.formSettingWidget(
            context,
            formTitleMap: _.formTitleMapSubmit,
            formStyleMap: _.formStyleMapSubmit,
            numPadFocusField: _.numPadFocusFieldSubmit,
            numPadFocusFieldOnChanged: (String field){
              _.numPadFocusFieldSubmit = field;
            },
          ),
        ),
        settingSaveBtnWidget(
            context,
            onPressed: () async {
              await controller.submitFormSave();
            }
        ),
      ],
    );
  }

  ///生产报工-表单填写设置
  Widget submitFormSettingWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '车间默认值获取方式',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: List.generate(AppConfig.depDefaultValueGetWayList.length, (index) {
                  ChoiceChipModel item = AppConfig.depDefaultValueGetWayList[index];
                  return RadioListTile(
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: index,
                    groupValue: _.depGetWayIndexSubmit,
                    onChanged: (int? int){
                      controller.depGetWayIndexSubmitOnChanged(index);
                    },
                  );
                }).toList(),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '产线数据的填报类型',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: List.generate(AppConfig.wcDataReportTypeList.length, (index) {
                  ChoiceChipModel item = AppConfig.wcDataReportTypeList[index];
                  return RadioListTile(
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: index,
                    groupValue: _.wcDataReportTypeSubmit,
                    onChanged: (int? int){
                      controller.wcDataReportTypeSubmitOnChanged(index);
                    },
                  );
                }).toList(),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isDeviceHasAdapterSubmit,
                onChanged: (bool? bool) {
                  controller.isDeviceHasAdapterSubmitOnChanged();
                },
                title: Text(
                  '设备填报使用选单模式',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isPsnHasAdapterSubmit,
                onChanged: (bool? bool) {
                  controller.isPsnHasAdapterSubmitOnChanged();
                },
                title: Text(
                  '生产人员填报使用选单模式',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isPsnMultiSubmit,
                onChanged: (bool? bool) {
                  controller.isPsnMultiSubmitOnChanged();
                },
                title: Text(
                  '可以选择多个生产人员',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '生产人员选单数据的筛选条件',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: [
                  ...List.generate(AppConfig.psnGetWayList.length, (index) {
                    ChoiceChipModel item = AppConfig.psnGetWayList[index];
                    return RadioListTile(
                      title: Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      value: index,
                      groupValue: _.psnGetWayIndexSubmit,
                      onChanged: (int? int){
                        controller.psnGetWayIndexSubmitOnChanged(index);
                      },
                    );
                  }).toList(),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    title: Text(
                      '固定车间的编号',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: SizedBox(
                      width: 190, height: 50,
                      child: TextField(
                        controller: _.psnDepCodeSubmitTC,
                        focusNode: _.psnDepCodeSubmitFN,
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLines: 1,
                        onChanged: (String string){
                          controller.update();
                        },
                        decoration: InputDecoration(
                          hintText: _.psnDepCodeSubmit,
                          hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          suffixIcon: _.psnDepCodeSubmitTC.text.isEmpty ? null : MineIconButton(
                            icon: Icons.cancel,
                            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                            tooltip: '清空',
                            onPressed: () {
                              _.psnDepCodeSubmitTC.clear();
                              controller.update();
                            },
                          ),
                        ),
                      )
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    title: Text(
                      '固定产线的编号',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: SizedBox(
                        width: 190, height: 50,
                        child: TextField(
                          controller: _.psnLineCodeSubmitTC,
                          focusNode: _.psnLineCodeSubmitFN,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          onChanged: (String string){
                            controller.update();
                          },
                          decoration: InputDecoration(
                            hintText: _.psnLineCodeSubmit,
                            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            suffixIcon: _.psnLineCodeSubmitTC.text.isEmpty ? null : MineIconButton(
                              icon: Icons.cancel,
                              iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                              tooltip: '清空',
                              onPressed: () {
                                _.psnLineCodeSubmitTC.clear();
                                controller.update();
                              },
                            ),
                          ),
                        )
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isSaveTheLastSelectedPsnIdSubmit,
                onChanged: (bool? bool) {
                  controller.isSaveTheLastSelectedPsnIdSubmitOnChanged();
                },
                title: Text(
                  '保存上次报工时选中的生产人员',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '“整箱箱数”可以填写的上限值',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: SizedBox(
                  width: 190, height: 50,
                  child: TextField(
                    controller: _.numMaxCountLimitTC,
                    focusNode: _.numMaxCountLimitFN,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 1,
                    onChanged: (String string){
                      controller.update();
                    },
                    decoration: InputDecoration(
                      hintText: _.numMaxCountLimit?.toString() ?? '',
                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      suffixIcon: _.numMaxCountLimitTC.text.isEmpty ? null : MineIconButton(
                        icon: Icons.cancel,
                        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        tooltip: '清空',
                        onPressed: () {
                          _.numMaxCountLimitTC.clear();
                          controller.update();
                        },
                      ),
                    ),
                  )
                ),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '“按托报工”时，报工数据的计算方式',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: List.generate(AppConfig.calcRuleForPalletSubmitTypeList.length, (index){
                  ChoiceChipModel item = AppConfig.calcRuleForPalletSubmitTypeList[index];
                  return RadioListTile(
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: index,
                    groupValue: _.calcRuleForPalletSubmitType,
                    onChanged: (int? int){
                      controller.calcRuleForPalletSubmitTypeOnChanged(index);
                    },
                  );
                }).toList(),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isSaveTheLastPackingWeightData,
                onChanged: (bool? bool) {
                  controller.isSaveTheLastPackingWeightDataOnChanged();
                },
                title: Text(
                  '保存上次报工时填写的皮重、单箱数量数据（或选择的装箱容器数据）',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isUsePackingPicker,
                onChanged: (bool? bool) {
                  controller.isUsePackingPickerOnChanged();
                },
                title: Text(
                  '通过选择装箱容器，自动填充“单箱皮重”、“单箱数量”',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isSingleBoxQtyOnlyChangedByContainer,
                onChanged: (bool? bool) {
                  controller.isSingleBoxQtyOnlyChangedByContainerOnChanged();
                },
                title: Text(
                  '“单箱数量”只能通过选择装箱容器来赋值，而不是手动输入',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '报工单条码打印模板的文件名称',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: SizedBox(
                  width: 190, height: 50,
                  child: TextField(
                    controller: _.frxNameSubmitTC,
                    focusNode: _.frxNameSubmitFN,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 1,
                    onChanged: (String string){
                      controller.update();
                    },
                    decoration: InputDecoration(
                      hintText: _.frxNameSubmit,
                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      suffixIcon: _.frxNameSubmitTC.text.isEmpty ? null : MineIconButton(
                        icon: Icons.cancel,
                        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        tooltip: '清空',
                        onPressed: () {
                          _.frxNameSubmitTC.clear();
                          controller.update();
                        },
                      ),
                    ),
                  )
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isGetBackAfterCommitSuccessSubmit,
                onChanged: (bool? bool) {
                  controller.isGetBackAfterCommitSuccessSubmitOnChanged();
                },
                title: Text(
                  '报工记录提交成功后，返回到首页',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.submitFormSettingSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
                const Size(2000, 70)
            ),
          ),
          child: Text(
            '确认修改',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ),
      ],
    );
  }

  ///生产报工-设备选单-车间过滤
  Widget submitFormDeviceDepFilterWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      controller.deviceDepSubmitAllOnChanged(allChoice: true);
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          kIsWeb || GetPlatform.isWindows
                              ? const EdgeInsets.symmetric(vertical: 18, horizontal: 14)
                              : const EdgeInsets.symmetric(vertical: 12, horizontal: 20)
                      ),
                    ),
                    child: Text(
                      '全\u00A0\u00A0选',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6,),
                  OutlinedButton(
                    onPressed: () {
                      controller.deviceDepSubmitAllOnChanged(allChoice: false);
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          kIsWeb || GetPlatform.isWindows
                              ? const EdgeInsets.symmetric(vertical: 18, horizontal: 14)
                              : const EdgeInsets.symmetric(vertical: 12, horizontal: 20)
                      ),
                    ),
                    child: Text(
                      '全不选',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6,),
                  OutlinedButton(
                    onPressed: () {
                      controller.deviceDepSubmitAllOnChanged(allChoice: null);
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          kIsWeb || GetPlatform.isWindows
                              ? const EdgeInsets.symmetric(vertical: 18, horizontal: 14)
                              : const EdgeInsets.symmetric(vertical: 12, horizontal: 20)
                      ),
                    ),
                    child: Text(
                      '反\u00A0\u00A0选',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  children: List.generate(_.deviceDepIdListSubmit.length, (index) {
                  DepartmentModel item = _.deviceDepIdListSubmit[index];
                  return CheckboxListTile(
                    title: Text(
                      '${item.enCode} ${item.fullName}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: item.isChoice,
                    onChanged: (bool? value) {
                      controller.deviceDepSubmitOnChanged(item);
                    },
                  );
                }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.submitFormDeviceDepFilterSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
                const Size(2000, 70)
            ),
          ),
          child: Text(
            '确认修改',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ),
      ],
    );
  }

  ///生产报工-设备选单-设备类别过滤
  Widget submitFormDeviceClassFilterWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: TreeView(
            selectionMode: TreeViewSelectionMode.singleIncludeParent,
            shrinkWrap: true,
            items: _.deviceClassTreeViewItemListSubmit,
            contentStyle: Theme.of(context).textTheme.bodyLarge,
            checkboxSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.6,
            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize!,
            onSelectionChanged: (Iterable<TreeViewItem> list) async{
              controller.deviceClassSubmitOnChanged(list.toList());
            },
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.submitFormDeviceClassFilterSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
                const Size(2000, 70)
            ),
          ),
          child: Text(
            '确认修改',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ),
      ],
    );
  }

  ///生产报工-产品类别打印模板设置
  Widget submitInvClassTemplateWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.invClassFrxNameMapSettingWidget(
            context,
            _.invClassFrxNameMapSubmit,
          ),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.submitInvClassTemplateSave();
          },
        ),
      ],
    );
  }

  ///报工单列表设置
  Widget submitListWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.customScrollInfoFormGroupSettingWidget(
            context,
            scrollController: _.submitListScrollController,
            sliverList: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '单页显示记录数',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: SizedBox(
                  width: 180,
                  child: TouchSpin(
                    width: 70,
                    numValue: _.pageConfigRowsSubmit.toDouble(),
                    numMin: 1,
                    step: 1,
                    point: 0,
                    textStyle: Theme.of(context).textTheme.titleLarge,
                    iconSize: Theme.of(context).textTheme.titleLarge!.fontSize! * 1.43,
                    addIcon: const Icon(Icons.add_circle_outline),
                    subtractIcon: const Icon(Icons.remove_circle_outline),
                    canInput: false,
                    numOnChanged: (value){
                      controller.pageConfigRowsSubmitOnChanged(value.toInt());
                    },
                  ),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '报工单删除时间限制（秒）',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: SizedBox(
                    width: 190, height: 50,
                    child: TextField(
                      controller: _.limitTimeSubmitTC,
                      focusNode: _.limitTimeSubmitFN,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      onChanged: (String string){
                        controller.update();
                      },
                      decoration: InputDecoration(
                        hintText: _.limitTimeSubmit?.toString() ?? '',
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        suffixIcon: _.limitTimeSubmitTC.text.isEmpty ? null : MineIconButton(
                          icon: Icons.cancel,
                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          tooltip: '清空',
                          onPressed: () {
                            _.limitTimeSubmitTC.clear();
                            controller.update();
                          },
                        ),
                      ),
                    )
                ),
              ),
            ],
            infoFormListMap: _.submitListInfoFormListMap,
          ),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.submitListSave();
          },
        ),
      ],
    );
  }

  ///次品录入-任务信息显示设置
  Widget checkRecordInfoFormWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.infoFormSettingWidget(context, _.orderInfoFormListCR),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.checkRecordInfoFormSave();
          },
        ),
      ],
    );
  }

  ///次品录入-按钮显示设置
  Widget checkRecordBtnWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowDataReportTypeBtnCR,
                onChanged: (bool? bool) {
                  controller.isShowDataReportTypeBtnCROnChanged();
                },
                title: Text(
                  '显示报次品方式切换按钮',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '报次品方式',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: List.generate(AppConfig.mesOrderCROperationWayList.length, (index) {
                  ChoiceChipModel item = AppConfig.mesOrderCROperationWayList[index];
                  return RadioListTile(
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: item.keyName,
                    groupValue: _.checkRecordType,
                    onChanged: (String? string){
                      controller.checkRecordTypeOnChanged(item);
                    },
                  );
                }).toList(),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowMakeUpBtnCR,
                onChanged: (bool? bool) {
                  controller.isShowMakeUpBtnCROnChanged();
                },
                title: Text(
                  '显示“补打”按钮（当生产日期受班次影响时，始终不显示该按钮）',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowOpDescriptionCR,
                onChanged: (bool? bool) {
                  controller.isShowOpDescriptionCROnChanged();
                },
                title: Text(
                  '显示工序说明',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '次品记录提交按钮的显示',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: List.generate(AppConfig.checkRecordBtnList.length, (index){
                  ChoiceChipModel item = AppConfig.checkRecordBtnList[index];
                  return SwitchListTile(
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: _.checkRecordBtnIndex & item.sign == item.sign,
                    onChanged: (bool boolValue){
                      controller.checkRecordBtnIndexOnChanged(item.sign);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.checkRecordBtnSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
                const Size(2000, 70)
            ),
          ),
          child: Text(
            '确认修改',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ),
      ],
    );
  }

  ///次品录入-表单填写项显示设置
  Widget checkRecordFormWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.formSettingWidget(
            context,
            formTitleMap: _.formTitleMapCR,
            formStyleMap: _.formStyleMapCR,
            numPadFocusField: _.numPadFocusFieldCR,
            numPadFocusFieldOnChanged: (String field){
              _.numPadFocusFieldCR = field;
            },
          ),
        ),
        settingSaveBtnWidget(
            context,
            onPressed: () async {
              await controller.checkRecordFormSave();
            }
        ),
      ],
    );
  }

  ///次品录入-表单填写设置
  Widget checkRecordFormSettingWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '车间默认值获取方式',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: List.generate(AppConfig.depDefaultValueGetWayList.length, (index) {
                  ChoiceChipModel item = AppConfig.depDefaultValueGetWayList[index];
                  return RadioListTile(
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: index,
                    groupValue: _.depGetWayIndexCR,
                    onChanged: (int? int){
                      controller.depGetWayIndexCROnChanged(index);
                    },
                  );
                }).toList(),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '产线数据的填报类型',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: List.generate(AppConfig.wcDataReportTypeList.length, (index) {
                  ChoiceChipModel item = AppConfig.wcDataReportTypeList[index];
                  return RadioListTile(
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: index,
                    groupValue: _.wcDataReportTypeCR,
                    onChanged: (int? int){
                      controller.wcDataReportTypeCROnChanged(index);
                    },
                  );
                }).toList(),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isDeviceHasAdapterCR,
                onChanged: (bool? bool) {
                  controller.isDeviceHasAdapterCROnChanged();
                },
                title: Text(
                  '设备填报使用选单模式',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isPsnHasAdapterCR,
                onChanged: (bool? bool) {
                  controller.isPsnHasAdapterCROnChanged();
                },
                title: Text(
                  '生产人员填报使用选单模式',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isPsnMultiCR,
                onChanged: (bool? bool) {
                  controller.isPsnMultiCROnChanged();
                },
                title: Text(
                  '可以选择多个生产人员',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '生产人员选单数据的筛选条件',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: [
                  ...List.generate(AppConfig.psnGetWayList.length, (index) {
                    ChoiceChipModel item = AppConfig.psnGetWayList[index];
                    return RadioListTile(
                      title: Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      value: index,
                      groupValue: _.psnGetWayIndexCR,
                      onChanged: (int? int){
                        controller.psnGetWayIndexCROnChanged(index);
                      },
                    );
                  }).toList(),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    title: Text(
                      '固定车间的编号',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: SizedBox(
                        width: 190, height: 50,
                        child: TextField(
                          controller: _.psnDepCodeCRTC,
                          focusNode: _.psnDepCodeCRFN,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          onChanged: (String string){
                            controller.update();
                          },
                          decoration: InputDecoration(
                            hintText: _.psnDepCodeCR,
                            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            suffixIcon: _.psnDepCodeCRTC.text.isEmpty ? null : MineIconButton(
                              icon: Icons.cancel,
                              iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                              tooltip: '清空',
                              onPressed: () {
                                _.psnDepCodeCRTC.clear();
                                controller.update();
                              },
                            ),
                          ),
                        )
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    title: Text(
                      '固定产线的编号',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: SizedBox(
                        width: 190, height: 50,
                        child: TextField(
                          controller: _.psnLineCodeCRTC,
                          focusNode: _.psnLineCodeCRFN,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          onChanged: (String string){
                            controller.update();
                          },
                          decoration: InputDecoration(
                            hintText: _.psnLineCodeCR,
                            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            suffixIcon: _.psnLineCodeCRTC.text.isEmpty ? null : MineIconButton(
                              icon: Icons.cancel,
                              iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                              tooltip: '清空',
                              onPressed: () {
                                _.psnLineCodeCRTC.clear();
                                controller.update();
                              },
                            ),
                          ),
                        )
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isSaveTheLastSelectedPsnIdCR,
                onChanged: (bool? bool) {
                  controller.isSaveTheLastSelectedPsnIdCROnChanged();
                },
                title: Text(
                  '保存上次报次品时选中的生产人员',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '次品条码打印模板的文件名称',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: SizedBox(
                    width: 190, height: 50,
                    child: TextField(
                      controller: _.frxNameCRTC,
                      focusNode: _.frxNameCRFN,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      onChanged: (String string){
                        controller.update();
                      },
                      decoration: InputDecoration(
                        hintText: _.frxNameCR,
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        suffixIcon: _.frxNameCRTC.text.isEmpty ? null : MineIconButton(
                          icon: Icons.cancel,
                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          tooltip: '清空',
                          onPressed: () {
                            _.frxNameCRTC.clear();
                            controller.update();
                          },
                        ),
                      ),
                    )
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isGetBackAfterCommitSuccessCR,
                onChanged: (bool? bool) {
                  controller.isGetBackAfterCommitSuccessCROnChanged();
                },
                title: Text(
                  '次品记录提交成功后，返回到首页',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.checkRecordFormSettingSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
                const Size(2000, 70)
            ),
          ),
          child: Text(
            '确认修改',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ),
      ],
    );
  }

  ///次品录入-设备选单-车间过滤
  Widget checkRecordFormDeviceDepFilterWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      controller.deviceDepCRAllOnChanged(allChoice: true);
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          kIsWeb || GetPlatform.isWindows
                              ? const EdgeInsets.symmetric(vertical: 18, horizontal: 14)
                              : const EdgeInsets.symmetric(vertical: 12, horizontal: 20)
                      ),
                    ),
                    child: Text(
                      '全\u00A0\u00A0选',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6,),
                  OutlinedButton(
                    onPressed: () {
                      controller.deviceDepCRAllOnChanged(allChoice: false);
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          kIsWeb || GetPlatform.isWindows
                              ? const EdgeInsets.symmetric(vertical: 18, horizontal: 14)
                              : const EdgeInsets.symmetric(vertical: 12, horizontal: 20)
                      ),
                    ),
                    child: Text(
                      '全不选',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6,),
                  OutlinedButton(
                    onPressed: () {
                      controller.deviceDepCRAllOnChanged(allChoice: null);
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          kIsWeb || GetPlatform.isWindows
                              ? const EdgeInsets.symmetric(vertical: 18, horizontal: 14)
                              : const EdgeInsets.symmetric(vertical: 12, horizontal: 20)
                      ),
                    ),
                    child: Text(
                      '反\u00A0\u00A0选',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  children: List.generate(_.deviceDepIdListCR.length, (index) {
                    DepartmentModel item = _.deviceDepIdListCR[index];
                    return CheckboxListTile(
                      title: Text(
                        '${item.enCode} ${item.fullName}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      value: item.isChoice,
                      onChanged: (bool? value) {
                        controller.deviceDepCROnChanged(item);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.checkRecordFormDeviceDepFilterSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
                const Size(2000, 70)
            ),
          ),
          child: Text(
            '确认修改',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ),
      ],
    );
  }

  ///次品录入-设备选单-设备类别过滤
  Widget checkRecordFormDeviceClassFilterWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: TreeView(
            selectionMode: TreeViewSelectionMode.singleIncludeParent,
            shrinkWrap: true,
            items: _.deviceClassTreeViewItemListCR,
            contentStyle: Theme.of(context).textTheme.bodyLarge,
            checkboxSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.6,
            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize!,
            onSelectionChanged: (Iterable<TreeViewItem> list) async{
              controller.deviceClassCROnChanged(list.toList());
            },
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.checkRecordFormDeviceClassFilterSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
                const Size(2000, 70)
            ),
          ),
          child: Text(
            '确认修改',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ),
      ],
    );
  }

  ///次品录入-产品类别打印模板设置
  Widget checkRecordInvClassTemplateWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.invClassFrxNameMapSettingWidget(
            context,
            _.invClassFrxNameMapCR,
          ),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.checkRecordInvClassTemplateSave();
          },
        ),
      ],
    );
  }

  ///不良品上报-任务信息显示设置
  Widget materialRejectInfoFormWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.infoFormSettingWidget(context, _.orderInfoFormListMR),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.materialRejectInfoFormSave();
          },
        ),
      ],
    );
  }

  ///不良品上报-按钮显示设置
  Widget materialRejectBtnWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowDataReportTypeBtnMR,
                onChanged: (bool? bool) {
                  controller.isShowDataReportTypeBtnMROnChanged();
                },
                title: Text(
                  '显示不良品上报方式切换按钮',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '不良品上报方式',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: List.generate(AppConfig.mesOrderMROperationWayList.length, (index) {
                  ChoiceChipModel item = AppConfig.mesOrderMROperationWayList[index];
                  return RadioListTile(
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: item.keyName,
                    groupValue: _.checkRecordTypeMR,
                    onChanged: (String? string){
                      controller.checkRecordTypeMROnChanged(item);
                    },
                  );
                }).toList(),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowMakeUpBtnMR,
                onChanged: (bool? bool) {
                  controller.isShowMakeUpBtnMROnChanged();
                },
                title: Text(
                  '显示“补打”按钮（当生产日期受班次影响时，始终不显示该按钮）',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '不良品记录提交按钮的显示',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: List.generate(AppConfig.materialRejectBtnList.length, (index){
                  ChoiceChipModel item = AppConfig.materialRejectBtnList[index];
                  return SwitchListTile(
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: _.checkRecordBtnIndexMR & item.sign == item.sign,
                    onChanged: (bool boolValue){
                      controller.checkRecordBtnIndexMROnChanged(item.sign);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.materialRejectBtnSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
                const Size(2000, 70)
            ),
          ),
          child: Text(
            '确认修改',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ),
      ],
    );
  }

  ///不良品上报-表单填写项显示设置
  Widget materialRejectFormWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.formSettingWidget(
            context,
            formTitleMap: _.formTitleMapMR,
            formStyleMap: _.formStyleMapMR,
            numPadFocusField: _.numPadFocusFieldMR,
            numPadFocusFieldOnChanged: (String field){
              _.numPadFocusFieldMR = field;
            },
          ),
        ),
        settingSaveBtnWidget(
            context,
            onPressed: () async {
              await controller.materialRejectFormSave();
            }
        ),
      ],
    );
  }

  ///不良品上报-表单填写设置
  Widget materialRejectFormSettingWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '车间默认值获取方式',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: List.generate(AppConfig.depDefaultValueGetWayList.length, (index) {
                  ChoiceChipModel item = AppConfig.depDefaultValueGetWayList[index];
                  return RadioListTile(
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: index,
                    groupValue: _.depGetWayIndexMR,
                    onChanged: (int? int){
                      controller.depGetWayIndexMROnChanged(index);
                    },
                  );
                }).toList(),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isPsnHasAdapterMR,
                onChanged: (bool? bool) {
                  controller.isPsnHasAdapterMROnChanged();
                },
                title: Text(
                  '生产人员填报使用选单模式',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isPsnMultiMR,
                onChanged: (bool? bool) {
                  controller.isPsnMultiMROnChanged();
                },
                title: Text(
                  '可以选择多个生产人员',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '生产人员选单数据的筛选条件',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: [
                  ...List.generate(AppConfig.psnGetWayListForMR.length, (index) {
                    ChoiceChipModel item = AppConfig.psnGetWayListForMR[index];
                    return RadioListTile(
                      title: Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      value: index,
                      groupValue: _.psnGetWayIndexMR,
                      onChanged: (int? int){
                        controller.psnGetWayIndexMROnChanged(index);
                      },
                    );
                  }).toList(),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    title: Text(
                      '固定车间的编号',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: SizedBox(
                        width: 190, height: 50,
                        child: TextField(
                          controller: _.psnDepCodeMRTC,
                          focusNode: _.psnDepCodeMRFN,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          onChanged: (String string){
                            controller.update();
                          },
                          decoration: InputDecoration(
                            hintText: _.psnDepCodeMR,
                            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            suffixIcon: _.psnDepCodeMRTC.text.isEmpty ? null : MineIconButton(
                              icon: Icons.cancel,
                              iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                              tooltip: '清空',
                              onPressed: () {
                                _.psnDepCodeMRTC.clear();
                                controller.update();
                              },
                            ),
                          ),
                        )
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    title: Text(
                      '固定产线的编号',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: SizedBox(
                        width: 190, height: 50,
                        child: TextField(
                          controller: _.psnLineCodeMRTC,
                          focusNode: _.psnLineCodeMRFN,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          onChanged: (String string){
                            controller.update();
                          },
                          decoration: InputDecoration(
                            hintText: _.psnLineCodeMR,
                            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            suffixIcon: _.psnLineCodeMRTC.text.isEmpty ? null : MineIconButton(
                              icon: Icons.cancel,
                              iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                              tooltip: '清空',
                              onPressed: () {
                                _.psnLineCodeMRTC.clear();
                                controller.update();
                              },
                            ),
                          ),
                        )
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isSaveTheLastSelectedPsnIdMR,
                onChanged: (bool? bool) {
                  controller.isSaveTheLastSelectedPsnIdMROnChanged();
                },
                title: Text(
                  '保存上次不良品上报时选中的生产人员',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '不良品上报条码打印模板的文件名称',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: SizedBox(
                    width: 190, height: 50,
                    child: TextField(
                      controller: _.frxNameMRTC,
                      focusNode: _.frxNameMRFN,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      onChanged: (String string){
                        controller.update();
                      },
                      decoration: InputDecoration(
                        hintText: _.frxNameMR,
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        suffixIcon: _.frxNameMRTC.text.isEmpty ? null : MineIconButton(
                          icon: Icons.cancel,
                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          tooltip: '清空',
                          onPressed: () {
                            _.frxNameMRTC.clear();
                            controller.update();
                          },
                        ),
                      ),
                    )
                ),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isGetBackAfterCommitSuccessMR,
                onChanged: (bool? bool) {
                  controller.isGetBackAfterCommitSuccessMROnChanged();
                },
                title: Text(
                  '不良品记录提交成功后，返回到首页',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.materialRejectFormSettingSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(
                const Size(2000, 70)
            ),
          ),
          child: Text(
            '确认修改',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ),
      ],
    );
  }

  ///不良品上报-产品类别打印模板设置
  Widget materialRejectInvClassTemplateWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.invClassFrxNameMapSettingWidget(
            context,
            _.invClassFrxNameMapMR,
          ),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.materialRejectInvClassTemplateSave();
          },
        ),
      ],
    );
  }

  ///次品单列表设置
  Widget checkRecordListWidget(BuildContext context, MesOrderDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.customScrollInfoFormGroupSettingWidget(
            context,
            scrollController: _.checkRecordListScrollController,
            sliverList: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '单页显示记录数',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: SizedBox(
                  width: 180,
                  child: TouchSpin(
                    width: 70,
                    numValue: _.pageConfigRowsCR.toDouble(),
                    numMin: 1,
                    step: 1,
                    point: 0,
                    textStyle: Theme.of(context).textTheme.titleLarge,
                    iconSize: Theme.of(context).textTheme.titleLarge!.fontSize! * 1.43,
                    addIcon: const Icon(Icons.add_circle_outline),
                    subtractIcon: const Icon(Icons.remove_circle_outline),
                    canInput: false,
                    numOnChanged: (value){
                      controller.pageConfigRowsCROnChanged(value.toInt());
                    },
                  ),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '次品记录删除时间限制（秒）',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: SizedBox(
                    width: 190, height: 50,
                    child: TextField(
                      controller: _.limitTimeCRTC,
                      focusNode: _.limitTimeCRFN,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      onChanged: (String string){
                        controller.update();
                      },
                      decoration: InputDecoration(
                        hintText: _.limitTimeCR?.toString() ?? '',
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        suffixIcon: _.limitTimeCRTC.text.isEmpty ? null : MineIconButton(
                          icon: Icons.cancel,
                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          tooltip: '清空',
                          onPressed: () {
                            _.limitTimeCRTC.clear();
                            controller.update();
                          },
                        ),
                      ),
                    )
                ),
              ),
            ],
            infoFormListMap: _.checkRecordListInfoFormListMap,
          ),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.checkRecordListSave();
          },
        ),
      ],
    );
  }

}