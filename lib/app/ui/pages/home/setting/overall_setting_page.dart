import 'dart:core';

import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_model.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/translation/language_config.dart';
import 'package:desktop/app/ui/widget/color_picker.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/popup_menu/popup_menu_position_delegate.dart';
import 'package:desktop/app/ui/widget/touch_spin.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PopupMenuPosition;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

import 'overall_setting_controller.dart';


///全局设置
class OverallSettingPage extends GetView<OverallSettingController> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OverallSettingController>(tag: tag, builder: (_){
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (GetPlatform.isAndroid){
            ///点击空白关闭软键盘
            FocusManager.instance.primaryFocus?.unfocus();
            ///全屏，关闭状态栏
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          }
        },
        child: contentWidget(context, _),
      );
    }, initState: (GetBuilderState<OverallSettingController> state){
      MineGetDelegate().pageInitState(controller);
    }, dispose: (GetBuilderState<OverallSettingController> state){
      try {
        MineGetDelegate().pageDispose(controller);
      } catch(e){}
    },);
  }

  Widget contentWidget(BuildContext context, OverallSettingController _) {
    return Container(
      alignment: Alignment.topCenter,
      child: ScrollbarTheme(
        data: ScrollbarThemeData(
          interactive: false,
          thumbVisibility: WidgetStateProperty.all(false),
          trackVisibility: WidgetStateProperty.all(false),
          thumbColor: WidgetStateProperty.all(Colors.transparent),
          trackColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Column(
          children: [
            ///主内容
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: AppConfig.tabWidth,
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      controller: _.leftScrollController,
                      child: Container(
                        height: (kIsWeb || GetPlatform.isWindows
                            ? 60.0
                            : 70.0) * _.tabValueList.length,
                        alignment: Alignment.topCenter,
                        child: ExtendedTabBar(
                          indicatorWeight: 0,
                          indicatorPadding: EdgeInsets.zero,
                          labelPadding: EdgeInsets.zero,
                          indicator: ColorTabIndicator(Theme.of(context).colorScheme.primary),
                          scrollDirection: Axis.vertical,
                          controller: _.tabController,
                          tabs: List.generate(_.tabValueList.length, (index) {
                            ChoiceChipModel item = _.tabValueList[index];
                            return tabBarItem(context, item, index);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  const VerticalDivider(indent: 0, endIndent: 0,),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ExtendedTabBarView(
                        physics: const NeverScrollableScrollPhysics(), ///禁止滑动
                        controller: _.tabController,
                        children: tabPageView(context, _),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget tabBarItem(BuildContext context, ChoiceChipModel item, int index){
    return Material(
        elevation: 0,
        color: item.isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: Icon(
            item.icon,
            size: Theme.of(context).textTheme.titleMedium!.fontSize! * 1.43,
          ),
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: item.isSelected ? Colors.white : null,
            ),
          ),
          trailing: item.isSelected ? Icon(
            Icons.arrow_right,
            size: Theme.of(context).textTheme.titleMedium!.fontSize! * 1.43,
          ) : null,
          dense: true,
          minLeadingWidth: 4,
          textColor: item.isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          iconColor: item.isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          onTap: () async {
            controller.tabOnChanged(item, index);
          },
        )
    );
  }


  List<Widget> tabPageView(BuildContext context, OverallSettingController _) {
    return [
      tabWidget(context, _),
      printWidget(context, _),
      weightMsgWidget(context, _),
      ttsWidget(context, _),
      themeWidget(context, _),
      languageWidget(context, _),
      fontWidget(context, _),
      inputWidget(context, _),
      interfaceWidget(context, _),
    ];
  }


  Widget tabWidget(BuildContext context, OverallSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _.destinationList.length,
            itemBuilder: (BuildContext context, int index){
              ChoiceChipModel item = _.destinationList[index];
              return Material(
                child: RadioListTile(
                  title: Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  value: item.keyName,
                  groupValue: _.destinationKeyName,
                  onChanged: (String? str){
                    controller.initialKeyNameOnChanged(str);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.tabSave();
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

  Widget printWidget(BuildContext context, OverallSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              if (!kIsWeb && GetPlatform.isWindows)
                Material(
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    expandedAlignment: Alignment.topLeft,
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    title: Text(
                      '打印机选择',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    children: List.generate(_.printerList.length, (index) {
                      Printer item = _.printerList[index];
                      return RadioListTile(
                        title: Text(
                          item.name,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        value: item.url,
                        groupValue: _.printerUrl,
                        onChanged: (String? str){
                          controller.printerOnChanged(item);
                        },
                      );
                    }).toList(),
                  )
                ),
              ListTile(
                title: Text('默认打印份数', style: Theme.of(context).textTheme.bodyLarge,),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                trailing: ttsTouchSpin(
                    context, _, _.defaultPrintCopies, 1, 10, 1, 0, controller.onChangedDefaultPrintCopies
                ),
              ),
              Material(
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  expandedAlignment: Alignment.topLeft,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: Text(
                    '打印方式选择',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  children: List.generate(AppConfig.printTypeList.length, (index) {
                    ChoiceChipModel item = AppConfig.printTypeList[index];
                    return RadioListTile(
                      title: Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      value: item.keyName,
                      groupValue: _.printType,
                      onChanged: (String? str){
                        controller.printTypeOnChanged(str!);
                      },
                    );
                  }).toList(),
                )
              ),
              Material(
                child: SwitchListTile(
                  title: Text(
                    '打印时显示参数设置（仅支持本地打印）',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  value: _.isShowPrintSetting,
                  onChanged: (bool value){
                    controller.isShowPrintSettingOnChanged(value);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.printSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(2000, 70)),
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

  Widget weightMsgWidget(BuildContext context, OverallSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: List.generate(_.weightMsgConnectService.weightMsgList.length, (index){
              ChoiceChipModel item = _.weightMsgConnectService.weightMsgList[index];
              WeightMsgConnectModel? model = _.weightMsgConnectService.connectList.firstWhereOrNull(
                      (element) => element.key == item.keyName);
              return ListTile(
                title: Text(
                  '${item.title}',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600
                  ),
                ),
                subtitle: Text(
                  '${model != null ? '${model.host}:${model.port} （${model.accuracy}；${model.isWeightMsgReverseOrder ? '反向' : ''}）' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.outline
                  ), maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: () async{
                        await controller.weightMsgConnectService.setting(item.keyName);
                      },
                      child: Text(
                        '修改',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4,),
                    FilledButton(
                      onPressed: () async{
                        await controller.weightMsgConnectService.delete(item.keyName);
                      },
                      child: Text(
                        '删除',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ],
                )
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget ttsWidget(BuildContext context, OverallSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              if (GetPlatform.isAndroid)
                Material(
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      '语音包引擎选择(仅支持Android端)',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    children: List.generate(_.enginesList.length, (index){
                      Object? item = _.enginesList[index];
                      return RadioListTile(
                        title: Text(
                          (item ?? '').toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        value: index,
                        groupValue: _.flutterTtsEngines,
                        onChanged: (Object? key){
                          controller.flutterTtsEnginesOnChanged(index);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ListTile(
                title: Text('音量', style: Theme.of(context).textTheme.bodyLarge,),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                trailing: ttsTouchSpin(
                    context, _, _.flutterTtsVolume, 0, 1, 0.1, 1, controller.onChangedVolume
                ),
              ),
              ListTile(
                title: Text('语速', style: Theme.of(context).textTheme.bodyLarge,),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                trailing: ttsTouchSpin(
                    context, _, _.flutterTtsSpeechRate, 0, 1, 0.1, 1, controller.onChangedSpeechRate
                ),
              ),
              ListTile(
                title: Text('音调', style: Theme.of(context).textTheme.bodyLarge,),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                trailing: ttsTouchSpin(
                    context, _, _.flutterTtsPitch, 0.5, 2, 0.1, 1, controller.onChangedPitch
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.ttsSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(2000, 70)),
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
  Widget ttsTouchSpin(BuildContext context, OverallSettingController _,
      double value, double? min, double? max, double? step, int point, ValueChanged<double> onChanged){
    return TouchSpin(
      width: 140,
      numValue: value,
      numMin: min,
      numMax: max,
      step: step,
      point: point,
      textStyle: Theme.of(context).textTheme.bodyLarge,
      iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
      addIcon: const Icon(Icons.add_circle_outline),
      subtractIcon: const Icon(Icons.remove_circle_outline),
      canInput: false,
      numOnChanged: (value){
        onChanged(value);
      },
      enabled: true,
    );
  }

  Widget themeWidget(BuildContext context, OverallSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Material(
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  expandedAlignment: Alignment.topLeft,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: Text(
                    '主题选择',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  children: List.generate(AppConfig.themeList.length, (index) {
                    ChoiceChipModel item = AppConfig.themeList[index];
                    return RadioListTile(
                      title: Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      value: item.keyName,
                      groupValue: _.themeModeKey,
                      onChanged: (String? str){
                        controller.themeOnChanged(item);
                      },
                    );
                  }).toList(),
                ),
              ),
              Material(
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  expandedAlignment: Alignment.topLeft,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: Text(
                    '配色方案',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      title: Text(
                          '主要重点色',
                          style: Theme.of(context).textTheme.bodyLarge
                      ),
                      trailing:colorCard(_, 'primary'),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      title: Text(
                          '次要重点色',
                          style: Theme.of(context).textTheme.bodyLarge
                      ),
                      trailing:colorCard(_, 'secondary'),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      title: Text(
                          '平衡色',
                          style: Theme.of(context).textTheme.bodyLarge
                      ),
                      trailing:colorCard(_, 'tertiary'),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      title: Text(
                          '背景色、以及高度强调的文本和图标',
                          style: Theme.of(context).textTheme.bodyLarge
                      ),
                      trailing:colorCard(_, 'neutral'),
                    ),
                  ],
                )
              ),
            ],
          ),
        ),

        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.themeSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(2000, 70)),
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
  Widget colorCard(OverallSettingController _, String key){
    Color color = const Color(0xFF000000);
    switch (key){
      case 'primary':
        color = _.material3ThemeBuilder.primaryKeyColor;
        break;
      case 'secondary':
        color = _.material3ThemeBuilder.secondaryKeyColor;
        break;
      case 'tertiary':
        color = _.material3ThemeBuilder.tertiaryKeyColor;
        break;
      case 'neutral':
        color = _.material3ThemeBuilder.neutralKeyColor;
        break;
    }
    return MineColorPicker(
        color: color,
        iconSize: 30,
        boxSize: const Size(30, 22),
        position: PopupMenuPosition.LEFT,
        verticalOffset: -30,
        horizontalOffset: -180,
        onChanged: (Color color){
          controller.colorOnChanged(key, color);
        }
    );
  }

  Widget languageWidget(BuildContext context, OverallSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Material(
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  expandedAlignment: Alignment.topLeft,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: Text(
                    '语言切换',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  children: LanguageConfig.supportLanguage.keys.map((e) {
                    return RadioListTile(
                      title: Text(
                        LanguageConfig.supportLanguage[e]['zhName'],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      value: e,
                      groupValue: _.selectedLocale.languageCode,
                      onChanged: (String? str){
                        controller.languageOnChanged(LanguageConfig.supportLanguage[e]);
                      },
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ),

        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.languageSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(2000, 70)),
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

  Widget fontWidget(BuildContext context, OverallSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                title: Text(
                  '文本比例',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: SizedBox(
                width: 150, height: 50,
                child: TextField(
                  controller: _.textScaleTC,
                  focusNode: _.textScaleFN,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 1,
                  onChanged: (String string){
                    controller.update();
                  },
                  decoration: InputDecoration(
                    hintText: _.textScale.toString(),
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                        fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    suffixIcon: _.textScaleTC.text.isNotEmpty ? MineIconButton(
                      icon: Icons.cancel,
                      iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                      tooltip: '清空',
                      onPressed: () {
                        _.textScaleTC.text = '';
                        controller.update();
                      },
                    ) :
                    null,
                  ),
                )
                ),
              ),
              Material(
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  expandedAlignment: Alignment.topLeft,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: Text(
                    '字体切换',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  children: FontFamilyConfig.supportFontFamily.keys.map((e) {
                    return RadioListTile(
                      title: Text(
                        FontFamilyConfig.supportFontFamily[e]['zhName'],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      value: e,
                      groupValue: _.fontFamily,
                      onChanged: (String? str){
                        controller.fontFamilyOnChanged(FontFamilyConfig.supportFontFamily[e]);
                      },
                    );
                  }).toList(),
                )
              ),
            ],
          ),
        ),

        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.fontSave();
          },
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(2000, 70)),
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

  Widget inputWidget(BuildContext context, OverallSettingController _){
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Material(
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  value: _.isKeyboardOpenAfterClickTC,
                  onChanged: (bool? bool) {
                    controller.isKeyboardOpenAfterClickTCOnChanged();
                  },
                  title: Text(
                    'Windows平台下，点击输入框时，弹出软键盘',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 4,),

        FilledButton(
          onPressed: () async{
            await controller.inputSave();
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

  Widget interfaceWidget(BuildContext context, OverallSettingController _){
    TipsShowType.values;
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Material(
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    expandedAlignment: Alignment.topLeft,
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    title: Text(
                      '错误提示信息显示方式',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    children: List.generate(AppConfig.tipsShowTypeList.length, (index) {
                      ChoiceChipModel item = AppConfig.tipsShowTypeList[index];
                      return RadioListTile(
                        title: Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        value: item.keyName,
                        groupValue: _.tipsShowTypeStr,
                        onChanged: (String? str){
                          controller.tipsShowTypeStrOnChanged(str!);
                        },
                      );
                    }).toList(),
                  )
              ),

            ],
          ),
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

}