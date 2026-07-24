import 'package:desktop/app/theme/material3_theme_builder/my_contrast_curve.dart';
import 'package:desktop/app/theme/material3_theme_builder/my_tonal_palette.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:desktop/app/utils/color_utils.dart' as mine_color_utils;


//  https://m3.material.io/styles/color/the-color-system/color-roles
///C:\Users\Administrator\AppData\Local\Pub\Cache\hosted\pub.flutter-io.cn\material_color_utilities-0.13.0\lib\dynamiccolor\material_dynamic_colors.dart


///给定单一颜色 keyColor，通过该色的色调板生成 ColorScheme
///
///Don’t use the outline color for components that contain multiple elements, such as cards. Instead, use the outline variant color.
///
///Don’t use the outline color for dividers since they have different contrast requirements. Instead, use the outline variant color.
///
///Don’t use the outline variant color for clustered elements like chips, or other UI elements that are in close proximity to each other.
///Instead, use outline or another color providing 3:1 contrast with the surface color.
///
///Don’t use the outline variant color to create visual hierarchy or define the visual boundary of targets.
///Instead, use the outline color or another color providing 3:1 contrast with the surface color.
class Material3ThemeBuilder {
  Brightness brightness;

  ///用于需要突出的关键组件
  ///radio checkbox 主次按钮  进度条 选中的输入框
  Color primaryKeyColor;

  ///用于UI中不太突出的组件
  ///导航栏 label 工具栏
  Color secondaryKeyColor;

  ///用于平衡主色和次色，或提高对某个元素（如输入字段）的注意力
  ///cardBkg?
  Color tertiaryKeyColor;

  ///用于错误语义
  Color errorKeyColor;

  ///用于表面和背景(surface bkg)，以及高度强调的文本和图标
  ///
  /// background: 表格背景色
  Color neutralKeyColor;

  ///用于轮廓 输入框 OutlinedBtn边框
  Color neutralVariantKeyColor;

  Material3ThemeBuilder({
    this.brightness = Brightness.light,
    this.primaryKeyColor = const Color(0xFF053042),
    this.secondaryKeyColor = const Color(0xFF19686A),
    this.tertiaryKeyColor = const Color(0xFF55624C),
    this.errorKeyColor = const Color(0xFFBA1A1A),
    this.neutralKeyColor = const Color(0xFF939094),
    this.neutralVariantKeyColor = const Color(0xFF73796C),

    Color neutralKeyColorr = const Color(0xFF74786F),
    Color neutralVariantKeyColorr = const Color(0xFF73796C),
  });


  Material3ThemeBuilder copyWithBrightness(Brightness brightness) {
    return Material3ThemeBuilder(
      brightness: brightness,
      primaryKeyColor: primaryKeyColor,
      secondaryKeyColor: secondaryKeyColor,
      tertiaryKeyColor: tertiaryKeyColor,
      errorKeyColor: errorKeyColor,
      neutralKeyColor: neutralKeyColor,
    );
  }

