import 'package:basement/utils.dart';
import 'dart:async';

import 'package:desktop/app/theme/app_theme.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';


const Duration _hundredMs = Duration(milliseconds: 150);
enum SuffixType { enter, tab }


class ScanGunListenerWidget extends StatefulWidget {

  final Widget? child;
  final Duration bufferDuration;
  final Future<void> Function(String searchString)? onBarcodeFun;
  final double? height;
  final double? maxWidth;
  final ThemeData? textFieldThemeData;
  final ButtonStyle? buttonStyle;
  final TextStyle? textStyle;

  ///是否可见状态下才触发接收事件
  final bool onVisible;
  ///区分多个组件时的名称，多个接收器时，用于区分
  final String tag;
  ///windows似乎正在使用[KeyDownEvent]而不是[KeyUpEvent]，可以通过设置[useKeyDownEvent]来管理此行为。
  ///在Windows上遇到空条形码问题时，请将此值设置为true。默认值为“false”。
  final bool useKeyDownEvent;
  ///检测后缀类型
  final SuffixType suffixType;


  ScanGunListenerWidget({
    this.child,
    this.bufferDuration = _hundredMs,
    this.tag = '',
    this.onBarcodeFun,
    this.height,
    this.maxWidth = 300,
    this.textFieldThemeData,
    this.buttonStyle,
    this.textStyle,
    this.onVisible = true,
    this.useKeyDownEvent = true,
    this.suffixType = SuffixType.enter,
  });

  @override
  ScanGunListenerState createState() => ScanGunListenerState();
}

class ScanGunListenerState extends State<ScanGunListenerWidget>{

  ///状态变量，是否在可见状态
  bool visible = false;
  late final Key visibilityDetectorKey = Key('code-scan-visible-detector-key${widget.tag}');

  final FocusNode scanFN = FocusNode();
  final TextEditingController scanTC = TextEditingController();
  bool isBarcodeWidgetOpen = false;

  final List<String> _scannedChars = [];
  final _controller = StreamController<String?>(sync: true);
  late StreamSubscription<String?> _keyboardSubscription;
  DateTime? _lastScannedCharCodeTime;
  bool _isProcessing = false;

  late final LogicalKeyboardKey _suffixKey;
  late final String _suffix;


  @override
  void initState() {
    super.initState();
    //region [_suffixKey]、[_suffix]
    switch (widget.suffixType){
      case SuffixType.enter:
        _suffixKey = LogicalKeyboardKey.enter;
        _suffix = '\n';
        break;
      case SuffixType.tab:
        _suffixKey = LogicalKeyboardKey.tab;
        _suffix = '\t';
        break;
    }
    //endregion
    HardwareKeyboard.instance.addHandler(_keyBoardCallback);
    _keyboardSubscription = _controller.stream.listen(onKeyEvent);
  }

  bool _keyBoardCallback(KeyEvent keyEvent) {
    try {
      LogicalKeyboardKey key = keyEvent.logicalKey;
      if (scanFN.hasFocus){
        return false;
      }
      if (widget.onVisible && !visible){
        return false;
      }
      if (key.keyId > 255 && key != _suffixKey){
        return false;
      }
      else if (keyEvent is KeyUpEvent
          && !widget.useKeyDownEvent && key == _suffixKey){
        _controller.add(_suffix);
        return true;
      }
      else if (keyEvent is KeyUpEvent
          && !widget.useKeyDownEvent){
        _controller.add(keyEvent.character ?? key.keyLabel);
        return true;
      }
      else if (keyEvent is KeyDownEvent
          && widget.useKeyDownEvent && key == _suffixKey){
        _controller.add(_suffix);
        return true;
      }
      else if (keyEvent is KeyDownEvent
          && widget.useKeyDownEvent){
        _controller.add(keyEvent.character ?? key.keyLabel);
        return true;
      }
    } catch(e){
      PrintUtil.printDebug('扫码监听错误：${e.toString()}');
    }
    return false;
  }

