
import 'package:basement/utils.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/ui/pages/root/root_controller.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


const EdgeInsets _defaultInsetPadding = EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0);

///能拖动的对话框窗体
///参考：https://github.com/aliMissaoui/Flutter-Package-Bouncing-Draggable-Dialog.git

/// A Material Design alert dialog.
///
/// An alert dialog (also known as a basic dialog) informs the user about
/// situations that require acknowledgement. An alert dialog has an optional
/// title and an optional list of actions. The title is displayed above the
/// content and the actions are displayed below the content.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=75CsnyRXf5I}
///
/// If the content is too large to fit on the screen vertically, the dialog will
/// display the title and the actions and let the content overflow, which is
/// rarely desired. Consider using a scrolling widget for [content], such as
/// [SingleChildScrollView], to avoid overflow. (However, be aware that since
/// [AlertDialog] tries to size itself using the intrinsic dimensions of its
/// children, widgets such as [ListView], [GridView], and [CustomScrollView],
/// which use lazy viewports, will not work. If this is a problem, consider
/// using [Dialog] directly.)
///
/// For dialogs that offer the user a choice between several options, consider
/// using a [SimpleDialog].
///
/// Typically passed as the child widget to [showDialog], which displays the
/// dialog.
///
/// {@animation 350 622 https://flutter.github.io/assets-for-api-docs/assets/material/alert_dialog.mp4}
///
/// {@tool snippet}
///
/// This snippet shows a method in a [State] which, when called, displays a dialog box
/// and returns a [Future] that completes when the dialog is dismissed.
///
/// ```dart
/// Future<void> _showMyDialog() async {
///   return showDialog<void>(
///     context: context,
///     barrierDismissible: false, // user must tap button!
///     builder: (BuildContext context) {
///       return AlertDialog(
///         title: const Text('AlertDialog Title'),
///         content: SingleChildScrollView(
///           child: ListBody(
///             children: const <Widget>[
///               Text('This is a demo alert dialog.'),
///               Text('Would you like to approve of this message?'),
///             ],
///           ),
///         ),
///         actions: <Widget>[
///           TextButton(
///             child: const Text('Approve'),
///             onPressed: () {
///               Navigator.of(context).pop();
///             },
///           ),
///         ],
///       );
///     },
///   );
/// }
/// ```
/// {@end-tool}
///
/// {@tool dartpad}
/// This demo shows a [TextButton] which when pressed, calls [showDialog]. When called, this method
/// displays a Material dialog above the current contents of the app and returns
/// a [Future] that completes when the dialog is dismissed.
///
/// ** See code in examples/api/lib/material/dialog/alert_dialog.0.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This sample shows the creation of [AlertDialog], as described in:
/// https://m3.material.io/components/dialogs/overview
///
/// ** See code in examples/api/lib/material/dialog/alert_dialog.1.dart **
/// {@end-tool}
///
/// See also:
///
///  * [SimpleDialog], which handles the scrolling of the contents but has no [actions].
///  * [Dialog], on which [AlertDialog] and [SimpleDialog] are based.
///  * [CupertinoAlertDialog], an iOS-styled alert dialog.
///  * [showDialog], which actually displays the dialog and returns its result.
///  * <https://material.io/design/components/dialogs.html#alert-dialog>
///  * <https://m3.material.io/components/dialogs>

class DraggableDialog extends StatefulWidget {

  /// Creates an alert dialog.
  ///
  /// Typically used in conjunction with [showDialog].
  ///
  /// The [titlePadding] and [contentPadding] default to null, which implies a
  /// default that depends on the values of the other properties. See the
  /// documentation of [titlePadding] and [contentPadding] for details.
  const DraggableDialog({
    super.key,
    this.icon,
    this.iconPadding,
    this.iconColor,
    this.title,
    this.titlePadding,
    this.caption,
    this.isMaximize = false,
    this.initialWidth,
    this.initialHeight,
    this.titleTextStyle,
    this.content,
    this.contentPadding,
    this.contentTextStyle,
    this.actions,
    this.actionsPadding,
    this.actionsAlignment,
    this.actionsOverflowAlignment,
    this.actionsOverflowDirection,
    this.actionsOverflowButtonSpacing,
    this.buttonPadding,
    this.backgroundColor,
    this.elevation,
    this.semanticLabel,
    this.insetPadding = _defaultInsetPadding,
    this.clipBehavior = Clip.none,
    this.shape,
    this.alignment,
    this.scrollable = false,
    this.titleBarWidgetList = const [],
  });

