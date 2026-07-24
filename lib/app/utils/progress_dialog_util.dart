import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class ProgressDialogUtil {

  static ProgressOverlay _progressDialog = ProgressOverlay(context: Get.context!);

  static const int defaultCompletionDelay = 1000;

  ///progressDialog.update(); 后，会显示成功弹框[completionDelay]毫秒，弹窗关闭后再执行下一步
  static Future<void> awaitCompletionDelay({int completionDelay = defaultCompletionDelay}) async {
    await Future.delayed(Duration(
        milliseconds: completionDelay + 100
    ));
  }

  static void showProgressDialog({int max = 1, int closeDelay = 30000,
    String msg = '正在加载数据', String completedMsg = '加载数据成功！',
    BuildContext? context, int completionDelay = defaultCompletionDelay}){
    context ??= Get.context!;
    _progressDialog = ProgressOverlay(context: context);
    _progressDialog.show(
      max: max, msg: msg,
      hideValue: true,
      progressType: ProgressType.indeterminate,
      barrierDismissible: kDebugMode,
      elevation: 10,
      backgroundColor: Theme.of(context).canvasColor,
      progressBgColor: Colors.transparent,
      progressValueColor: Theme.of(context).colorScheme.primary,
      valueColor: Theme.of(context).textTheme.titleMedium!.color!,
      valueFontSize: 16,
      msgColor: Theme.of(context).textTheme.titleMedium!.color!,
      msgFontSize: 16,
      completed: Completed(
        completionDelay: completionDelay,
        completedMsg: completedMsg,
        completedImage: const AssetImage('assets/images/completed.png'),
      ),
    );
    close(delay: closeDelay); ///30秒后自动关闭
  }

  static void showValuableProgressDialog({int max = 1, int closeDelay = 60000,
    String msg = '正在加载数据', String completedMsg = '加载数据成功！',
    BuildContext? context, int completionDelay = defaultCompletionDelay}){
    context ??= Get.context!;
    _progressDialog = ProgressOverlay(context: context);
    _progressDialog.show(
      max: max, msg: msg,
      hideValue: true,
      progressType: ProgressType.indeterminate,
      barrierDismissible: kDebugMode,
      elevation: 10,
      backgroundColor: Theme.of(context).canvasColor,
      progressBgColor: Colors.transparent,
      progressValueColor: Theme.of(context).colorScheme.primary,
      valueColor: Theme.of(context).textTheme.titleMedium!.color!,
      valueFontSize: 16,
      msgColor: Theme.of(context).textTheme.titleMedium!.color!,
      msgFontSize: 16,
      completed: Completed(
        completionDelay: completionDelay,
        completedMsg: completedMsg,
        completedImage: const AssetImage('assets/images/completed.png'),
      ),
    );
    close(delay: closeDelay); ///1分钟后自动关闭
  }

  static void update({int value = 1, String? msg}){
    _progressDialog.update(value: value, msg: msg);
  }

  static void close({int? delay = 0}){
    _progressDialog.close(delay: delay);
  }

}



class ProgressOverlay extends ProgressDialog {

  final ValueNotifier _progress = ValueNotifier(0);
  final ValueNotifier _msg = ValueNotifier('');
  late BuildContext _context;
  ValueChanged<DialogStatus>? _onStatusChanged;
  late OverlayState overlayState = Overlay.of(_context);
  OverlayEntry? overlayEntry;

  ProgressOverlay({required BuildContext context}) : super(context: context){
    this._context = context;
  }

  @override
  void update({int? value, String? msg}) {
    if (value != null) _progress.value = value;
    if (msg != null) _msg.value = msg;
  }

  @override
  void close({int? delay = 0}) {
    ///部分进度弹框打开和关闭之间的间隔过短，无法识别是否已打开，需要等50毫秒后再检查进度弹窗是否已经打开
    if (delay == 0 || delay == null) {
      Future.delayed(Duration(milliseconds: 50), () {
        _removeOverlay();
      });
      return;
    }
    Future.delayed(Duration(milliseconds: delay + 50), () {
      _removeOverlay();
    });
  }

  @override
  bool isOpen() {
    return overlayEntry?.mounted ?? false;
  }

  ///[super._closeDialog]
  void _removeOverlay() {
    bool isOverlayOpen = isOpen();
    if (isOverlayOpen){
      try {
        ///移除加载进度框
        overlayEntry?.remove();
      } catch (e){}
      overlayEntry = null;
      _setDialogStatus(DialogStatus.closed);
    }
  }

  ///[super._setDialogStatus]
  void _setDialogStatus(DialogStatus status) {
    if (_onStatusChanged != null) _onStatusChanged!(status);
  }

  ///[super._valueProgress]
  _valueProgress({Color? valueColor, Color? bgColor, required double value}) {
    return CircularProgressIndicator(
      backgroundColor: bgColor,
      valueColor: AlwaysStoppedAnimation<Color?>(valueColor),
      value: value.toDouble() / 100,
    );
  }

