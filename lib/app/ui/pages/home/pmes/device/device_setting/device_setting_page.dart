import 'package:basement/model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_setting/device_setting_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:flutter/material.dart';


///设备概览 - 参数设置
class DeviceSettingPage extends BaseSettingPage<DeviceSettingController>{

  @override
  List<Widget> tabPageView(BuildContext context, DeviceSettingController _) {
    return [
      depSettingWidget(context, _),
      deviceSettingWidget(context, _),
      interfaceSettingWidget(context, _),
      ttsSettingWidget(context, _),
      timerRefreshSettingWidget(context, _),
    ];
  }

  ///车间筛选
  Widget depSettingWidget(BuildContext context, DeviceSettingController _){
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
              itemCount: _.depList.length,
              itemBuilder: (BuildContext context, int index){
                DepartmentEntity item = _.depList[index];
                return CheckboxListTile(
                  title: Text(
                    '${item.enCode} ${item.fullName}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  value: item.isChoice,
                  onChanged: (bool? value) async {
                    controller.depOnChanged(item);
                  },
                );
              },
            )
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.depSave();
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

  ///设备筛选
  Widget deviceSettingWidget(BuildContext context, DeviceSettingController _){
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
              itemCount: _.deviceList.length,
              itemBuilder: (BuildContext context, int index){
                EAMDeviceModel item = _.deviceList[index];
                return CheckboxListTile(
                  title: Text(
                    '${item.deviceCode} ${item.deviceName}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  value: item.isChoice,
                  onChanged: (bool? value) async {
                    controller.deviceOnChanged(item);
                  },
                );
              },
            )
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.deviceSave();
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

  ///页面显示设置
  Widget interfaceSettingWidget(BuildContext context, DeviceSettingController _){
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    value: _.isBlink,
                    onChanged: (bool? bool) {
                      controller.isBlinkOnChanged();
                    },
                    title: Text(
                      '超产闪烁',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      '超产闪烁频率（毫秒）',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: SizedBox(
                        width: 150, height: 50,
                        child: TextField(
                          controller: _.rateTC,
                          focusNode: _.rateFN,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          onChanged: (String string){
                            controller.update();
                          },
                          decoration: InputDecoration(
                            hintText: _.rate.toString(),
                            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            suffixIcon: _.rateTC.text.isNotEmpty ?
                            MineIconButton(
                              icon: Icons.cancel,
                              iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                              tooltip: '清空',
                              onPressed: () {
                                _.rateTC.text = '';
                                controller.update();
                              },
                            ) :
                            null,
                          ),
                        )
                    ),
                  ),
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      '单个设备卡片显示的设备信息',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    children: [
                      RadioListTile(
                        value: 0,
                        groupValue: _.deviceShowInfoType,
                        onChanged: (int? index){
                          controller.deviceShowInfoTypeOnChanged(index!);
                        },
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text(
                          '设备编号',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      RadioListTile(
                        value: 1,
                        groupValue: _.deviceShowInfoType,
                        onChanged: (int? index){
                          controller.deviceShowInfoTypeOnChanged(index!);
                        },
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text(
                          '设备简称',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      RadioListTile(
                        value: 2,
                        groupValue: _.deviceShowInfoType,
                        onChanged: (int? index){
                          controller.deviceShowInfoTypeOnChanged(index!);
                        },
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text(
                          '设备名称',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.interfaceSave();
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

  ///语音播报设置
  Widget ttsSettingWidget(BuildContext context, DeviceSettingController _){
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    value: _.isOpenOverProductFlutterTts,
                    onChanged: (bool? bool) {
                      controller.overProductFlutterTtsOnChanged();
                    },
                    title: Text(
                      '超产语音播报',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    value: _.isOpenExceptionReportTts,
                    onChanged: (bool? bool) {
                      controller.isOpenExceptionReportTtsOnChanged();
                    },
                    title: Text(
                      '异常报告语音播报',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    value: _.isOpenAndonTts,
                    onChanged: (bool? bool) {
                      controller.isOpenAndonTtsOnChanged();
                    },
                    title: Text(
                      '全场呼叫语音播报',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      '超产预警（超产播报提前时间）（秒）',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: SizedBox(
                        width: 150, height: 50,
                        child: TextField(
                          controller: _.lTOPWFTTC,
                          focusNode: _.lTOPWFTFN,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          onChanged: (String string){
                            controller.update();
                          },
                          decoration: InputDecoration(
                            hintText: _.lTOPWFTTC.toString(),
                            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            suffixIcon: _.lTOPWFTTC.text.isNotEmpty ?
                            MineIconButton(
                              icon: Icons.cancel,
                              iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                              tooltip: '清空',
                              onPressed: () {
                                _.lTOPWFTTC.text = '';
                                controller.update();
                              },
                            ) :
                            null,
                          ),
                        )
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      '两次循环之间的间隔时间（秒）',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: SizedBox(
                        width: 150, height: 50,
                        child: TextField(
                          controller: _.tBCOPFTTC,
                          focusNode: _.tBCOPFTFN,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          onChanged: (String string){
                            controller.update();
                          },
                          decoration: InputDecoration(
                            hintText: _.tBCOPFTTC.toString(),
                            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            suffixIcon: _.tBCOPFTTC.text.isNotEmpty ?
                            MineIconButton(
                              icon: Icons.cancel,
                              iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                              tooltip: '清空',
                              onPressed: () {
                                _.tBCOPFTTC.text = '';
                                controller.update();
                              },
                            ) :
                            null,
                          ),
                        )
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      '单次循环的播报次数',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: SizedBox(
                        width: 150, height: 50,
                        child: TextField(
                          controller: _.nOECOPFTTC,
                          focusNode: _.nOECOPFTFN,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          onChanged: (String string){
                            controller.update();
                          },
                          decoration: InputDecoration(
                            hintText: _.nOECOPFTTC.toString(),
                            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            suffixIcon: _.nOECOPFTTC.text.isNotEmpty ?
                            MineIconButton(
                              icon: Icons.cancel,
                              iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                              tooltip: '清空',
                              onPressed: () {
                                _.nOECOPFTTC.text = '';
                                controller.update();
                              },
                            ) :
                            null,
                          ),
                        )
                    ),
                  ),
                ],
              ),
            )
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.ttsSave();
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

  Widget timerRefreshSettingWidget(BuildContext context, DeviceSettingController _){
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  value: _.isCanTimedRefresh,
                  onChanged: (bool? bool) {
                    controller.isCanTimedRefreshOnChanged();
                  },
                  title: Text(
                    '开启定时刷新',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  title: Text(
                    '刷新频率（秒）',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: SizedBox(
                    width: 150, height: 50,
                    child: TextField(
                      controller: _.secondOfRefreshTC,
                      focusNode: _.secondOfRefreshFN,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      onChanged: (String string){
                        controller.update();
                      },
                      decoration: InputDecoration(
                        hintText: _.secondOfRefreshTC.toString(),
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        suffixIcon: _.secondOfRefreshTC.text.isNotEmpty ?
                        MineIconButton(
                          icon: Icons.cancel,
                          iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                          tooltip: '清空',
                          onPressed: () {
                            _.secondOfRefreshTC.text = '';
                            controller.update();
                          },
                        ) :
                        null,
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
            await controller.timerRefreshSave();
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