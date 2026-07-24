import 'dart:convert';

import 'package:basement/logger.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:desktop/app/routes/mine_route_observer.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/translation/language_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:windows_single_instance/windows_single_instance.dart';
import 'app/utils/app_config.dart';
import 'app/initializer.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/shared_preferences_keys.dart';
import 'app/theme/app_theme.dart';
import 'app/translation/translation_service.dart';
import 'package:logger/logger.dart';


void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && GetPlatform.isWindows){
    await WindowsSingleInstance.ensureSingleInstance(
      args,
      "workshop_desktop",
      onSecondWindow: (args) {
        PrintUtil.printDebug(args.toString());
      }
    );
  }

  ///全局错误处理，https://flutter.cn/docs/testing/errors
  FlutterError.onError = (FlutterErrorDetails details) async {
    //FlutterError.presentError(details); ///每当Flutter框架想要向用户显示错误时调用
    //FlutterError.reportError(details);
    try {
      debugPrint(jsonEncode({
        LoggerCollector.logLevel: Level.debug.name,
        LoggerCollector.logMsg: 'Flutter Error: \n${details.exceptionAsString()}',
        LoggerCollector.logError: 'Error Library: \n${details.library}',
        LoggerCollector.logStackTrace: 'Stack Trace: \n${details.stack}',
      }));
    } catch(e){}
  };

  ///启用 [debugPrint] 重定向
  LoggerCollector.redirectDebugPrint();

  await Initializer().dependencies();

  ///配置Web应用的URL策略,去掉最后的# + 锚点标识符 读写，在非Web平台下直接返加Noop();
  ///import 'package:url_strategy
  //setPathUrlStrategy();

  final MyRouteObserver _myRouteObserver = MyRouteObserver();
  Get.routerDelegate = MineGetDelegate(
    //notFoundRoute: unknownRoute,
    navigatorObservers: [_myRouteObserver],
  );

  ///todo https://github.com/flutter/flutter/issues/182444
  ///flutter 的错误，会不停的抛出错误，先完全禁用 app 的语义，等 flutter 版本升级后再改回来
  if (!kIsWeb && GetPlatform.isWindows){
    runApp(ExcludeSemantics(child: DesktopApp(),));
  }
  else {
    runApp(DesktopApp());
  }
}

class DesktopApp extends StatelessWidget {
  DesktopApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerThickness: 6,
        dividerPainter: DividerPainters.grooved1(
          color: Theme.of(context).dividerColor.withAlpha(128),
          highlightedColor: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(179),
          thickness: 3,
          highlightedThickness: null,
          size: 40,
          highlightedSize: null,
        )
      ),
      child: GetMaterialApp.router(
        title: '车间工作台',
        enableLog: true,
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.fade,
        getPages: AppPages.pages,
        routerDelegate: Get.routerDelegate as RouterDelegate<Object>?,
        theme: AppTheme.lightThemeData,
        darkTheme: AppTheme.darkThemeData,
        supportedLocales: LanguageConfig.supportedLocales,
        locale: Locale(
          ShareStorageUtil.instance?.read(SharedPreferencesKeys.LOCALE_LANGUAGE_CODE_KEY) ?? AppConfig.defaultLocal.languageCode,
          ShareStorageUtil.instance?.read(SharedPreferencesKeys.LOCALE_COUNTRY_CODE_KEY) ?? AppConfig.defaultLocal.countryCode,
        ),
        fallbackLocale: Locale(
          ShareStorageUtil.instance?.read(SharedPreferencesKeys.LOCALE_LANGUAGE_CODE_KEY) ?? AppConfig.defaultLocal.languageCode,
          ShareStorageUtil.instance?.read(SharedPreferencesKeys.LOCALE_COUNTRY_CODE_KEY) ?? AppConfig.defaultLocal.countryCode,
        ),
        ///国际化，多语言 https://docs.flutter.dev/development/accessibility-and-localization/internationalization
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate,   ///只支持了英文
          DefaultWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        translations: TranslationService(),
        builder: (context, child) {
          ///每次APP刷新都会运行此，有关APP层级的初始化都放到AppService中init中去
          return MediaQuery(
            ///设置文字大小不随系统设置改变
            data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(FontFamilyConfig.textScale)
            ),
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                    builder: (BuildContext context){
                      return child ?? const SizedBox.shrink();
                    }
                )
              ],
            ),
          );
        },
      ),
    );
  }
}