  Future<void> onKeyEvent(String? char) async {
    if (char == null) { return; }
    if (scanFN.hasFocus){
      resetScannedCharCodes();
      return;
    }
    ///删除所有早于bufferDuration值的挂起字符
    if (_lastScannedCharCodeTime != null
        && _lastScannedCharCodeTime!.isBefore(
            DateTime.now().subtract((widget.bufferDuration))
        )){
      resetScannedCharCodes();
    }
    _lastScannedCharCodeTime = DateTime.now();
    if (char == _suffix){
      ///是否只能在可见状态下才能触发
      if (widget.onVisible && !visible) {
        resetScannedCharCodes();
        return;
      }
      final String str = _scannedChars.join();
      resetScannedCharCodes();
      if (str.isEmpty){
        return;
      }
      if (_isProcessing) {
        return;
      }
      _isProcessing = true;
      try {
        await widget.onBarcodeFun?.call(str);
      } finally {
        _isProcessing = false;
      }
    }
    else {
      if (_isProcessing) {
        return;
      }
      ///将该字符添加到扫描字符列表中
      _scannedChars.add(char);
      //PrintUtil.printDebug(char);
    }
  }

  void resetScannedCharCodes() {
    _lastScannedCharCodeTime = null;
    _scannedChars.clear();
  }


  void barcodeWidgetOpeOnChanged(bool boolValue) {
    isBarcodeWidgetOpen = boolValue;
    if (isBarcodeWidgetOpen){
      FocusScope.of(Get.context!).requestFocus(scanFN);
    }
    else {
      scanFN.unfocus();
      scanTC.clear();
    }
    setState(() {  });
  }


  @override
  Widget build(BuildContext context) {
    Widget child = widget.child ?? Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Theme(
          data: widget.textFieldThemeData ?? AppTheme.darkThemeData,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: widget.height ?? 45,
            width: isBarcodeWidgetOpen ? widget.maxWidth : 50,
            child: TextField(
              controller: scanTC,
              focusNode: scanFN,
              maxLines: 1,
              showCursor: true,
              cursorColor: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color,
              keyboardType: TextInputType.none,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color,
              ),
              onChanged: (String? string) {  },
              decoration: InputDecoration(
                hintText: '请扫描条码……',
                hintStyle: Theme.of(context).inputDecorationTheme.hintStyle?.copyWith(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  color: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                prefixIcon: MineIconButton(
                  icon: Icons.qr_code_scanner,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  iconColor: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color,
                  tooltip: isBarcodeWidgetOpen ? '收起' : '展开',
                  onPressed: () async {
                    barcodeWidgetOpeOnChanged(!isBarcodeWidgetOpen);
                  },
                ),
                suffixIcon: scanTC.text.isNotEmpty ?
                MineIconButton(
                  icon: Icons.cancel,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  iconColor: Theme.of(context).navigationRailTheme.unselectedLabelTextStyle!.color,
                  tooltip: '清空',
                  onPressed: () async{
                    scanTC.clear();
                    setState(() { });
                  },
                ) :
                null,
                enabledBorder: isBarcodeWidgetOpen
                    ? null
                    : const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
              ),
              onTap: () {
                if (!isBarcodeWidgetOpen){
                  isBarcodeWidgetOpen = true;
                  setState(() { });
                }
              },
              onSubmitted: (String value) async {
                final String str = value;
                scanTC.clear();
                if (mounted){
                  setState(() { });
                }
                Future.delayed(const Duration(milliseconds: 100), (){
                  if (mounted){
                    FocusScope.of(context).requestFocus(scanFN);
                  }
                });
                if (str.isEmpty){
                  return;
                }
                await widget.onBarcodeFun?.call(str);
              },
            ),
          ),
        ),
        if (isBarcodeWidgetOpen)
          const SizedBox(width: 4,),
        if (isBarcodeWidgetOpen)
          FilledButton(
            style: widget.buttonStyle ?? ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.primaryContainer
              ),
              padding: WidgetStateProperty.all(
                  kIsWeb || GetPlatform.isWindows
                    ? const EdgeInsets.symmetric(vertical: 20, horizontal: 22)
                    : const EdgeInsets.symmetric(vertical: 12, horizontal: 22)
              ),
            ),
            child: Text(
              '关闭',
              style: widget.textStyle ?? TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
              ),
            ),
            onPressed: () {
              barcodeWidgetOpeOnChanged(false);
            },
          ),
      ],
    );
    return VisibilityDetector(
      onVisibilityChanged: (VisibilityInfo info) {
        visible = info.visibleFraction > 0;
      },
      key: visibilityDetectorKey,
      child: child
    );
  }


  @override
  void dispose() {
    _keyboardSubscription.cancel();
    _controller.close();
    HardwareKeyboard.instance.removeHandler(_keyBoardCallback);
    scanTC.dispose();
    scanFN.dispose();
    super.dispose();
  }

}