  ColorScheme toScheme() {
    final bool isLight = brightness == Brightness.light;
    final Map<int, Color> primaryPalette = tonalPalette(primaryKeyColor);
    final Map<int, Color> secondaryPalette = tonalPalette(secondaryKeyColor);
    final Map<int, Color> tertiaryPalette = tonalPalette(tertiaryKeyColor);
    final Map<int, Color> errorPalette = tonalPalette(errorKeyColor);
    final Map<int, Color> neutralPalette = tonalPalette(neutralKeyColor);
    final Map<int, Color> neutralVariantPalette = tonalPalette(neutralVariantKeyColor);
    double contrastLevel = 0;  ///contrastLevel 默认 0

    return ColorScheme(
      brightness: brightness,

      primary: isLight
          ? primaryPalette[40]!
          : primaryPalette[80]!,
      onPrimary: isLight
          ? primaryPalette[100]!
          : primaryPalette[20]!,
      primaryContainer: isLight
          ? primaryPalette[90]!
          : primaryPalette[30]!,
      onPrimaryContainer: isLight
          ? primaryPalette[10]!
          : primaryPalette[90]!,
      primaryFixed: isLight
          ? primaryPalette[90]!
          : primaryPalette[90]!,
      primaryFixedDim: isLight
          ? primaryPalette[80]!
          : primaryPalette[80]!,
      onPrimaryFixed: isLight
          ? primaryPalette[10]!
          : primaryPalette[10]!,
      onPrimaryFixedVariant: isLight
          ? primaryPalette[30]!
          : primaryPalette[30]!,

      secondary: isLight
          ? secondaryPalette[40]!
          : secondaryPalette[80]!,
      onSecondary: isLight
          ? secondaryPalette[100]!
          : secondaryPalette[20]!,
      secondaryContainer: isLight
          ? secondaryPalette[90]!
          : secondaryPalette[30]!,
      onSecondaryContainer: isLight
          ? secondaryPalette[10]!
          : secondaryPalette[90]!,
      secondaryFixed: isLight
          ? secondaryPalette[90]!
          : secondaryPalette[90]!,
      secondaryFixedDim: isLight
          ? secondaryPalette[80]!
          : secondaryPalette[80]!,
      onSecondaryFixed: isLight
          ? secondaryPalette[10]!
          : secondaryPalette[10]!,
      onSecondaryFixedVariant: isLight
          ? secondaryPalette[30]!
          : secondaryPalette[30]!,

      tertiary: isLight
          ? tertiaryPalette[40]!
          : tertiaryPalette[80]!,
      onTertiary: isLight
          ? tertiaryPalette[100]!
          : tertiaryPalette[20]!,
      tertiaryContainer: isLight
          ? tertiaryPalette[90]!
          : tertiaryPalette[30]!,
      onTertiaryContainer: isLight
          ? tertiaryPalette[10]!
          : tertiaryPalette[90]!,
      tertiaryFixed: isLight
          ? tertiaryPalette[90]!
          : tertiaryPalette[90]!,
      tertiaryFixedDim: isLight
          ? tertiaryPalette[80]!
          : tertiaryPalette[80]!,
      onTertiaryFixed: isLight
          ? tertiaryPalette[10]!
          : tertiaryPalette[10]!,
      onTertiaryFixedVariant: isLight
          ? tertiaryPalette[30]!
          : tertiaryPalette[30]!,

      error: isLight
          ? errorPalette[40]!
          : errorPalette[80]!,
      onError: isLight
          ? errorPalette[100]!
          : errorPalette[20]!,
      errorContainer: isLight
          ? errorPalette[90]!
          : errorPalette[30]!,
      onErrorContainer: isLight
          ? errorPalette[10]!
          : errorPalette[90]!,

      surface: isLight
          ? neutralPalette[99]!
          : neutralPalette[10]!,
      onSurface: isLight
          ? neutralPalette[10]!
          : neutralPalette[90]!,
      surfaceDim: isLight
          ? neutralPalette[MyContrastCurve(87, 87, 80, 75).get(contrastLevel)]!
          : neutralPalette[6]!,
      surfaceBright: isLight
          ? neutralPalette[98]!
          : neutralPalette[MyContrastCurve(24, 24, 29, 34).get(contrastLevel)]!,
      surfaceContainerLowest: isLight
          ? neutralPalette[100]!
          : neutralPalette[MyContrastCurve(4, 4, 2, 0).get(contrastLevel)]!,
      surfaceContainerLow: isLight
          ? neutralPalette[MyContrastCurve(96, 96, 96, 95).get(contrastLevel)]!
          : neutralPalette[MyContrastCurve(10, 10, 11, 12).get(contrastLevel)]!,
      surfaceContainer: isLight
          ? neutralPalette[MyContrastCurve(94, 94, 92, 90).get(contrastLevel)]!
          : neutralPalette[MyContrastCurve(12, 12, 16, 20).get(contrastLevel)]!,
      surfaceContainerHigh: isLight
          ? neutralPalette[MyContrastCurve(92, 92, 88, 85).get(contrastLevel)]!
          : neutralPalette[MyContrastCurve(17, 17, 21, 25).get(contrastLevel)]!,
      surfaceContainerHighest: isLight
          ? neutralPalette[MyContrastCurve(90, 90, 84, 80).get(contrastLevel)]
          : neutralPalette[MyContrastCurve(22, 22, 26, 30).get(contrastLevel)],
      //surfaceContainerHighest: isLight
      //    ? neutralVariantPalette[90]
      //    : neutralVariantPalette[30],

      onSurfaceVariant: isLight
          ? neutralVariantPalette[30]
          : neutralVariantPalette[80],
      outline: isLight
          ? neutralVariantPalette[50]
          : neutralVariantPalette[60],
      outlineVariant: isLight
          ? neutralVariantPalette[90]!
          : neutralVariantPalette[30],
      //outlineVariant: isLight
      //    ? neutralVariantPalette[80]!
      //    : neutralVariantPalette[30],

      shadow: isLight
          ? neutralPalette[0]!
          : neutralPalette[0]!,
      scrim: isLight
          ? neutralPalette[0]!
          : neutralPalette[0]!,
      inverseSurface: isLight
          ? neutralPalette[20]!
          : neutralPalette[90]!,
      onInverseSurface: isLight
          ? neutralPalette[95]!
          : neutralPalette[20]!,

      inversePrimary: isLight
          ? primaryPalette[80]!
          : primaryPalette[40]!,
      surfaceTint: isLight
          ? primaryPalette[40]
          : primaryPalette[80],
    );
  }

