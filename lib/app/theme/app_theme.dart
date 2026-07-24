
import 'dart:convert';

import 'package:desktop/app/theme/app_theme_mode.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/theme/material3_theme_builder/material3_theme_builder.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_config.dart';


///相关类：颜色定义   Color.dart
///
///默认的主题：ConfigInfo.dart
///
///Material 3 开如，支持从单一种子颜色生成整个配色方案的能力，可以使用任意颜色来创建新的ColorScheme类型
abstract class AppTheme {

  static ThemeMode themeMode = ThemeMode.light;
  static ThemeData lightThemeData = ThemeData();
  static ThemeData darkThemeData = ThemeData();
  static Material3ThemeBuilder lightMaterial3ThemeBuilder = Material3ThemeBuilder(brightness: Brightness.light);
  static Material3ThemeBuilder darkMaterial3ThemeBuilder = Material3ThemeBuilder(brightness: Brightness.dark);
  static ColorScheme lightColorScheme = const ColorScheme.light();
  static ColorScheme darkColorScheme = const ColorScheme.dark();

  static buildTheme(){
    String themeModeKey = ShareStorageUtil.instance?.read(SharedPreferencesKeys.THEME_MODE_KEY) ?? AppConfig.themeMode;
    themeMode = AppThemeMode().getThemeMode(themeModeKey);
    buildMaterial3Theme();
    buildColorScheme();
    buildLightTheme(FontFamilyConfig.fontFamily);
    buildDarkTheme(FontFamilyConfig.fontFamily);
  }

