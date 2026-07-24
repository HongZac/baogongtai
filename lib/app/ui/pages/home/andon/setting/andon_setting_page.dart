import 'package:basement/model.dart';
import 'package:desktop/app/ui/pages/home/andon/setting/andon_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_page.dart';
import 'package:flutter/material.dart';


///安灯系统 --全场呼叫系统 设置页面
class AndonSettingPage extends BaseSettingPage<AndonSettingController>{

  @override
  List<Widget> tabPageView(BuildContext context, AndonSettingController _) {
    return [
      signSettingWidget(context, _),
      depSettingWidget(context, _),
      andonClassSettingWidget(context, _),
      dateSettingWidget(context, _),
      uiSettingWidget(context, _),
    ];
  }

  ///状态标签设置
  Widget signSettingWidget(BuildContext context, AndonSettingController _){
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  controller.isShowSignFilterWidget(context),
                  controller.isSignChipMultiWidget(context),
                  controller.signChoiceWidget(context),
                ],
              ),
            )
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.signSettingSave();
          },
        ),
      ],
    );
  }

  ///车间过滤设置
  Widget depSettingWidget(BuildContext context, AndonSettingController _){
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  controller.isShowDepPickerWidget(context),
                  controller.depChoiceTileWidget(context),
                ],
              ),
            )
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.depSettingSave();
          },
        ),
      ],
    );
  }

  ///日期过滤设置
  Widget dateSettingWidget(BuildContext context, AndonSettingController _){
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  controller.isShowDatePickerWidget(context),
                  controller.datePickerEnumIndexChoiceWidget(context),
                ],
              ),
            )
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.dateSettingSave();
          },
        ),
      ],
    );
  }

  Widget andonClassSettingWidget(BuildContext context, AndonSettingController _){
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  value: _.isShowAndonClassPicker,
                  onChanged: (bool? bool) {
                    controller.isShowAndonClassPickerOnChanged();
                  },
                  title: Text(
                    '显示全场呼叫类型筛选器',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '全场呼叫类型筛选器初始选中对象',
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  children: List.generate(_.andonClassList.length, (index){
                    MoAndonClassModel item = _.andonClassList[index];
                    return RadioListTile(
                      title: Text(
                        '${item.classCode} ${item.className}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      value: item.id,
                      groupValue: _.andonServiceClassId,
                      onChanged: (String? id){
                        controller.andonClassOnChanged(item);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.andonClassSettingSave();
          },
        ),
      ],
    );
  }

  Widget uiSettingWidget(BuildContext context, AndonSettingController _){
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  controller.pageConfigRowsChoiceWidget(
                      context,
                      pageConfigRows: _.pageConfigRows,
                      pageConfigRowsOnChanged: (int index){
                        controller.pageConfigRowsOnChanged(index);
                      }
                  ),
                ],
              ),
            )
        ),
        settingSaveBtnWidget(
          context,
          onPressed: () async {
            await controller.uiSettingSave();
          },
        ),
      ],
    );
  }

}