  final List<Widget> titleBarWidgetList;

  ///初始宽度
  final double? initialWidth;

  ///初始高度
  final double? initialHeight;

  ///是否初始最大化
  final bool isMaximize;

  /// An optional icon to display at the top of the dialog.
  ///
  /// Typically, an [Icon] widget. Providing an icon centers the [title]'s text.
  final Widget? icon;

  /// Color for the [Icon] in the [icon] of this [AlertDialog].
  ///
  /// If null, [DialogTheme.iconColor] is used. If that is null, defaults to
  /// color scheme's [ColorScheme.secondary] if [ThemeData.useMaterial3] is
  /// true, black otherwise.
  final Color? iconColor;

  /// Padding around the [icon].
  ///
  /// If there is no [icon], no padding will be provided. Otherwise, this
  /// padding is used.
  ///
  /// This property defaults to providing 24 pixels on the top, left, and right
  /// of the [icon]. If [title] is _not_ null, 16 pixels of bottom padding is
  /// added to separate the [icon] from the [title]. If the [title] is null and
  /// [content] is _not_ null, then no bottom padding is provided (but see
  /// [contentPadding]). In any other case 24 pixels of bottom padding is
  /// added.
  final EdgeInsetsGeometry? iconPadding;

  /// The (optional) title of the dialog is displayed in a large font at the top
  /// of the dialog, below the (optional) [icon].
  ///
  /// Typically a [Text] widget.
  final Widget? title;

  /// Padding around the title.
  ///
  /// If there is no title, no padding will be provided. Otherwise, this padding
  /// is used.
  ///
  /// This property defaults to providing 24 pixels on the top, left, and right
  /// of the title. If the [content] is not null, then no bottom padding is
  /// provided (but see [contentPadding]). If it _is_ null, then an extra 20
  /// pixels of bottom padding is added to separate the [title] from the
  /// [actions].
  final EdgeInsetsGeometry? titlePadding;

  /// Style for the text in the [title] of this [AlertDialog].
  ///
  /// If null, [DialogTheme.titleTextStyle] is used. If that's null, defaults to
  /// [TextTheme.headline6] of [ThemeData.textTheme].
  final TextStyle? titleTextStyle;

  final String? caption;

  /// The (optional) content of the dialog is displayed in the center of the
  /// dialog in a lighter font.
  ///
  /// Typically this is a [SingleChildScrollView] that contains the dialog's
  /// message. As noted in the [AlertDialog] documentation, it's important
  /// to use a [SingleChildScrollView] if there's any risk that the content
  /// will not fit.
  final Widget? content;

  /// Padding around the content.
  ///
  /// If there is no [content], no padding will be provided. Otherwise, this
  /// padding is used.
  ///
  /// This property defaults to providing a padding of 20 pixels above the
  /// [content] to separate the [content] from the [title], and 24 pixels on the
  /// left, right, and bottom to separate the [content] from the other edges of
  /// the dialog.
  ///
  /// If [ThemeData.useMaterial3] is true, the top padding separating the
  /// content from the title defaults to 16 pixels instead of 20 pixels.
  final EdgeInsetsGeometry? contentPadding;

  /// Style for the text in the [content] of this [AlertDialog].
  ///
  /// If null, [DialogTheme.contentTextStyle] is used. If that's null, defaults
  /// to [TextTheme.subtitle1] of [ThemeData.textTheme].
  final TextStyle? contentTextStyle;

