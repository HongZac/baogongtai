import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:get/get.dart';
import 'package:soundpool/soundpool.dart';

class SoundService extends GetxService {

  final SoundpoolOptions soundPoolOptions = const SoundpoolOptions();
  late final Soundpool _pool;

  int _soundErrorId =0 ;
  int _soundPostId  =0 ;
  int _soundInfoId = 0 ;

  @override
  onInit() async {
    super.onInit();
    init();
  }

  void init() async {

    ///windows中还不支持
    //todo:windows下提示音解决方案
    if(kIsWeb || GetPlatform.isWindows){

      return;
    }

    _pool = Soundpool.fromOptions(options: soundPoolOptions);

    ///m4a文件必须在pubspec.yaml中先加载
    _soundInfoId = await rootBundle.load("assets/sounds/Click.m4a").then((ByteData soundData) {
      return _pool.load(soundData);
    });

    _soundErrorId = await rootBundle.load("assets/sounds/BasicError.m4a").then((ByteData soundData) {
      return _pool.load(soundData);
    });
    _soundPostId = await rootBundle.load("assets/sounds/member_join.m4a").then((ByteData soundData) {
      return _pool.load(soundData);
    });

  }

  playError() async {

    //todo: web上声音提示还没有
    if(kIsWeb){
      return;
    }

    if(_soundErrorId == 0){
      FlutterPlatformAlert.playAlertSound(iconStyle: IconStyle.error, );
    }  else {
      _pool.play(_soundErrorId);
    }
  }

  playPost() async {

    //todo: web上声音提示还没有
    if(kIsWeb){
      return;
    }

    if(_soundPostId == 0){
      FlutterPlatformAlert.playAlertSound(iconStyle: IconStyle.exclamation, );
    } else {
      _pool.play(_soundPostId);
    }
  }

  playInfo() async {

    //todo: web上声音提示还没有
    if(kIsWeb){
      return;
    }

    if(_soundInfoId == 0){
      FlutterPlatformAlert.playAlertSound(iconStyle: IconStyle.information,);
    } else {
      _pool.play(_soundInfoId);
    }
  }
}