  Map<int, Color> tonalPalette(Color color) {
    final hct = Hct.fromInt(mine_color_utils.ColorUtils.getColorValue(color));
    final palette = MyTonalPalette.of(hct.hue, hct.chroma).asList;
    var colors = <int, Color>{  };
    for(var i = 0; i < MyTonalPalette.commonSize; i++) {
      colors.addAll({
        MyTonalPalette.commonTones[i]: Color(palette[i])
      });
    }
    return colors;
  }


  ///当前主题色是第几次修改（如果本地存储的[colorSchemeType] 不等于该值，则需要 remove 该存储值，重新初始化主题色）
  static const int colorSchemeType = 2;

  Map<String, dynamic> colorSchemeToJson(ColorScheme colorScheme){
    return {
      ///如果本地存储的[colorSchemeType] 不等于该值，则需要 remove 该存储值，重新初始化主题色
      'colorSchemeType': colorSchemeType,

      'brightness': colorScheme.brightness.name,

      'primary': mine_color_utils.ColorUtils.getColorValue(colorScheme.primary),
      'onPrimary': mine_color_utils.ColorUtils.getColorValue(colorScheme.onPrimary),
      'primaryContainer': mine_color_utils.ColorUtils.getColorValue(colorScheme.primaryContainer),
      'onPrimaryContainer': mine_color_utils.ColorUtils.getColorValue(colorScheme.onPrimaryContainer),
      'primaryFixed': mine_color_utils.ColorUtils.getColorValue(colorScheme.primaryFixed),
      'primaryFixedDim': mine_color_utils.ColorUtils.getColorValue(colorScheme.primaryFixedDim),
      'onPrimaryFixed': mine_color_utils.ColorUtils.getColorValue(colorScheme.onPrimaryFixed),
      'onPrimaryFixedVariant': mine_color_utils.ColorUtils.getColorValue(colorScheme.onPrimaryFixedVariant),

      'secondary': mine_color_utils.ColorUtils.getColorValue(colorScheme.secondary),
      'onSecondary': mine_color_utils.ColorUtils.getColorValue(colorScheme.onSecondary),
      'secondaryContainer': mine_color_utils.ColorUtils.getColorValue(colorScheme.secondaryContainer),
      'onSecondaryContainer': mine_color_utils.ColorUtils.getColorValue(colorScheme.onSecondaryContainer),
      'secondaryFixed': mine_color_utils.ColorUtils.getColorValue(colorScheme.secondaryFixed),
      'secondaryFixedDim': mine_color_utils.ColorUtils.getColorValue(colorScheme.secondaryFixedDim),
      'onSecondaryFixed': mine_color_utils.ColorUtils.getColorValue(colorScheme.onSecondaryFixed),
      'onSecondaryFixedVariant': mine_color_utils.ColorUtils.getColorValue(colorScheme.onSecondaryFixedVariant),

      'tertiary': mine_color_utils.ColorUtils.getColorValue(colorScheme.tertiary),
      'onTertiary': mine_color_utils.ColorUtils.getColorValue(colorScheme.onTertiary),
      'tertiaryContainer': mine_color_utils.ColorUtils.getColorValue(colorScheme.tertiaryContainer),
      'onTertiaryContainer': mine_color_utils.ColorUtils.getColorValue(colorScheme.onTertiaryContainer),
      'tertiaryFixed': mine_color_utils.ColorUtils.getColorValue(colorScheme.tertiaryFixed),
      'tertiaryFixedDim': mine_color_utils.ColorUtils.getColorValue(colorScheme.tertiaryFixedDim),
      'onTertiaryFixed': mine_color_utils.ColorUtils.getColorValue(colorScheme.onTertiaryFixed),
      'onTertiaryFixedVariant': mine_color_utils.ColorUtils.getColorValue(colorScheme.onTertiaryFixedVariant),

      'error': mine_color_utils.ColorUtils.getColorValue(colorScheme.error),
      'onError': mine_color_utils.ColorUtils.getColorValue(colorScheme.onError),
      'errorContainer': mine_color_utils.ColorUtils.getColorValue(colorScheme.errorContainer),
      'onErrorContainer': mine_color_utils.ColorUtils.getColorValue(colorScheme.onErrorContainer),

      'surface': mine_color_utils.ColorUtils.getColorValue(colorScheme.surface),
      'onSurface': mine_color_utils.ColorUtils.getColorValue(colorScheme.onSurface),
      'surfaceDim': mine_color_utils.ColorUtils.getColorValue(colorScheme.surfaceDim),
      'surfaceBright': mine_color_utils.ColorUtils.getColorValue(colorScheme.surfaceBright),
      'surfaceContainerLowest': mine_color_utils.ColorUtils.getColorValue(colorScheme.surfaceContainerLowest),
      'surfaceContainerLow': mine_color_utils.ColorUtils.getColorValue(colorScheme.surfaceContainerLow),
      'surfaceContainer': mine_color_utils.ColorUtils.getColorValue(colorScheme.surfaceContainer),
      'surfaceContainerHigh': mine_color_utils.ColorUtils.getColorValue(colorScheme.surfaceContainerHigh),
      'surfaceContainerHighest': mine_color_utils.ColorUtils.getColorValue(colorScheme.surfaceContainerHighest),
      'onSurfaceVariant': mine_color_utils.ColorUtils.getColorValue(colorScheme.onSurfaceVariant),
      'outline': mine_color_utils.ColorUtils.getColorValue(colorScheme.outline),
      'outlineVariant': mine_color_utils.ColorUtils.getColorValue(colorScheme.outlineVariant),

      'shadow': mine_color_utils.ColorUtils.getColorValue(colorScheme.shadow),
      'scrim': mine_color_utils.ColorUtils.getColorValue(colorScheme.scrim),
      'inverseSurface': mine_color_utils.ColorUtils.getColorValue(colorScheme.inverseSurface),
      'onInverseSurface': mine_color_utils.ColorUtils.getColorValue(colorScheme.onInverseSurface),
      'inversePrimary': mine_color_utils.ColorUtils.getColorValue(colorScheme.inversePrimary),
      'surfaceTint': mine_color_utils.ColorUtils.getColorValue(colorScheme.surfaceTint),
    };
  }