  /// The (optional) set of actions that are displayed at the bottom of the
  /// dialog with an [OverflowBar].
  ///
  /// Typically this is a list of [TextButton] widgets. It is recommended to
  /// set the [Text.textAlign] to [TextAlign.end] for the [Text] within the
  /// [TextButton], so that buttons whose labels wrap to an extra line align
  /// with the overall [OverflowBar]'s alignment within the dialog.
  ///
  /// If the [title] is not null but the [content] _is_ null, then an extra 20
  /// pixels of padding is added above the [OverflowBar] to separate the [title]
  /// from the [actions].
  final List<Widget>? actions;

  /// Padding around the set of [actions] at the bottom of the dialog.
  ///
  /// Typically used to provide padding to the button bar between the button bar
  /// and the edges of the dialog.
  ///
  /// If there are no [actions], then no padding will be included. It is also
  /// important to note that [buttonPadding] may contribute to the padding on
  /// the edges of [actions] as well.
  ///
  /// {@tool snippet}
  /// This is an example of a set of actions aligned with the content widget.
  /// ```dart
  /// AlertDialog(
  ///   title: const Text('Title'),
  ///   content: Container(width: 200, height: 200, color: Colors.green),
  ///   actions: <Widget>[
  ///     ElevatedButton(onPressed: () {}, child: const Text('Button 1')),
  ///     ElevatedButton(onPressed: () {}, child: const Text('Button 2')),
  ///   ],
  ///   actionsPadding: const EdgeInsets.symmetric(horizontal: 8.0),
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  /// * [OverflowBar], which [actions] configures to lay itself out.
  final EdgeInsetsGeometry? actionsPadding;

  /// Defines the horizontal layout of the [actions] according to the same
  /// rules as for [Row.mainAxisAlignment].
  ///
  /// This parameter is passed along to the dialog's [OverflowBar].
  ///
  /// If this parameter is null (the default) then [MainAxisAlignment.end]
  /// is used.
  final MainAxisAlignment? actionsAlignment;

  /// The horizontal alignment of [actions] within the vertical
  /// "overflow" layout.
  ///
  /// If the dialog's [actions] do not fit into a single row, then they
  /// are arranged in a column. This parameter controls the horizontal
  /// alignment of widgets in the case of an overflow.
  ///
  /// If this parameter is null (the default) then [OverflowBarAlignment.end]
  /// is used.
  ///
  /// See also:
  ///
  /// * [OverflowBar], which [actions] configures to lay itself out.
  final OverflowBarAlignment? actionsOverflowAlignment;

  /// The vertical direction of [actions] if the children overflow
  /// horizontally.
  ///
  /// If the dialog's [actions] do not fit into a single row, then they
  /// are arranged in a column. The first action is at the top of the
  /// column if this property is set to [VerticalDirection.down], since it
  /// "starts" at the top and "ends" at the bottom. On the other hand,
  /// the first action will be at the bottom of the column if this
  /// property is set to [VerticalDirection.up], since it "starts" at the
  /// bottom and "ends" at the top.
  ///
  /// See also:
  ///
  /// * [OverflowBar], which [actions] configures to lay itself out.
  final VerticalDirection? actionsOverflowDirection;

  /// The spacing between [actions] when the [OverflowBar] switches
  /// to a column layout because the actions don't fit horizontally.
  ///
  /// If the widgets in [actions] do not fit into a single row, they are
  /// arranged into a column. This parameter provides additional
  /// vertical space in between buttons when it does overflow.
  ///
  /// Note that the button spacing may appear to be more than
  /// the value provided. This is because most buttons adhere to the
  /// [MaterialTapTargetSize] of 48px. So, even though a button
  /// might visually be 36px in height, it might still take up to
  /// 48px vertically.
  ///
  /// If null then no spacing will be added in between buttons in
  /// an overflow state.
  final double? actionsOverflowButtonSpacing;

  /// The padding that surrounds each button in [actions].
  ///
  /// This is different from [actionsPadding], which defines the padding
  /// between the entire button bar and the edges of the dialog.
  ///
  /// If this property is null, then it will default to
  /// 8.0 logical pixels on the left and right.
  final EdgeInsetsGeometry? buttonPadding;

  /// {@macro flutter.material.dialog.backgroundColor}
  final Color? backgroundColor;

