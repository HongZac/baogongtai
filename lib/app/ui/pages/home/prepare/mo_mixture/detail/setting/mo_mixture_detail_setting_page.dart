import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_page.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/setting/mo_mixture_detail_setting_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';

///拌料单 OR 粉料单 详情页 设置页面
class MoMixtureDetailSettingPage extends BaseSettingPage<MoMixtureDetailSettingController>{

  @override
  List<Widget> tabPageView(BuildContext context, MoMixtureDetailSettingController _) {
    return [
      initialIndexWidget(context, _),
      submitWidget(context, _),
    ];
  }

  Widget initialIndexWidget(BuildContext context, MoMixtureDetailSettingController _){
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
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

  Widget submitWidget(BuildContext context, MoMixtureDetailSettingController _){
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  title: Text(
                    '生产人员选单列表的筛选条件',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  children: [
                    SizedBox(
                      height: 72.0 * AppConfig.psnGetWayList.length,
                      child: ListView.builder(
                        itemCount: AppConfig.psnGetWayList.length,
                        itemBuilder: (BuildContext context, int index){
                          ChoiceChipModel item = AppConfig.psnGetWayList[index];
                          return RadioListTile(
                            title: Text(
                              item.title,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            controlAffinity: ListTileControlAffinity.trailing,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            value: index,
                            groupValue: _.submitPsnGetWayIndex,
                            onChanged: (int? int){
                              controller.submitPsnGetWayIndexOnChanged(index);
                            },
                          );
                        },
                      ),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      title: Text(
                        '固定车间的编号',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      trailing: SizedBox(
                        width: 150, height: 50,
                        child: TextField(
                          controller: _.submitPsnDepCodeTC,
                          focusNode: _.submitPsnDepCodeFN,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          onChanged: (String string){
                            controller.update();
                          },
                          decoration: InputDecoration(
                            hintText: _.submitPsnDepCode.toString(),
                            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            suffixIcon: _.submitPsnDepCodeTC.text.isEmpty ? null : MineIconButton(
                              icon: Icons.cancel,
                              iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                              tooltip: '清空',
                              onPressed: () {
                                _.submitPsnDepCodeTC.text = '';
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  value: _.isSubmitPsnHasAdapter,
                  onChanged: (bool? bool) {
                    controller.isSubmitPsnHasAdapterOnChanged();
                  },
                  title: Text(
                    '生产人员填报使用选单模式',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  title: Text(
                    '报工单可删除的时间限制（秒）',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: SizedBox(
                    width: 150, height: 50,
                    child: TextField(
                      controller: _.submitLimitTimeTC,
                      focusNode: _.submitLimitTimeFN,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      onChanged: (String string){
                        controller.update();
                      },
                      decoration: InputDecoration(
                        hintText: (_.submitLimitTime ?? '').toString(),
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        suffixIcon: _.submitLimitTimeTC.text.isEmpty ? null : MineIconButton(
                          icon: Icons.cancel,
                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          tooltip: '清空',
                          onPressed: () {
                            _.submitLimitTimeTC.text = '';
                            controller.update();
                          },
                        ),
                      ),
                    )
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  title: Text(
                    '报工单打印模板名称',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: SizedBox(
                    width: 200, height: 50,
                    child: TextField(
                      controller: _.submitPrinterFrxNameTC,
                      focusNode: _.submitPrinterFrxNameFN,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      onChanged: (String string){
                        controller.update();
                      },
                      decoration: InputDecoration(
                        hintText: _.submitPrinterFrxName.toString(),
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        suffixIcon: _.submitPrinterFrxNameTC.text.isEmpty ? null : MineIconButton(
                          icon: Icons.cancel,
                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          tooltip: '清空',
                          onPressed: () {
                            _.submitPrinterFrxNameTC.text = '';
                            controller.update();
                          },
                        ),
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.submitSave();
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

}