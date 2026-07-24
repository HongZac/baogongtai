import 'dart:io';

import 'package:basement/utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utils/app_config.dart';


///tts文字转语音服务
class TtsService extends GetxService{

  ///是否打开语音播报
  bool isOpenFlutterTts = false;

  FlutterTts flutterTts = FlutterTts();

  String flutterTtsEngines = '';

  bool isSetting = false;

  /*/// 设置语言
  await flutterTts.setLanguage("zh-CN");
  /// 设置音量
  await flutterTts.setVolume(1);
  /// 设置语速
  await flutterTts.setSpeechRate(0.5);
  /// 音调
  await flutterTts.setPitch(1.0);
  String speechText = '语音播报';
  await flutterTts.speak(speechText);
  await flutterTts.setSilence(2); //静音几秒（Android）
  await flutterTts.getEngines; //获取引擎(Android)
  await flutterTts.awaitSpeakCompletion(true); //等发言完成后再执行下一条语句
  await flutterTts.setQueueMode(1); //(Android)
  await flutterTts.getMaxSpeechInputLength; //(Android)
  await flutterTts.setVoice({"name": "Karen", "locale": "zh-CN"}); //(Android,iOS,macOS)
  await flutterTts.pause(); //暂停（IOS, WEB）
  await flutterTts.stop(); //结束*/


  @override
  Future<void> onReady() async {
    super.onReady();

    var languages = await flutterTts.getLanguages;
    if (languages == null){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ToastNotification(Get.overlayContext!).info("未安装语音包！");
      });
      return;
    }

    //region 判断是否有打开语音播报
    ///设备概览超产：是否语音播报
    bool isOpenOverProductFlutterTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_IS_OPEN_OVER_PRODUCT_FLUTTER_TTS) ?? AppConfig.isOpenFlutterTts;
    ///异常报告 是否语音播报
    bool isOpenExceptionReportTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_IS_OPEN_EXCEPTION_REPORT_FLUTTER_TTS) ?? AppConfig.isOpenFlutterTts;
    ///全场呼叫 是否打开语音播报
    bool isOpenAndonTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_IS_OPEN_ANDON_FLUTTER_TTS) ?? AppConfig.isOpenFlutterTts;

    if (isOpenOverProductFlutterTts || isOpenExceptionReportTts || isOpenAndonTts){
      isOpenFlutterTts = true;
    }
    //endregion

    //region 语音播报参数
    await flutterTts.setLanguage("zh-CN");
    await flutterTts.awaitSpeakCompletion(true);
    if (isOpenFlutterTts){
      await flutterTts.setVolume(ShareStorageUtil.instance?.read(SharedPreferencesKeys.FLUTTERTTS_VOLUME) ?? AppConfig.flutterTtsVolume);
      await flutterTts.setSpeechRate(ShareStorageUtil.instance?.read(SharedPreferencesKeys.FLUTTERTTS_SPEECHRATE) ?? AppConfig.flutterTtsSpeechRate);
      await flutterTts.setPitch(ShareStorageUtil.instance?.read(SharedPreferencesKeys.FLUTTERTTS_PITCH) ?? AppConfig.flutterTtsPitch);
      if (Platform.isAndroid){
        flutterTtsEngines = ShareStorageUtil.instance?.read(SharedPreferencesKeys.FLUTTERTTS_ENGINES) ?? (await flutterTts.getDefaultEngine ?? '');
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.FLUTTERTTS_ENGINES, flutterTtsEngines);
        if (isOpenFlutterTts && flutterTtsEngines.isEmpty){
          PrintUtil.printDebug('未安装或未选择语音包引擎');
        }
        else if (flutterTtsEngines.isNotEmpty){
          await flutterTts.setEngine(flutterTtsEngines);
          await Future.delayed(const Duration(seconds: 10));
        }
      }
    }
    //endregion
  }

  ///设置参数
  Future<void> setData() async{
    isSetting = true;
    await flutterTts.stop();
    await flutterTts.setVolume(ShareStorageUtil.instance?.read(SharedPreferencesKeys.FLUTTERTTS_VOLUME) ?? AppConfig.flutterTtsVolume);
    await flutterTts.setSpeechRate(ShareStorageUtil.instance?.read(SharedPreferencesKeys.FLUTTERTTS_SPEECHRATE) ?? AppConfig.flutterTtsSpeechRate);
    await flutterTts.setPitch(ShareStorageUtil.instance?.read(SharedPreferencesKeys.FLUTTERTTS_PITCH) ?? AppConfig.flutterTtsPitch);
    if (Platform.isAndroid){
      var engine = ShareStorageUtil.instance?.read(SharedPreferencesKeys.FLUTTERTTS_ENGINES) ?? '';
      if (engine.isNotEmpty && engine != flutterTtsEngines){
        flutterTtsEngines = engine;
        await flutterTts.setEngine(engine);
        ToastNotification(Get.overlayContext!).info("正在修改语音引擎,请稍等！");
        ///设置引擎后，需要一些时间来完全初始化Tts https://github.com/dlutton/flutter_tts/issues/261#issuecomment-904129032
        await Future.delayed(const Duration(seconds: 10));
      }
    }
    ToastNotification(Get.overlayContext!).success("参数修改成功,开始播放语音测试！");
    isSetting = false;
  }

  ///文字转语音（语音播报）
  Future<void> flutterTtsSpeak(String text, {int repetitions = 1}) async{
    if (isSetting){
      return;
    }
    await flutterTts.stop();
    PrintUtil.printDebug(text);
    text = text * repetitions;
    await flutterTts.speak(text);
  }

  ///把阿拉伯数字改为中文数字（设备编号）
  String changeArabicToChineseForNumerals(String string) {
    String returnStr = '';
    List<String> list = string.split('');
    for (var element in list) {
      int? intNum = int.tryParse(element);
      if (intNum != null){
        returnStr += getChineseNumerals(intNum);
      }
      else {
        returnStr += element;
      }
    }

    return returnStr;
  }

  String getChineseNumerals(int num) {
    switch (num){
      case 0:
        return '零';
      case 1:
        return '一'; ///'壹';
      case 2:
        return '二'; ///'贰';
      case 3:
        return '三'; ///'叁';
      case 4:
        return '四'; ///'肆';
      case 5:
        return '五'; ///'伍';
      case 6:
        return '六'; ///'陆';
      case 7:
        return '七'; ///'柒';
      case 8:
        return '八'; ///'捌';
      case 9:
        return '九'; ///'玖';
      default:
        return '';
    }
  }

  @override
  void onClose() async {
    await flutterTts.stop();
    super.onClose();
  }

}