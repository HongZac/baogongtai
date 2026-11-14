import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_text_field.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// 「选填」占位文字在输入框内的垂直位置回归测试。
///
/// 结论（真机主题：bodyLarge 16/行高24，headlineMedium 28/行高36，框高 65）：
/// - 正常状态：hint 中心 30.3，框中心 32.5 → 偏上 2.3px，视为居中，不会掉到下面。
/// - 「内容突出显示」(styleMap[isHighlight]) 或「称重消息回填」(isDataByWeightMsg)
///   两种放大字状态：内容行按 28px 排版，hint 仍按 16px 且跟随内容基线，
///   hint 中心落到 41.3 → 掉到框的中下部，约 8.8px。
void main() {
  /// 与 lib/app/theme/app_theme.dart 中 lightThemeData 的输入框相关配置一致
  final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    inputDecorationTheme: const InputDecorationTheme(
      isCollapsed: false,
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      border: OutlineInputBorder(),
      hintStyle: TextStyle(),
    ),
  );

  Future<double?> hintDelta(WidgetTester tester, double boxHeight) async {
    final RenderBox box =
        find.byType(NumPadTextField).evaluate().single.renderObject! as RenderBox;
    final List<Element> hints = find
        .textContaining('选填')
        .evaluate()
        .where((e) => e.widget is Text)
        .toList();
    if (hints.isEmpty) return null; // 文本非空，hint 不显示
    final RenderBox b = hints.last.renderObject! as RenderBox;
    final double top = b.localToGlobal(Offset.zero).dy - box.localToGlobal(Offset.zero).dy;
    expect(box.size.height, boxHeight);
    return top + b.size.height / 2 - box.size.height / 2;
  }

  Future<void> render(
    WidgetTester tester,
    NumPadController ctl,
    int tick,
  ) async {
    await tester.pumpWidget(GetMaterialApp(
      theme: theme,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 480,
            height: 300,
            child: Align(
              alignment: Alignment.topLeft,
              child: NumPadTextField(
                key: ValueKey(tick),
                numPadController: ctl,
                hintText: '选填',
                measurement: '(kg)',
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('正常状态：选填 保持居中', (WidgetTester tester) async {
    final ctl = NumPadController(key: NumPadUtil.weight, zhName: '总重');
    await render(tester, ctl, 1);
    final double? d = await hintDelta(tester, 65);
    // ignore: avoid_print
    print('正常状态 delta=${d?.toStringAsFixed(1)}');
    expect(d, closeTo(-2.3, 0.5)); // 偏上 2.3px，不掉下去
  });

  testWidgets('内容突出显示 + 空文本：选填 掉到中下部', (WidgetTester tester) async {
    final ctl = NumPadController(key: NumPadUtil.weight, zhName: '总重');
    ctl.styleMap[AppConfig.isHighlight] = true;
    await render(tester, ctl, 2);
    final double? d = await hintDelta(tester, 65);
    // ignore: avoid_print
    print('突出显示 delta=${d?.toStringAsFixed(1)}');
    expect(d, closeTo(8.8, 0.5)); // 下沉
  });

  testWidgets('称重回填后 controller.clear()：标志残留导致选填仍然下沉',
      (WidgetTester tester) async {
    final ctl = NumPadController(key: NumPadUtil.weight, zhName: '总重');
    final List<NumPadController> list = [ctl];
    NumPadUtil().setText(NumPadUtil.weight, '12.5', list, isDataByWeightMsg: true);
    // 生产：submitTypeOnChanged 里 numPadCTList.forEach((e) => e.controller.clear())
    ctl.controller.clear();
    await render(tester, ctl, 3);
    expect(ctl.isDataByWeightMsg, isTrue); // 标志位没有被重置
    final double? d = await hintDelta(tester, 65);
    // ignore: avoid_print
    print('称重回填+clear delta=${d?.toStringAsFixed(1)}');
    expect(d, closeTo(8.8, 0.5));
  });
}