  /// {@macro flutter.material.dialog.elevation}
  /// {@macro flutter.material.material.elevation}
  final double? elevation;

  /// The semantic label of the dialog used by accessibility frameworks to
  /// announce screen transitions when the dialog is opened and closed.
  ///
  /// In iOS, if this label is not provided, a semantic label will be inferred
  /// from the [title] if it is not null.
  ///
  /// In Android, if this label is not provided, the dialog will use the
  /// [MaterialLocalizations.alertDialogLabel] as its label.
  ///
  /// See also:
  ///
  ///  * [SemanticsConfiguration.namesRoute], for a description of how this
  ///    value is used.
  final String? semanticLabel;

  /// {@macro flutter.material.dialog.insetPadding}
  final EdgeInsets insetPadding;

  /// {@macro flutter.material.dialog.clipBehavior}
  final Clip clipBehavior;

  /// {@macro flutter.material.dialog.shape}
  final ShapeBorder? shape;

  /// {@macro flutter.material.dialog.alignment}
  final AlignmentGeometry? alignment;

  /// Determines whether the [title] and [content] widgets are wrapped in a
  /// scrollable.
  ///
  /// This configuration is used when the [title] and [content] are expected
  /// to overflow. Both [title] and [content] are wrapped in a scroll view,
  /// allowing all overflowed content to be visible while still showing the
  /// button bar.
  final bool scrollable;


  @override
  DraggableDialogStat createState()  => DraggableDialogStat();

}

class DraggableDialogStat extends State<DraggableDialog> with SingleTickerProviderStateMixin {