  static buildMaterial3Theme(){
    String material3themeBuilderStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MATERIAL3_THEME_BUILDER_KEY) ?? '';
    if (material3themeBuilderStr.isNotEmpty){
      Map<String, dynamic> map = json.decode(material3themeBuilderStr);
      if (map['colorSchemeType'] == Material3ThemeBuilder.colorSchemeType) {
        lightMaterial3ThemeBuilder = Material3ThemeBuilder().fromJson(map).copyWithBrightness(Brightness.light);
        darkMaterial3ThemeBuilder = lightMaterial3ThemeBuilder.copyWithBrightness(Brightness.dark);
      }
      else {
        ShareStorageUtil.instance?.remove(SharedPreferencesKeys.MATERIAL3_THEME_BUILDER_KEY);
        lightMaterial3ThemeBuilder = Material3ThemeBuilder().copyWithBrightness(Brightness.light);
        darkMaterial3ThemeBuilder = lightMaterial3ThemeBuilder.copyWithBrightness(Brightness.dark);
      }
    }
    else {
      lightMaterial3ThemeBuilder = Material3ThemeBuilder().copyWithBrightness(Brightness.light);
      darkMaterial3ThemeBuilder = lightMaterial3ThemeBuilder.copyWithBrightness(Brightness.dark);
    }
  }

  static buildColorScheme() {
    String lightColorThemeStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.LIGHT_COLOR_THEME_KEY) ?? '';
    if (lightColorThemeStr.isNotEmpty){
      Map<String, dynamic> map = json.decode(lightColorThemeStr);
      if (map['colorSchemeType'] == Material3ThemeBuilder.colorSchemeType){
        lightColorScheme = Material3ThemeBuilder().colorSchemeFormJson(map);
      }
      else {
        ShareStorageUtil.instance?.remove(SharedPreferencesKeys.LIGHT_COLOR_THEME_KEY);
        lightColorScheme = lightMaterial3ThemeBuilder.toScheme();
      }
    }
    else {
      lightColorScheme = lightMaterial3ThemeBuilder.toScheme();
    }

    String darkColorThemeStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DARK_COLOR_THEME_KEY) ?? '';
    if (darkColorThemeStr.isNotEmpty){
      Map<String, dynamic> map = json.decode(darkColorThemeStr);
      if (map['colorSchemeType'] == Material3ThemeBuilder.colorSchemeType){
        darkColorScheme = Material3ThemeBuilder().colorSchemeFormJson(map);
      }
      else {
        ShareStorageUtil.instance?.remove(SharedPreferencesKeys.DARK_COLOR_THEME_KEY);
        darkColorScheme = darkMaterial3ThemeBuilder.toScheme();
      }
    }
    else {
      darkColorScheme = darkMaterial3ThemeBuilder.toScheme();
    }
  }

  static buildLightTheme(String fontFamily) {
    ColorScheme colorScheme = lightColorScheme;
    lightThemeData = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      extensions: const [],
      colorScheme: colorScheme,
      /*textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
      ),*/
      scrollbarTheme: ScrollbarThemeData( ///滚动条样式
        thumbVisibility: WidgetStateProperty.all(true), ///滚动条是否可见
        trackVisibility: WidgetStateProperty.all(true), ///滚动轨道是否可见
        thumbColor: WidgetStateProperty.all(colorScheme.outline),
        trackColor: WidgetStateProperty.all(colorScheme.onInverseSurface),
        trackBorderColor: WidgetStateProperty.all(Colors.transparent),
        thickness: WidgetStateProperty.all(32),
        radius: const Radius.circular(40),
        mainAxisMargin: 4,
      ),
      dividerTheme: DividerThemeData(
        space: 1, thickness: 1,
        indent: 10, endIndent: 10,
        color: colorScheme.outlineVariant,
      ),
      appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary, //Colors.transparent,
          iconTheme: const IconThemeData(
            color: Color(0xFF545454),
            size: 20,
          ),
          titleTextStyle: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface,
            fontFamily: fontFamily,
          )
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: colorScheme.onPrimaryContainer,
        //labelTextStyle:
      ),
      disabledColor: Colors.black.withAlpha(18), //colorScheme.onInverseSurface,
      inputDecorationTheme: InputDecorationTheme(
        isCollapsed: false,
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        border: const OutlineInputBorder(),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
        ),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
        ),
        errorStyle: TextStyle(
            fontFamily: fontFamily,
            color: colorScheme.error
        ),
        helperStyle: TextStyle(
          fontFamily: fontFamily,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(0, 0)),
            padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                vertical: kIsWeb || GetPlatform.isWindows ? 14 : 8,
                horizontal: 14
            )),
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                )
            ),
          )
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(0, 0)),
            padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                vertical: kIsWeb || GetPlatform.isWindows ? 14 : 8,
                horizontal: 14
            )),
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                )
            ),
          )
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(0, 0)),
            padding: WidgetStateProperty.all(EdgeInsets.symmetric(
              vertical: kIsWeb || GetPlatform.isWindows ? 14 : 8,
              horizontal: 14
            )),
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                )
            ),
          )
      ),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(0, 0)),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                )
            ),
          )
      ),
      dialogTheme: DialogThemeData(
        elevation: 1,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4)
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      navigationRailTheme: NavigationRailThemeData(
        //theme.brightness == Brightness.light
        // ? theme.colorScheme.onPrimaryContainer
        // : theme.navigationDrawerTheme.backgroundColor
        backgroundColor: colorScheme.onPrimaryContainer,
        useIndicator: true,
        indicatorColor: colorScheme.primaryContainer,
        labelType: NavigationRailLabelType.none,
        elevation: 4,
        unselectedIconTheme: IconThemeData(
          color: colorScheme.surface,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontFamily: fontFamily,
        ),
        selectedIconTheme: IconThemeData(
            color: colorScheme.onPrimaryContainer
        ),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontFamily: fontFamily,
        ),
      ),
      menuBarTheme: MenuBarThemeData(
        style: MenuStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)
            )
          ),
          padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        )
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)
            )
          ),
          padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
        )
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          alignment: Alignment.center,
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)
            )
          ),
          padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: fontFamily,
              color: colorScheme.onSurface,
            )
          ),
        ),
      ),
    );
  }

  static buildDarkTheme(String fontFamily) {
    ColorScheme colorScheme = darkColorScheme;
    darkThemeData = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      extensions: const [],
      colorScheme: colorScheme,
      scrollbarTheme: ScrollbarThemeData( ///滚动条样式
        thumbVisibility: WidgetStateProperty.all(true), ///滚动条是否可见
        trackVisibility: WidgetStateProperty.all(true), ///滚动轨道是否可见
        thumbColor: WidgetStateProperty.all(colorScheme.outline),
        trackColor: WidgetStateProperty.all(colorScheme.onInverseSurface),
        trackBorderColor: WidgetStateProperty.all(Colors.transparent),
        thickness: WidgetStateProperty.all(32),
        radius: const Radius.circular(40),
        mainAxisMargin: 4,
      ),
      chipTheme: ChipThemeData(
        checkmarkColor: colorScheme.onSurface,
      ),
      dividerTheme: DividerThemeData(
        space: 1, thickness: 1,
        indent: 10, endIndent: 10,
        color: colorScheme.outlineVariant,
      ),
      appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary, //Colors.transparent,
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 20,
          ),
          titleTextStyle: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface,
            fontFamily: fontFamily,
          )
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: colorScheme.onPrimaryContainer,
        //labelTextStyle:
      ),
      disabledColor: Colors.white.withAlpha(18),
      inputDecorationTheme: InputDecorationTheme(
        isCollapsed: false,
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        border: const OutlineInputBorder(),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
        ),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
        ),
        errorStyle: TextStyle(
            fontFamily: fontFamily,
            color: colorScheme.error
        ),
        helperStyle: TextStyle(
          fontFamily: fontFamily,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(0, 0)),
            padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                vertical: kIsWeb || GetPlatform.isWindows ? 14 : 8,
                horizontal: 14
            )),
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                )
            ),
          )
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(0, 0)),
            padding: WidgetStateProperty.all(EdgeInsets.symmetric(
              vertical: kIsWeb || GetPlatform.isWindows ? 14 : 8,
              horizontal: 14
            )),
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                )
            ),
          )
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(0, 0)),
            padding: WidgetStateProperty.all(EdgeInsets.symmetric(
              vertical: kIsWeb || GetPlatform.isWindows ? 14 : 8,
              horizontal: 14
            )),
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                )
            ),
          )
      ),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(0, 0)),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                )
            ),
          )
      ),
      dialogTheme: DialogThemeData(
        elevation: 1,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4)
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceTint.withAlpha(51),
        useIndicator: true,
        indicatorColor: colorScheme.onPrimaryContainer.withAlpha(51),
        labelType: NavigationRailLabelType.none,
        elevation: 4,
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        selectedIconTheme: IconThemeData(
            color: colorScheme.onPrimaryContainer
        ),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
      ),
      menuBarTheme: MenuBarThemeData(
          style: MenuStyle(
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                )
            ),
            padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          )
      ),
      menuTheme: MenuThemeData(
          style: MenuStyle(
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                )
            ),
            padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
          )
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          alignment: Alignment.center,
          shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)
              )
          ),
          padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
          textStyle: WidgetStateProperty.all(
              TextStyle(
                fontFamily: fontFamily,
                color: colorScheme.onSurface,
              )
          ),
        ),
      ),
    );
  }

}