  ColorScheme colorSchemeFormJson(Map<String, dynamic> map){
    ColorScheme colorScheme = ColorScheme(
      brightness: map['brightness'] == 'light' ? Brightness.light : Brightness.dark,

      primary: Color(map['primary']),
      onPrimary: Color(map['onPrimary']),
      primaryContainer: Color(map['primaryContainer']),
      onPrimaryContainer: Color(map['onPrimaryContainer']),
      primaryFixed: Color(map['primaryFixed']),
      primaryFixedDim: Color(map['primaryFixedDim']),
      onPrimaryFixed: Color(map['onPrimaryFixed']),
      onPrimaryFixedVariant: Color(map['onPrimaryFixedVariant']),

      secondary: Color(map['secondary']),
      onSecondary: Color(map['onSecondary']),
      secondaryContainer: Color(map['secondaryContainer']),
      onSecondaryContainer: Color(map['onSecondaryContainer']),
      secondaryFixed: Color(map['secondaryFixed']),
      secondaryFixedDim: Color(map['secondaryFixedDim']),
      onSecondaryFixed: Color(map['onSecondaryFixed']),
      onSecondaryFixedVariant: Color(map['onSecondaryFixedVariant']),

      tertiary: Color(map['tertiary']),
      onTertiary: Color(map['onTertiary']),
      tertiaryContainer: Color(map['tertiaryContainer']),
      onTertiaryContainer: Color(map['onTertiaryContainer']),
      tertiaryFixed: Color(map['tertiaryFixed']),
      tertiaryFixedDim: Color(map['tertiaryFixedDim']),
      onTertiaryFixed: Color(map['onTertiaryFixed']),
      onTertiaryFixedVariant: Color(map['onTertiaryFixedVariant']),

      error: Color(map['error']),
      onError: Color(map['onError']),
      errorContainer: Color(map['errorContainer']),
      onErrorContainer: Color(map['onErrorContainer']),

      surface: Color(map['surface']),
      onSurface: Color(map['onSurface']),
      surfaceDim: Color(map['surfaceDim']),
      surfaceBright: Color(map['surfaceBright']),
      surfaceContainerLowest: Color(map['surfaceContainerLowest']),
      surfaceContainerLow: Color(map['surfaceContainerLow']),
      surfaceContainer: Color(map['surfaceContainer']),
      surfaceContainerHigh: Color(map['surfaceContainerHigh']),
      surfaceContainerHighest: Color(map['surfaceContainerHighest']),
      onSurfaceVariant: Color(map['onSurfaceVariant']),
      outline: Color(map['outline']),
      outlineVariant: Color(map['outlineVariant']),

      shadow: Color(map['shadow']),
      scrim: Color(map['scrim']),
      inverseSurface: Color(map['inverseSurface']),
      onInverseSurface: Color(map['onInverseSurface']),
      inversePrimary: Color(map['inversePrimary']),
      surfaceTint: Color(map['surfaceTint']),
    );
    return colorScheme;
  }