  double dialogWidth = 0;
  double dialogHeight = 0;
  var _dragAlignment = Alignment.center;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));

    final size = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final DialogThemeData dialogTheme = DialogTheme.of(context);
    final DialogTheme defaults = theme.useMaterial3 ? _DialogDefaultsM3(context) : _DialogDefaultsM2(context);

    if(dialogWidth == 0){
      dialogWidth = widget.isMaximize ? size.width : (widget.initialWidth ?? size.width *.5);
      dialogHeight = widget.isMaximize ? size.height : (widget.initialHeight ?? size.height *.6);
    }


    String? label = widget.semanticLabel;
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        label ??= MaterialLocalizations.of(context).alertDialogLabel;
    }

    // The paddingScaleFactor is used to adjust the padding of Dialog's
    // children.
    final double paddingScaleFactor = _paddingScaleFactor(FontFamilyConfig.textScale);
    final TextDirection? textDirection = Directionality.maybeOf(context);

    Widget? iconWidget;
    Widget? titleWidget;
    Widget? contentWidget;
    Widget? actionsWidget;
    Widget dividerWidget = Divider(
      indent: 0, endIndent: 0,
      color: Theme.of(context).dividerTheme.color?.withAlpha(102) ?? Colors.white70,
    );

    ///用不到
    if (widget.icon != null) {
      final bool belowIsTitle = widget.title != null;
      final bool belowIsContent = !belowIsTitle && widget.content != null;
      final EdgeInsets defaultIconPadding = EdgeInsets.only(
        left: 24.0,
        top: 24.0,
        right: 24.0,
        bottom: belowIsTitle ? 16.0 : belowIsContent ? 0.0 : 24.0,
      );
      final EdgeInsets effectiveIconPadding = widget.iconPadding?.resolve(textDirection) ?? defaultIconPadding;
      iconWidget = Padding(
        padding: EdgeInsets.only(
          left: effectiveIconPadding.left * paddingScaleFactor,
          right: effectiveIconPadding.right * paddingScaleFactor,
          top: effectiveIconPadding.top * paddingScaleFactor,
          bottom: effectiveIconPadding.bottom,
        ),
        child: IconTheme(
          data: IconThemeData(
            color: widget.iconColor ?? dialogTheme.iconColor ?? defaults.iconColor,
          ),
          child: widget.icon!,
        ),
      );
    }

    ///用不到
    if (widget.title != null) {
      final EdgeInsets defaultTitlePadding = EdgeInsets.only(
        left: 24.0,
        top: widget.icon == null ? 24.0 : 0.0,
        right: 24.0,
        bottom: widget.content == null ? 20.0 : 0.0,
      );
      final EdgeInsets effectiveTitlePadding = widget.titlePadding?.resolve(textDirection) ?? defaultTitlePadding;
      titleWidget = Padding(
        padding: EdgeInsets.only(
          left: effectiveTitlePadding.left * paddingScaleFactor,
          right: effectiveTitlePadding.right * paddingScaleFactor,
          top: widget.icon == null ? effectiveTitlePadding.top * paddingScaleFactor : effectiveTitlePadding.top,
          bottom: effectiveTitlePadding.bottom,
        ),
        child: DefaultTextStyle(
          style: widget.titleTextStyle ?? dialogTheme.titleTextStyle ?? defaults.titleTextStyle!,
          textAlign: widget.icon == null ? TextAlign.start : TextAlign.center,
          child: Semantics(
            // For iOS platform, the focus always lands on the title.
            // Set nameRoute to false to avoid title being announce twice.
            namesRoute: label == null && theme.platform != TargetPlatform.iOS,
            container: true,
            child: widget.title,
          ),
        ),
      );
    }

    ///标题 todo 桌面端也改成新的，需要调整一下按钮大小，操作栏也是
    if (widget.caption != null){
      if (kIsWeb || GetPlatform.isWindows){
        titleWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 8,),
                Expanded(
                    child: Text(
                      widget.caption!,
                      style: Theme.of(context).textTheme.titleSmall,
                    )
                ),
                ...widget.titleBarWidgetList.map((e){
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: e,
                  );
                }),
                if (!kIsWeb && GetPlatform.isWindows)
                  MineIconButton(
                    icon: Icons.keyboard,
                    tooltip: '软键盘',
                    onPressed: () async {
                      await Get.find<RootController>().openKeyboard();
                    },
                  ),
                if (!kIsWeb && GetPlatform.isWindows)
                  const SizedBox(width: 8),
                if(dialogWidth != size.width)
                  MineIconButton(
                    icon: FluentIcons.arrow_maximize_16_filled,
                    tooltip: '最大化',
                    onPressed: () async {
                      setState(() {
                        if (kDebugMode) {
                          PrintUtil.printDebug("setState");
                        }
                        dialogWidth = size.width;
                        dialogHeight = size.height;
                      });
                    },
                  ),
                if(dialogWidth == size.width)
                  MineIconButton(
                    icon: FluentIcons.arrow_minimize_16_filled,
                    tooltip: '还原',
                    onPressed: () async {
                      setState(() {
                        if (kDebugMode) {
                          PrintUtil.printDebug("setState");
                        }
                        dialogWidth = (widget.initialWidth ?? (size.width *.5).toDouble());
                        dialogHeight = (widget.initialHeight ?? size.height *.6);
                      });
                    },
                  ),
                const SizedBox(width: 8),
                MineIconButton(),
              ],
            )
        );
      }
      else {
        titleWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Stack(
            alignment: AlignmentDirectional.centerEnd,
            children: [
              Center(
                child: Text(
                  widget.caption!,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...widget.titleBarWidgetList.map((e){
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: e,
                      );
                    }),
                    if (dialogWidth != size.width)
                      MineIconButton(
                        icon: FluentIcons.arrow_maximize_16_filled,
                        tooltip: '最大化',
                        onPressed: () async {
                          setState(() {
                            if (kDebugMode) {
                              PrintUtil.printDebug("setState");
                            }
                            dialogWidth = size.width;
                            dialogHeight = size.height;
                          });
                        },
                      ),
                    if(dialogWidth == size.width)
                      MineIconButton(
                        icon: FluentIcons.arrow_minimize_16_filled,
                        tooltip: '还原',
                        onPressed: () async {
                          setState(() {
                            if (kDebugMode) {
                              PrintUtil.printDebug("setState");
                            }
                            dialogWidth = (widget.initialWidth ?? (size.width *.5).toDouble());
                            dialogHeight = (widget.initialHeight ?? size.height *.6);
                          });
                        },
                      ),
                    const SizedBox(width: 8),
                    MineIconButton(),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }

    ///标题栏增加拖拽手势
    if (titleWidget != null){
      titleWidget = GestureDetector(
        //onPanStart: (details) => {},
        onPanUpdate: (details) =>
            setState(() {
              _dragAlignment += Alignment(
                details.delta.dx / (size.width / 2),
                details.delta.dy / (size.height / 2),
              );
            }),
        //onPanEnd: (details) => {},
        child: titleWidget,
      );
    }

    ///主内容
    if (widget.content != null) {
      final EdgeInsets defaultContentPadding = EdgeInsets.only(
        left: 24.0,
        top: theme.useMaterial3 ? 16.0 : 20.0,
        right: 24.0,
        bottom: 24.0,
      );
      final EdgeInsets effectiveContentPadding = widget.contentPadding?.resolve(textDirection) ?? defaultContentPadding;
      contentWidget = Container(
        color: Theme.of(context).colorScheme.surface,
        padding: EdgeInsets.only(
          left: effectiveContentPadding.left * paddingScaleFactor,
          right: effectiveContentPadding.right * paddingScaleFactor,
          top: widget.title == null && widget.icon == null
              ? effectiveContentPadding.top * paddingScaleFactor
              : effectiveContentPadding.top,
          bottom: effectiveContentPadding.bottom,
        ),
        child: DefaultTextStyle(
          style: widget.contentTextStyle ?? dialogTheme.contentTextStyle ?? defaults.contentTextStyle!,
          child: Semantics(
            container: true,
            child: widget.content,
          ),
        ),
      );
    }

    ///操作栏
    if (widget.actions != null) {
      final double spacing = (widget.buttonPadding?.horizontal ?? 16) / 2;

      ///窗体大小可拖动的图标位置，右下角
      Widget draggable = Container(
        padding: const EdgeInsets.only(bottom: 1, right: 1),
        alignment: Alignment.bottomRight,
        child: ManipulatingBall(
          icon: Image.asset(
            'assets/images/draggable.png',
            width: 12, height: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onDrag: (dx, dy) {
            var mid = (dx + dy) / 2;
            var newHeight = dialogHeight + 2 * mid;
            var newWidth = dialogWidth + 2 * mid;
            ///最小高度处理
            if(newHeight < 240){
              return;
            }
            setState(() {
              dialogHeight = newHeight;
              dialogWidth = newWidth;
            });
          },
        ),
      );

      if (kIsWeb || GetPlatform.isWindows){
        actionsWidget = IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:[
              Expanded(
                child: Padding(
                  padding: widget.actionsPadding ?? dialogTheme.actionsPadding ?? (
                    theme.useMaterial3
                        ? defaults.actionsPadding!
                        : defaults.actionsPadding!.add(EdgeInsets.all(spacing))
                  ),
                  child: OverflowBar(
                    alignment: widget.actionsAlignment ?? MainAxisAlignment.end,
                    spacing: spacing,
                    overflowAlignment: widget.actionsOverflowAlignment ?? OverflowBarAlignment.end,
                    overflowDirection: widget.actionsOverflowDirection ?? VerticalDirection.down,
                    overflowSpacing: widget.actionsOverflowButtonSpacing ?? 0,
                    children: widget.actions!,
                  ),
                ),
              ),
              draggable,
            ]
          ),
        );
      }
      else {
        actionsWidget = Container(
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Container(
                alignment: Alignment.center,
                padding: widget.actionsPadding ?? dialogTheme.actionsPadding ?? (
                    theme.useMaterial3
                        ? defaults.actionsPadding!
                        : defaults.actionsPadding!.add(EdgeInsets.all(spacing))
                ),
                child: OverflowBar(
                  alignment: widget.actionsAlignment ?? MainAxisAlignment.end,
                  spacing: spacing,
                  overflowAlignment: widget.actionsOverflowAlignment ?? OverflowBarAlignment.end,
                  overflowDirection: widget.actionsOverflowDirection ?? VerticalDirection.down,
                  overflowSpacing: widget.actionsOverflowButtonSpacing ?? 0,
                  children: widget.actions!,
                ),
              ),
              Positioned(
                child: draggable,
              ),
            ],
          ),
        );
      }
    }

    List<Widget> columnChildren;
    if (widget.scrollable) {
      columnChildren = <Widget>[
        if (titleWidget != null || widget.content != null)
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (widget.icon != null) iconWidget!,
                if (titleWidget != null) titleWidget,
                if (titleWidget != null && (kIsWeb || GetPlatform.isWindows)) dividerWidget,
                if (widget.content != null) Expanded(child: contentWidget!),
              ],
            ),
          ),

        if (widget.actions != null && (kIsWeb || GetPlatform.isWindows)) dividerWidget,
        if (widget.actions != null)
          actionsWidget!,
      ];
    }
    else {
      columnChildren = <Widget>[
        if (widget.icon != null) iconWidget!,
        if (titleWidget != null) titleWidget,
        if (titleWidget != null && (kIsWeb || GetPlatform.isWindows)) dividerWidget,
        if (widget.content != null) Expanded(child: contentWidget!),
        if (widget.actions != null && (kIsWeb || GetPlatform.isWindows)) dividerWidget,
        if (widget.actions != null) actionsWidget!,
      ];
    }

    Widget dialogChild = IntrinsicWidth(
      child: Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(4),
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columnChildren,
      )
      ),
    );

    if (label != null) {
      dialogChild = Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        namesRoute: true,
        label: label,
        child: dialogChild,
      );
    }

    return Dialog(
      //backgroundColor: widget.backgroundColor ?? Colors.transparent,
      //elevation: widget.elevation ?? 0,
      //insetPadding: widget.insetPadding,
      //clipBehavior: widget.clipBehavior,
      //alignment: widget.alignment,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Align(
        alignment: _dragAlignment,
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: dialogChild
        ),
      ),
    );
  }
}


