import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 复刻 NumPadTextField.build，验证「按是否有内容决定放大」这一修法的效果。
Widget replica({
  required NumPadController ctl,
  required bool gateByHasText, // 修法开关
}) {
  return Builder(builder: (BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool flag = ctl.isDataByWeightMsg || ctl.styleMap['isHighlight'] == true;
    final bool enlarged =
        gateByHasText ? (flag && ctl.controller.text.isNotEmpty) : flag;

    return Container(
      height: 65,
      constraints: const BoxConstraints(maxWidth: 400),
      child: TextField(
        controller: ctl.controller,
        focusNode: ctl.focusNode,
        maxLines: 1,
        style: theme.textTheme.bodyLarge!.copyWith(
          color: enlarged ? theme.colorScheme.error : null,
          fontWeight: enlarged ? FontWeight.w600 : null,
          fontSize: enlarged ? theme.textTheme.headlineMedium!.fontSize : null,
        ),
        decoration: InputDecoration(
          hintText: '选填',
          hintStyle: theme.inputDecorationTheme.hintStyle!
              .copyWith(fontSize: theme.textTheme.bodyLarge!.fontSize),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 25),
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('(kg)', style: theme.textTheme.bodyLarge),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 39),
        ),
      ),
    );
  });
}

void main() {
  final ThemeData theme = ThemeData(
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(
      isCollapsed: false, filled: true, fillColor: Colors.transparent,
      contentPadding: EdgeInsets.zero, border: OutlineInputBorder(),
      hintStyle: TextStyle(),
    ),
  );

  Future<void> run(WidgetTester tester, String tag,
      {required bool flag, required String? text, required bool gate}) async {
    final ctl = NumPadController(key: 'w', value: text);
    if (flag) ctl.styleMap['isHighlight'] = true;
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 480, height: 300,
            child: Align(
              alignment: Alignment.topLeft,
              child: replica(ctl: ctl, gateByHasText: gate),
            ),
          ),
        ),
      ),
    ));
    final RenderBox box = find.byType(TextField).evaluate().single.renderObject! as RenderBox;
    final List<Element> hints = find.textContaining('选填').evaluate()
        .where((e) => e.widget is Text).toList();
    final StringBuffer sb = StringBuffer()..writeln('$tag :: box=${box.size.height}');
    if (hints.isNotEmpty) {
      final RenderBox b = hints.last.renderObject! as RenderBox;
      final double t = b.localToGlobal(Offset.zero).dy - box.localToGlobal(Offset.zero).dy;
      sb.writeln('    hint h=${b.size.height} delta='
          '${(t + b.size.height / 2 - box.size.height / 2).toStringAsFixed(1)}');
    }
    for (final e in find.byType(RichText).evaluate()) {
      final String txt = (e.widget as RichText).text.toPlainText();
      if (txt != '12.5') continue;
      final RenderBox b = e.renderObject! as RenderBox;
      final double t = b.localToGlobal(Offset.zero).dy - box.localToGlobal(Offset.zero).dy;
      sb.writeln('    内容"12.5" fs=${(e.widget as RichText).text.style?.fontSize} '
          'h=${b.size.height} top=${t.toStringAsFixed(1)} '
          'delta=${(t + b.size.height / 2 - box.size.height / 2).toStringAsFixed(1)}');
    }
    // ignore: avoid_print
    print(sb.toString());
  }

  testWidgets('修法验证', (WidgetTester tester) async {
    await run(tester, '现状 突出显示 空文本', flag: true, text: null, gate: false);
    await run(tester, '修法 突出显示 空文本', flag: true, text: null, gate: true);
    await run(tester, '现状 突出显示 有值', flag: true, text: '12.5', gate: false);
    await run(tester, '修法 突出显示 有值', flag: true, text: '12.5', gate: true);
    await run(tester, '修法 未突出 空文本', flag: false, text: null, gate: true);
  });
}
