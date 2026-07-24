

import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_page.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/setting/inv_barcode_detail_setting_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/touch_spin.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';

///物料条码新增查看 详情页 设置页面
class InvBarcodeDetailSettingPage extends BaseSettingPage<InvBarcodeDetailSettingController> {

  @override
  List<Widget> tabPageView(BuildContext context, InvBarcodeDetailSettingController _) {
    return [
      if (_.type == 'tab')
        initialIndexWidget(context, _),

      if (_.type == 'tab' || _.type == 'save')
        ...[
          invInfoFormWidget(context, _),
          btnWidget(context, _),
          reportFormWidget(context, _),
          reportFormSettingWidget(context, _),
          invBarcodeInvClassTemplateWidget(context, _),
        ],
      if (_.type == 'tab' || _.type == 'list')
        ...[
          invBarcodeListWidget(context, _),
        ],
    ];
  }

  Widget initialIndexWidget(BuildContext context, InvBarcodeDetailSettingController _){
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
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.initialIndexSave();
          }
        ),
      ],
    );
  }

  Widget invInfoFormWidget(BuildContext context, InvBarcodeDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.infoFormSettingWidget(context, _.invInfoFormList),
        ),
        settingSaveBtnWidget(
            context,
            onPressed: () async {
              await controller.infoFormSave();
            }
        ),
      ],
    );
  }

  Widget btnWidget(BuildContext context, InvBarcodeDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isShowSaveTypeBtn,
                onChanged: (bool? bool) {
                  controller.isShowSaveTypeBtnOnChanged();
                },
                title: Text(
                  '显示填报方式切换按钮',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '填报方式',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                children: List.generate(AppConfig.invBarcodeOperationWayList.length, (index) {
                  ChoiceChipModel item = AppConfig.invBarcodeOperationWayList[index];
                  return RadioListTile(
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    value: item.keyName,
                    groupValue: _.saveType,
                    onChanged: (String? string){
                      controller.saveTypeOnChanged(item);
                    },
                  );
                }).toList(),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '条码提交按钮的显示',
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
                    value: _.invBarcodeSaveBtnIndex & item.sign == item.sign,
                    onChanged: (bool boolValue){
                      controller.invBarcodeSaveBtnIndexOnChanged(item.sign);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        settingSaveBtnWidget(
            context,
            onPressed: () async {
              await controller.btnSave();
            }
        ),
      ],
    );
  }

  Widget reportFormWidget(BuildContext context, InvBarcodeDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: controller.customScrollFormGroupSettingWidget(
            context,
            scrollController: _.formScrollController,
            sliverList: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '单列可显示的表单填写项的行数',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: SizedBox(
                    width: 190, height: 50,
                    child: TextField(
                      controller: _.formRowMaxCountLimitTC,
                      focusNode: _.formRowMaxCountLimitFN,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      onChanged: (String string){
                        controller.update();
                      },
                      decoration: InputDecoration(
                        hintText: _.formRowMaxCountLimit?.toString() ?? '',
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        suffixIcon: _.formRowMaxCountLimitTC.text.isEmpty ? null : MineIconButton(
                          icon: Icons.cancel,
                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          tooltip: '清空',
                          onPressed: () {
                            _.formRowMaxCountLimitTC.clear();
                            controller.update();
                          },
                        ),
                      ),
                    )
                ),
              ),
            ],
            formTitleMap: _.formTitleMap,
            formStyleMap: _.formStyleMap,
            numPadFocusField: _.numPadFocusField,
            numPadFocusFieldOnChanged: (String field){
              _.numPadFocusField = field;
            },
          ),
        ),
        settingSaveBtnWidget(
            context,
            onPressed: () async {
              await controller.reportFormSave();
            }
        ),
      ],
    );
  }

  Widget reportFormSettingWidget(BuildContext context, InvBarcodeDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.weightIsAddPieceWeightToTotal,
                onChanged: (bool? bool) {
                  controller.weightIsAddPieceWeightToTotalOnChanged();
                },
                title: Text(
                  '按重量填报时，产品称重的数据加到总数据上',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '“按托填报”时，填报数据的计算方式',
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
                    groupValue: _.calcRuleForPalletSaveType,
                    onChanged: (int? int){
                      controller.calcRuleForPalletSaveTypeOnChanged(index);
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
                  //'保存上次提交物料条码时的填写的皮重数据或选择的装箱容器数据',
                  '保存上次提交物料条码时的填写的单箱数量数据或选择的装箱容器数据',
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
                  //'通过选择装箱容器，自动填充“单箱皮重”、“单箱数量”',
                  '通过选择装箱容器，自动填充“单箱数量”',
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
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                value: _.isGetBackAfterSaveSuccess,
                onChanged: (bool? bool) {
                  controller.isGetBackAfterSaveSuccessOnChanged();
                },
                title: Text(
                  '物料条码提交提交成功后，返回到首页',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        settingSaveBtnWidget(
            context,
            onPressed: () async {
              await controller.reportFormSettingSave();
            }
        ),
      ],
    );
  }

  Widget invBarcodeInvClassTemplateWidget(BuildContext context, InvBarcodeDetailSettingController _){
    return Column(
      children: [
          Expanded(
          child: controller.invClassFrxNameMapSettingWidget(
            context,
            _.invClassFrxNameMap,
          ),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.invClassTemplateSave();
          },
        ),
      ]
      ,
    );
  }

  Widget invBarcodeListWidget(BuildContext context, InvBarcodeDetailSettingController _) {
    return Column(
      children: [
        Expanded(
          child: controller.customScrollInfoFormGroupSettingWidget(
            context,
            scrollController: _.invBarcodeListScrollController,
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
                    numValue: _.pageConfigRows.toDouble(),
                    numMin: 1,
                    step: 1,
                    point: 0,
                    textStyle: Theme.of(context).textTheme.titleLarge,
                    iconSize: Theme.of(context).textTheme.titleLarge!.fontSize! * 1.43,
                    addIcon: const Icon(Icons.add_circle_outline),
                    subtractIcon: const Icon(Icons.remove_circle_outline),
                    canInput: false,
                    numOnChanged: (value){
                      controller.pageConfigRowsOnChanged(value.toInt());
                    },
                  ),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '物料条码删除时间限制（秒）',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: SizedBox(
                    width: 190, height: 50,
                    child: TextField(
                      controller: _.limitTimeTC,
                      focusNode: _.limitTimeFN,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      onChanged: (String string){
                        controller.update();
                      },
                      decoration: InputDecoration(
                        hintText: _.limitTime?.toString() ?? '',
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        suffixIcon: _.limitTimeTC.text.isEmpty ? null : MineIconButton(
                          icon: Icons.cancel,
                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          tooltip: '清空',
                          onPressed: () {
                            _.limitTimeTC.clear();
                            controller.update();
                          },
                        ),
                      ),
                    )
                ),
              ),
            ],
            infoFormListMap: _.invBarcodeListInfoFormListMap,
          ),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.invBarcodeListSave();
          },
        ),
      ],
    );
  }

}