// Hand coded defaults based on Material Design 2.
class _DialogDefaultsM2 extends DialogTheme {
  _DialogDefaultsM2(this.context)
      : _textTheme = Theme.of(context).textTheme,
        _iconTheme = Theme.of(context).iconTheme,
        super(
        alignment: Alignment.center,
        elevation: 24.0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  final TextTheme _textTheme;
  final IconThemeData _iconTheme;

  @override
  Color? get iconColor => _iconTheme.color;

  @override
  Color? get backgroundColor => ElevationOverlay.colorWithOverlay(_colors.surface, _colors.primary, 6.0);

  @override
  TextStyle? get titleTextStyle => _textTheme.headlineSmall;

  @override
  TextStyle? get contentTextStyle => _textTheme.bodyMedium;

  @override
  EdgeInsetsGeometry? get actionsPadding => EdgeInsets.zero;
}

// BEGIN GENERATED TOKEN PROPERTIES - Dialog

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

// Token database version: v0_101

class _DialogDefaultsM3 extends DialogTheme {
  _DialogDefaultsM3(this.context)
      : super(
    alignment: Alignment.center,
    elevation: 6.0,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(28.0), topRight: Radius.circular(28.0), bottomLeft: Radius.circular(28.0), bottomRight: Radius.circular(28.0))),
  );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get iconColor => _colors.secondary;

  @override
  Color? get backgroundColor => ElevationOverlay.colorWithOverlay(_colors.surface, _colors.primary, 6.0);

  @override
  TextStyle? get titleTextStyle => _textTheme.headlineSmall;

  @override
  TextStyle? get contentTextStyle => _textTheme.bodyMedium;

  @override
  EdgeInsetsGeometry? get actionsPadding => const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0);
}