  Map<String, dynamic> toJson(){
    return {
      ///如果本地存储的[colorSchemeType] 不等于该值，则需要 remove 该存储值，重新初始化主题色
      'colorSchemeType': colorSchemeType,

      'brightness': brightness.name,
      'primaryKeyColor': mine_color_utils.ColorUtils.getColorValue(primaryKeyColor),
      'secondaryKeyColor': mine_color_utils.ColorUtils.getColorValue(secondaryKeyColor),
      'tertiaryKeyColor': mine_color_utils.ColorUtils.getColorValue(tertiaryKeyColor),
      'errorKeyColor': mine_color_utils.ColorUtils.getColorValue(errorKeyColor),
      'neutralKeyColor': mine_color_utils.ColorUtils.getColorValue(neutralKeyColor),
      'neutralVariantKeyColor': mine_color_utils.ColorUtils.getColorValue(neutralVariantKeyColor),
    };
  }

  Material3ThemeBuilder fromJson(Map<String, dynamic> map){
    Material3ThemeBuilder material3themeBuilder = Material3ThemeBuilder(
      brightness: map['brightness'] == 'light' ? Brightness.light : Brightness.dark,
      primaryKeyColor: Color(map['primaryKeyColor']),
      secondaryKeyColor: Color(map['secondaryKeyColor']),
      tertiaryKeyColor: Color(map['tertiaryKeyColor']),
      errorKeyColor: Color(map['errorKeyColor']),
      neutralKeyColor: Color(map['neutralKeyColor']),
      neutralVariantKeyColor: Color(map['neutralVariantKeyColor']),
    );
    return material3themeBuilder;
  }
}
