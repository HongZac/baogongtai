
import 'dart:convert';
import 'dart:io';

import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/service/tts_service.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/theme/app_theme.dart';
import 'package:desktop/app/theme/app_theme_mode.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/theme/material3_theme_builder/material3_theme_builder.dart';
import 'package:desktop/app/translation/language_config.dart';
import 'package:desktop/app/ui/pages/home/home_controller.dart';
import 'package:desktop/app/ui/pages/root/root_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';


///全局设置
class OverallSettingController extends GetxController with GetSingleTickerProviderStateMixin {

  final rootCtl = Get.find<RootController>();
  final HomeController homeController = Get.find<HomeController>();

  bool isLoading = false;

  late final TabController tabController = TabController(
    length: tabValueList.length,
    initialIndex: 0,
    vsync: this,
  );

  final ScrollController leftScrollController = ScrollController();

  final List<ChoiceChipModel> tabValueList = [
    ChoiceChipModel(icon: Icons.filter_alt_sharp, title: '默认选项卡', keyName: 'tab', isSelected: true),
    ChoiceChipModel(icon: Icons.print_rounded, title: '打印设置', keyName: 'print', isSelected: false),
    ChoiceChipModel(icon: Icons.compare_arrows, title: 'TCP 连接设置', keyName: 'weightMsg', isSelected: false),
    ChoiceChipModel(icon: FluentIcons.speaker_settings_24_filled, title: '语音播报参数设置', keyName: 'tts', isSelected: false),
    ChoiceChipModel(icon: Icons.color_lens, title: '主题设置', keyName: 'theme', isSelected: false),
    ChoiceChipModel(icon: Icons.language, title: '语言设置', keyName: 'language', isSelected: false),
    ChoiceChipModel(icon: FluentIcons.text_font_16_filled, title: '字体设置', keyName: 'font', isSelected: false),
    ChoiceChipModel(icon: Icons.keyboard, title: '输入设置', keyName: 'input', isSelected: false),
    ChoiceChipModel(icon: Icons.view_quilt, title: '显示设置', keyName: 'interface', isSelected: false),
  ];

  //region 默认选项卡设置参数
  ///NavigationRail默认选中的Item的Key
  late String destinationKeyName = ShareStorageUtil.personal?.read(SharedPreferencesKeys.DEFAULT_DESTINATION_KEY) ?? AppConfig.destinationKeyName;
  final List<ChoiceChipModel> destinationList = [];
  //endregion