double _paddingScaleFactor(double textScaleFactor) {
  final double clampedTextScaleFactor = clampDouble(textScaleFactor, 1.0, 2.0);
  // The final padding scale factor is clamped between 1/3 and 1. For example,
  // a non-scaled padding of 24 will produce a padding between 24 and 8.
  return _lerpDouble(1.0, 1.0 / 3.0, clampedTextScaleFactor - 1.0)!;
}


/// Linearly interpolate between two numbers, `a` and `b`, by an extrapolation
/// factor `t`.
///
/// When `a` and `b` are equal or both NaN, `a` is returned.  Otherwise,
/// `a`, `b`, and `t` are required to be finite or null, and the result of `a +
/// (b - a) * t` is returned, where nulls are defaulted to 0.0.
double? _lerpDouble(num? a, num? b, double t) {
  if (a == b || (a?.isNaN == true) && (b?.isNaN == true)) {
    return a?.toDouble();
  }
  a ??= 0.0;
  b ??= 0.0;
  assert(a.isFinite, 'Cannot interpolate between finite and non-finite values');
  assert(b.isFinite, 'Cannot interpolate between finite and non-finite values');
  assert(t.isFinite, 't must be finite when interpolating between values');
  return a * (1.0 - t) + b * t;
}




///https://github.com/SamiaAshraff/auto_size_widget
class AutoSizeWidget extends StatefulWidget {
  const AutoSizeWidget(
  {super.key,
  this.boxDecoration,
  this.borderColor,
  required this.initialHeight,
  required this.showIcon,
  required this.child,
  required this.initialWidth,
  required this.maxWidth,
  required this.maxHeight});