  ///[super._normalProgress]
  _normalProgress({Color? valueColor, Color? bgColor}) {
    return CircularProgressIndicator(
      backgroundColor: bgColor,
      valueColor: AlwaysStoppedAnimation<Color?>(valueColor),
    );
  }


  @override
  Future<void> show({
    int max = 100,
    String msg = "Default Message",
    Completed? completed,
    Cancel? cancel,
    ProgressType progressType = ProgressType.indeterminate,
    ValuePosition valuePosition = ValuePosition.right,
    Color backgroundColor = Colors.white,
    Color? surfaceTintColor,
    Color barrierColor = Colors.transparent,
    Color progressValueColor = Colors.blueAccent,
    Color progressBgColor = Colors.blueGrey,
    Color valueColor = Colors.black87,
    Color msgColor = Colors.black87,
    TextAlign msgTextAlign = TextAlign.center,
    FontWeight msgFontWeight = FontWeight.bold,
    FontWeight valueFontWeight = FontWeight.normal,
    double valueFontSize = 15.0,
    double msgFontSize = 17.0,
    int msgMaxLines = 1,
    double elevation = 5.0,
    double borderRadius = 15.0,
    bool barrierDismissible = false,
    bool hideValue = false,
    int closeWithDelay = 100,
    ValueChanged<DialogStatus>? onStatusChanged,
  }) async {
    _msg.value = msg;
    _onStatusChanged = onStatusChanged;
    _setDialogStatus(DialogStatus.opened);
    double width = 280;
    double height = 80;
    Offset offset = Offset(
      (MediaQuery.of(_context).size.width - width) / 2,
      (MediaQuery.of(_context).size.height - height) / 2,
    );
    overlayEntry = OverlayEntry(
      builder: (BuildContext context){
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () async {
                  if (barrierDismissible){
                    ///移除加载进度框
                    ///这里不重置加载进度状态
                    overlayEntry?.remove();
                  }
                },
                child: Container(
                  color: barrierColor,
                ),
              )
            ),
            Positioned(
              top: offset.dy,
              left: offset.dx,
              child: Material(
                elevation: elevation,
                surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                shadowColor: Colors.transparent,
                color: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(borderRadius),
                  ),
                ),
                child: Container(
                  height: height, width: width,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    top: 16.0,
                    right: 24.0,
                    bottom: 24.0,
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: _progress,
                    builder: (BuildContext context, dynamic value, Widget? child) {
                      if (value == max) {
                        _setDialogStatus(DialogStatus.completed);
                        completed == null
                            ? close(delay: closeWithDelay)
                            : close(delay: completed.completionDelay);
                      }
                      Widget widget = Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (cancel != null)
                            ...[
                              cancel.autoHidden && value == max ?
                              SizedBox.shrink() :
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    close();
                                    if (cancel.cancelClicked != null)
                                      cancel.cancelClicked!();
                                  },
                                  child: Image(
                                    width: cancel.cancelImageSize,
                                    height: cancel.cancelImageSize,
                                    color: cancel.cancelImageColor,
                                    image: cancel.cancelImage ??
                                        AssetImage(
                                          "images/cancel.png",
                                          package: "sn_progress_dialog",
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          Row(
                            children: [
                              value == max && completed != null ?
                              Image(
                                width: 40,
                                height: 40,
                                image: completed.completedImage ??
                                    AssetImage(
                                      "images/completed.png",
                                      package: "sn_progress_dialog",
                                    ),
                              ) :
                              Container(
                                width: 35.0,
                                height: 35.0,
                                child: progressType == ProgressType.normal ?
                                _normalProgress(
                                  bgColor: progressBgColor,
                                  valueColor: progressValueColor,
                                ) :
                                value == 0 ?
                                _normalProgress(
                                  bgColor: progressBgColor,
                                  valueColor: progressValueColor,
                                ) :
                                _valueProgress(
                                  valueColor: progressValueColor,
                                  bgColor: progressBgColor,
                                  value: (value / max) * 100,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15.0,
                                    top: 8.0,
                                    bottom: 8.0,
                                  ),
                                  child: ValueListenableBuilder(
                                    valueListenable: _msg,
                                    builder: (BuildContext context, dynamic msgValue, Widget? child) {
                                      return AutoSizeText(
                                        value == max && completed != null
                                            ? completed.completedMsg
                                            : msgValue,
                                        textAlign: msgTextAlign,
                                        maxLines: msgMaxLines,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: msgFontSize,
                                          color: msgColor,
                                          fontWeight: msgFontWeight,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          hideValue == false ?
                          Align(
                            child: Text(
                              value <= 0 ? '' : '${_progress.value}/$max',
                              style: TextStyle(
                                fontSize: valueFontSize,
                                color: valueColor,
                                fontWeight: valueFontWeight,
                                decoration: value == max
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            alignment: valuePosition == ValuePosition.right
                                ? Alignment.bottomRight
                                : Alignment.bottomCenter,
                          ) :
                          SizedBox.shrink()
                        ],
                      );
                      return SingleChildScrollView(
                        child: widget,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
    overlayState.insert(overlayEntry!);
  }

}