  //region 打印设置参数
  final List<Printer> printerList = [];
  String printerName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PRINTER_NAME_KEY) ?? '';
  String printerUrl = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PRINTER_URL_KEY) ?? '';
  double defaultPrintCopies = (ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEFAULT_PRINT_COPIES) ?? AppConfig.defaultPrintCopies).toDouble();
  String printType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PRINT_TYPE_KEY) ?? AppConfig.printType;
  ///打印时是否显示参数设置
  bool isShowPrintSetting = ShareStorageUtil.instance?.read(SharedPreferencesKeys.IS_SHOW_PRINT_SETTING_KEY) ?? AppConfig.isShowPrintSetting;
  //endregion

  //region 称重消息参数
  final WeightMsgConnectService weightMsgConnectService = Get.find<WeightMsgConnectService>();
  //endregion

  //region 语音播报参数设置
  final ttsService = Get.find<TtsService>();
  final List<Object?> enginesList = [];
  ///语音播报音量
  double flutterTtsVolume = ShareStorageUtil.instance?.read(SharedPreferencesKeys.FLUTTERTTS_VOLUME) ?? AppConfig.flutterTtsVolume;
  ///语音播报语速
  double flutterTtsSpeechRate = ShareStorageUtil.instance?.read(SharedPreferencesKeys.FLUTTERTTS_SPEECHRATE) ?? AppConfig.flutterTtsSpeechRate;
  ///语音播报音调
  double flutterTtsPitch = ShareStorageUtil.instance?.read(SharedPreferencesKeys.FLUTTERTTS_PITCH) ?? AppConfig.flutterTtsPitch;
  ///语音包引擎选择
  String flutterTtsEngines = ShareStorageUtil.instance?.read(SharedPreferencesKeys.FLUTTERTTS_ENGINES) ?? '';
  //endregion

  //region 主题设置
  ///主题 system light dark
  String themeModeKey = ShareStorageUtil.instance?.read(SharedPreferencesKeys.THEME_MODE_KEY) ?? AppConfig.themeMode;
  String themeModeName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.THEME_MODE_NAME_KEY) ?? AppConfig.themeModeName;
  late ThemeMode themeMode = AppThemeMode().getThemeMode(themeModeKey);
  final String material3themeBuilderStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MATERIAL3_THEME_BUILDER_KEY) ?? '';
  late Material3ThemeBuilder material3ThemeBuilder = Material3ThemeBuilder();
  //endregion

  //region 语言设置参数
  late Locale selectedLocale = Locale(
    ShareStorageUtil.instance?.read(SharedPreferencesKeys.LOCALE_LANGUAGE_CODE_KEY) ?? AppConfig.defaultLocal.languageCode,
    ShareStorageUtil.instance?.read(SharedPreferencesKeys.LOCALE_COUNTRY_CODE_KEY) ?? AppConfig.defaultLocal.countryCode,
  );
  //endregion

  //region 字体设置参数
  ///字体大小比例
  final double textScale = ShareStorageUtil.instance?.read(SharedPreferencesKeys.TEXT_SCALE_KEY) ?? AppConfig.textScale;
  late final TextEditingController textScaleTC = TextEditingController(text: textScale.toString());
  final FocusNode textScaleFN = FocusNode();
  ///字体主题
  String fontFamily = ShareStorageUtil.instance?.read(SharedPreferencesKeys.FONT_FAMILY_KEY) ?? AppConfig.fontFamily;
  //endregion

  //region 输入设置
  ///windows平台下，点击输入框时，是否弹出软键盘
  bool isKeyboardOpenAfterClickTC = ShareStorageUtil.instance?.read(SharedPreferencesKeys.IS_KEYBOARD_OPEN_AFTER_CLICK_TC_KEY) ?? AppConfig.isKeyboardOpenAfterClickTC;
  //endregion

  //region 显示设置
  String tipsShowTypeStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.TIPS_SHOW_TYPE_KEY) ?? AppConfig.tipsShowTypeStr;
  //endregion


  @override
  void onInit() {
    super.onInit();
  }

  void _tabOnChanged(ChoiceChipModel item, int index){
    for (var element in tabValueList) {
      element.isSelected = false;
    }
    item.isSelected = true;
    tabController.animateTo(index);
    update();
  }
  Function(ChoiceChipModel item, int index) get tabOnChanged => _tabOnChanged;


  @override
  void onClose() {
    leftScrollController.dispose();
    tabController.dispose();
    super.onClose();
  }


  Future<bool> initializeForm() async {
    if (!kIsWeb && GetPlatform.isWindows){
      List<Printer> printerList = await Printing.listPrinters();
      this.printerList.clear();
      this.printerList.addAll(printerList);
    }
    destinationList.addAll(
        homeController.destinations.map((e) {
          e.isSelected = e.keyName == destinationKeyName;
          return e;
        }).toList()
    );

    var _languages = await ttsService.flutterTts.getLanguages;
    if (_languages == null){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ToastNotification(Get.overlayContext!).info("未安装语音包！");
      });
    }
    if (Platform.isAndroid){
      var _list = await ttsService.flutterTts.getEngines ?? [];
      enginesList.addAll(_list);
      ///这两种不支持中文语音，且切换引擎时可能会出错
      enginesList.removeWhere((element) => element == 'com.svox.pico');
      enginesList.removeWhere((element) => element == 'com.svox.classic');
      update();
    }

    if (material3themeBuilderStr.isNotEmpty){
      Map<String, dynamic> map = json.decode(material3themeBuilderStr);
      material3ThemeBuilder = Material3ThemeBuilder().fromJson(map).copyWithBrightness(Brightness.light);
    }
    else {
      material3ThemeBuilder = Material3ThemeBuilder().copyWithBrightness(Brightness.light);
    }
    return true;
  }

  @override
  Future<void> onReady() async {
    super.onReady();
      ProgressDialogUtil.showProgressDialog();

    ///窗体数据创建过程
    var res2 = await initializeForm();

    update();
    if (!res2){
      ProgressDialogUtil.close();
    }
    ProgressDialogUtil.update(value: 1);
  }


  //region onChanged

  ///默认选项卡选择变化
  void initialKeyNameOnChanged(String? str) {
    if (str == null || str.isEmpty){
      return;
    }
    destinationKeyName = str;
    update();
  }

  ///打印机选择变化
  void printerOnChanged(Printer printer) {
    printerUrl = printer.url;
    printerName = printer.name;
    update();
  }

  ///默认打印份数
  void onChangedDefaultPrintCopies(double value){
    defaultPrintCopies = value;
  }

  ///打印方式选择变化
  void printTypeOnChanged(String str){
    printType = str;
    update();
  }

  ///打印时是否显示参数设置选择变化
  void isShowPrintSettingOnChanged(bool value){
    isShowPrintSetting = !isShowPrintSetting;
    update();
  }

  ///语音引擎选择变化
  void flutterTtsEnginesOnChanged(Object key){
    flutterTtsEngines = key.toString();
    update();
  }

  ///音量
  void onChangedVolume(double value){
    flutterTtsVolume = value;
  }

  ///语速
  void onChangedSpeechRate(double value){
    flutterTtsSpeechRate = value;
  }

  ///音调
  void onChangedPitch(double value){
    flutterTtsPitch = value;
  }

  ///主题选择变化
  void themeOnChanged(ChoiceChipModel item) {
    themeModeKey = item.keyName;
    themeModeName = item.title;
    themeMode = AppThemeMode().getThemeMode(themeModeKey);
    update();
  }

  ///颜色选择变化
  void colorOnChanged(String key, Color pickerColor){
    switch (key){
      case 'primary':
        material3ThemeBuilder.primaryKeyColor = pickerColor;
        break;
      case 'secondary':
        material3ThemeBuilder.secondaryKeyColor = pickerColor;
        break;
      case 'tertiary':
        material3ThemeBuilder.tertiaryKeyColor = pickerColor;
        break;
      case 'neutral':
        material3ThemeBuilder.neutralKeyColor = pickerColor;
        break;
    }
    update();
  }

  ///语言选择变化
  void languageOnChanged(dynamic item){
    selectedLocale = Locale(item['code'], item['country_code']);
    update();
  }

  ///字体选择变化
  void fontFamilyOnChanged(dynamic item){
    fontFamily = item['enName'];
    update();
  }

  ///是否弹出软键盘 选择变化
  void isKeyboardOpenAfterClickTCOnChanged() {
    isKeyboardOpenAfterClickTC = !isKeyboardOpenAfterClickTC;
    update();
  }

  void tipsShowTypeStrOnChanged(String str) {
    tipsShowTypeStr = str;
    update();
  }

  //endregion


  //region onSave

  ///默认选项卡参数保存
  Future<void> tabSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 1, msg: '正在保存', completedMsg: '数据保存成功！');

    //region 数据保存
    ShareStorageUtil.personal?.write(SharedPreferencesKeys.DEFAULT_DESTINATION_KEY, destinationKeyName);
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 1);
  }

  ///打印参数保存
  Future<void> printSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 1, msg: '正在保存', completedMsg: '数据保存成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PRINTER_NAME_KEY, printerName);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PRINTER_URL_KEY, printerUrl);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEFAULT_PRINT_COPIES, defaultPrintCopies.toInt());
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PRINT_TYPE_KEY, printType);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.IS_SHOW_PRINT_SETTING_KEY, isShowPrintSetting);
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 1);
  }

  ///语音播报参数保存
  Future<void> ttsSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 1, msg: '正在保存', completedMsg: '数据保存成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.FLUTTERTTS_VOLUME, flutterTtsVolume);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.FLUTTERTTS_SPEECHRATE, flutterTtsSpeechRate);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.FLUTTERTTS_PITCH, flutterTtsPitch);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.FLUTTERTTS_ENGINES, flutterTtsEngines);
    await ttsService.setData();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 1);
  }

  ///主题参数保存
  Future<void> themeSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.THEME_MODE_KEY, themeModeKey);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.THEME_MODE_NAME_KEY, themeModeName);

    String material3ThemeBuilderJsonString = json.encode(material3ThemeBuilder.toJson());
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MATERIAL3_THEME_BUILDER_KEY, material3ThemeBuilderJsonString);
    ColorScheme lightColorScheme = material3ThemeBuilder.copyWithBrightness(Brightness.light).toScheme();
    ColorScheme darkColorScheme = material3ThemeBuilder.copyWithBrightness(Brightness.dark).toScheme();
    String lightColorSchemeJsonString = json.encode(Material3ThemeBuilder().colorSchemeToJson(lightColorScheme));
    String darkColorSchemeJsonString = json.encode(Material3ThemeBuilder().colorSchemeToJson(darkColorScheme));
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.LIGHT_COLOR_THEME_KEY, lightColorSchemeJsonString);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DARK_COLOR_THEME_KEY, darkColorSchemeJsonString);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '保存成功，正在刷新！');

    //region 刷新主题
    bool isThemeModeChanged = false;
    bool isThemeColorChanged = false;
    if (AppTheme.themeMode != themeMode){
      isThemeModeChanged = true;
    }
    var oldString = json.encode(AppTheme.lightMaterial3ThemeBuilder.toJson());
    var newString = json.encode(material3ThemeBuilder.copyWithBrightness(Brightness.light).toJson());
    if (oldString != newString){
      isThemeColorChanged = true;
    }
    AppTheme.themeMode = themeMode;
    AppTheme.lightMaterial3ThemeBuilder = material3ThemeBuilder.copyWithBrightness(Brightness.light);
    AppTheme.darkMaterial3ThemeBuilder = material3ThemeBuilder.copyWithBrightness(Brightness.dark);
    AppTheme.lightColorScheme = lightColorScheme;
    AppTheme.darkColorScheme = darkColorScheme;
    AppTheme.buildLightTheme(FontFamilyConfig.fontFamily);
    AppTheme.buildDarkTheme(FontFamilyConfig.fontFamily);
    if (isThemeModeChanged || isThemeColorChanged){
      AppThemeMode().changedThemeByThemeMode(AppTheme.themeMode);
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///语言设置
  Future<void> languageSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.LOCALE_LANGUAGE_CODE_KEY, selectedLocale.languageCode);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.LOCALE_COUNTRY_CODE_KEY, selectedLocale.countryCode);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '保存成功，正在刷新！');

    //region 刷新
    LanguageConfig.getLanguage(selectedLocale);
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///字体设置保存
  Future<void> fontSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;

    //region 判断填写的数值是否正确
    double? textScale = double.tryParse(textScaleTC.text);
    if (textScale == null || textScale <= 0){
      ToastNotification(Get.overlayContext!).warn('“文本比例”填写有误！');
      isLoading = false;
      return;
    }
    if (textScale > 1.5){
      ToastNotification(Get.overlayContext!).warn('“文本比例”建议不能超过1.5！');
      isLoading = false;
      return;
    }
    //endregion

    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.TEXT_SCALE_KEY, textScale);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.FONT_FAMILY_KEY, fontFamily);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '保存成功，正在刷新！');

    //region 刷新
    if (FontFamilyConfig.textScale != textScale){
      FontFamilyConfig.textScale = textScale;
      Get.forceAppUpdate();
    }
    if (FontFamilyConfig.fontFamily != fontFamily){
      FontFamilyConfig.fontFamily = fontFamily;
      AppTheme.buildLightTheme(FontFamilyConfig.fontFamily);
      AppTheme.buildDarkTheme(FontFamilyConfig.fontFamily);
      AppThemeMode().changedThemeByThemeMode(AppTheme.themeMode);
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///输入设置
  Future<void> inputSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.IS_KEYBOARD_OPEN_AFTER_CLICK_TC_KEY, isKeyboardOpenAfterClickTC);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '保存成功，正在刷新！');

    //region 刷新
    var rootCtl = Get.find<RootController>();
    rootCtl.isKeyboardOpenAfterClickTC = isKeyboardOpenAfterClickTC;
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///显示设置
  Future<void> interfaceSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.TIPS_SHOW_TYPE_KEY, tipsShowTypeStr);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '保存成功，正在刷新！');

    //region 刷新
    TipsUtils.tipsShowTypeStr = tipsShowTypeStr;
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }


  //endregion


}