  final Widget child;
  final BoxDecoration? boxDecoration;
  final double initialHeight;
  final Color? borderColor;
  final double initialWidth;
  final bool showIcon;
  final double maxWidth;
  final double maxHeight;

  @override
  AutoSizeWidgetState createState() => AutoSizeWidgetState();
}

class AutoSizeWidgetState extends State<AutoSizeWidget> {
  double height = 0;
  double width = 0;
  double maxWidth = 0;
  double maxHeight = 0;

  double top = 0;
  double left = 0;

  double startHeight = 0;
  double startWidth = 0;

  void onDrag(double dx, double dy) {
    var newHeight = height + dy;
    var newWidth = width + dx;

    setState(() {
      height = newHeight > height
          ? newHeight <= maxHeight
          ? newHeight
          : maxHeight
          : height;
      width = newWidth > width
          ? newWidth <= maxWidth
          ? newWidth
          : maxWidth
          : width;
    });
  }

  @override
  void initState() {
    setState(() {
      height = widget.initialHeight;
      maxHeight = widget.maxHeight;
      maxWidth = widget.maxWidth;
      width = widget.initialWidth;
      startHeight = widget.initialHeight;
      startWidth = widget.initialWidth;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Positioned(
            top: top,
            left: left,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                    decoration: widget.boxDecoration ??
                        BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: widget.borderColor ?? Colors.grey),
                            borderRadius: BorderRadius.circular(5)),
                    height: height,
                    width: width,
                    child: widget.child),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: ManipulatingBall(
              icon: widget.showIcon
                  ? const Icon(Icons.dashboard_customize)
                  : Container(
                color: Colors.transparent,
                width: 15,
                height: 15,
              ),
              onDrag: (dx, dy) {
                var mid = (dx + dy) / 2;

                var newHeight = height + 2 * mid;
                var newWidth = width + 2 * mid;

                setState(() {
                  startHeight = newHeight;
                  startWidth = newWidth;
                  height = newHeight > widget.initialHeight
                      ? newHeight <= maxHeight
                      ? newHeight
                      : maxHeight
                      : widget.initialHeight;
                  width = newWidth > widget.initialWidth
                      ? newWidth <= maxWidth
                      ? newWidth
                      : maxWidth
                      : widget.initialWidth;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ManipulatingBall extends StatefulWidget {
  const ManipulatingBall({super.key,  required this.icon, required this.onDrag});

  final Function onDrag;
  final Widget icon;

  @override
  ManipulatingBallState createState() => ManipulatingBallState();
}

class ManipulatingBallState extends State<ManipulatingBall> {
  double? initX;
  double? initY;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: MouseRegion(
          cursor: SystemMouseCursors.resizeUpLeftDownRight,
          child: widget.icon),
    );
  }
}




