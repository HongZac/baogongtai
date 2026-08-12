
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/dynamic_overflow.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/flyout.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/flyout_content.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/flyout_controller.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/horizontal_scroll_view.dart';
import 'package:desktop/app/ui/widget/fluent_ui/dropdown_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'menu.dart';


/// A card with appropriate margins, padding, and elevation for it to
/// contain one or more [CommandBar]s.
class CommandBarCard extends StatelessWidget {
  const CommandBarCard({
    Key? key,
    required this.child,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(8),
    this.width,
    this.color,
  }) : super(key: key);

  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsets padding;
  final double? width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(4),
        color: color,
        child: Container(
          padding: padding,
          width: width,
          child: child
        ),
      ),
    );
  }
}

/// How horizontal overflow is handled for the items on the primary area
/// of a CommandBar.
enum CommandBarOverflowBehavior {
  /// Will cause items to scroll horizontally.
  scrolling,

  /// Will expand the size of the CommandBar based on the size of the contained items.
  noWrap,

  /// Will wrap items onto additional lines as needed.
  wrap,

  /// Will keep items on one line and clip as needed.
  clip,

  /// Will dynamically move overflowing items into the "secondary area"
  /// (shown as a flyout menu when the overflow item is activated).
  dynamicOverflow,
}

/// Signature of function that will build a [CommandBarItem] with some
/// functionality to trigger an action (e.g., a clickable button), and
/// it will call the given callback when the action is triggered.
typedef CommandBarActionItemBuilder = CommandBarItem Function(
    VoidCallback onPressed);

/// Command bars provide quick access to common tasks. This could be
/// application-level or page-level commands.
///
/// A command bar is composed of a series of [CommandBarItem]s, which each could
/// be a [CommandBarButton] or a custom [CommandBarItem].
///
/// If there is not enough horizontal space to display all items, the overflow
/// behavior is determined by [overflowBehavior].
///
/// ![CommandBar example](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/controls-appbar-icons.png)
///
/// See also:
///
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/command-bar>
class CommandBar extends StatefulWidget {

  //region
  /// The [CommandBarItem]s that should appear on the primary area.
  final List<CommandBarItem> primaryItems;

  /// If non-empty, a "overflow item" will appear on the primary area
  /// (as built by [overflowItemBuilder], or it will be a "more" button
  /// if [overflowItemBuilder] is null), and when activated, will show a
  /// flyout containing this list of secondary items.
  final List<CommandBarItem> secondaryItems;

  /// Allows customization of the "overflow item" that will appear on the
  /// primary area of the command bar if there are any items in the
  /// [secondaryItems] (including any items that are dynamically considered
  /// to be there if [overflowBehavior] is
  /// [CommandBarOverflowBehavior.dynamicOverflow].)
  final CommandBarActionItemBuilder? overflowItemBuilder;

  /// Determines what should happen when the items are too wide for the
  /// primary command bar area. See [CommandBarOverflowBehavior].
  final CommandBarOverflowBehavior overflowBehavior;

  /// If the width of this widget is less then the indicated amount,
  /// items in the primary area will be rendered using
  /// [CommandBarItemDisplayMode.inPrimaryCompact]. If this is `null`
  /// or the width of this widget is wider, then the items will be rendered
  /// using [CommandBarItemDisplayMode.inPrimary].
  final double? compactBreakpointWidth;

  /// If [compactBreakpointWidth] is `null`, then specifies whether or not
  /// primary items should be displayed in compact mode
  /// ([CommandBarItemDisplayMode.inPrimaryCompact]) or normal mode
  /// [CommandBarItemDisplayMode.inPrimary].
  ///
  /// This can be useful if the CommandBar is used in a setting where
  /// [compactBreakpointWidth] cannot be used (i.e. because using
  /// [LayoutBuilder] cannot be used in a context where the intrinsic
  /// height is also calculated), and you want to specify whether or not
  /// the primary items should be compact or not.
  ///
  /// If [compactBreakpointWidth] is not `null` this field is ignored.
  final bool? isCompact;

  /// The alignment of the items within the command bar across the main axis
  final MainAxisAlignment mainAxisAlignment;

  /// The alignment of the items within the command bar across the cross axis
  final CrossAxisAlignment crossAxisAlignment;

  /// The alignment of the overflow item (if displayed) between the end of
  /// the visible primary items and the end of the boundaries of this widget.
  /// Only relevant if [overflowBehavior] is
  /// [CommandBarOverflowBehavior.dynamicOverflow].
  final MainAxisAlignment overflowItemAlignment;

  final bool _isExpanded;

  const CommandBar({
    Key? key,
    required this.primaryItems,
    this.secondaryItems = const [],
    this.overflowItemBuilder,
    this.overflowBehavior = CommandBarOverflowBehavior.dynamicOverflow,
    this.compactBreakpointWidth,
    this.isCompact,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.overflowItemAlignment = MainAxisAlignment.end,
  })  : _isExpanded = overflowBehavior != CommandBarOverflowBehavior.noWrap,
        super(key: key);
  //endregion

  @override
  CommandBarState createState() => CommandBarState();
}

class CommandBarState extends State<CommandBar> {
  final FlyoutController secondaryFlyoutController = FlyoutController();
  List<int> dynamicallyHiddenPrimaryItems = [];

  @override
  void dispose() {
    secondaryFlyoutController.dispose();
    super.dispose();
  }

  WrapAlignment _getWrapAlignment() {
    switch (widget.mainAxisAlignment) {
      case MainAxisAlignment.start:
        return WrapAlignment.start;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
    }
  }

  WrapCrossAlignment _getWrapCrossAlignment() {
    switch (widget.crossAxisAlignment) {
      case CrossAxisAlignment.start:
        return WrapCrossAlignment.start;
      case CrossAxisAlignment.end:
        return WrapCrossAlignment.end;
      case CrossAxisAlignment.center:
        return WrapCrossAlignment.center;
      case CrossAxisAlignment.stretch:
      case CrossAxisAlignment.baseline:
        throw UnsupportedError(
          'CommandBar does not support ${widget.crossAxisAlignment}',
        );
    }
  }

  Widget _buildForPrimaryMode(BuildContext context, CommandBarItemDisplayMode primaryMode) {
    final builtItems = widget.primaryItems.map((item) => item.build(context, primaryMode));
    Widget? overflowWidget;
    if (widget.secondaryItems.isNotEmpty || widget.overflowBehavior == CommandBarOverflowBehavior.dynamicOverflow) {
      void showSecondaryMenu() {
        secondaryFlyoutController.open();
      }

      late CommandBarItem overflowItem;
      if (widget.overflowItemBuilder != null) {
        overflowItem = widget.overflowItemBuilder!(showSecondaryMenu);
      }
      else {
        overflowItem = CommandBarButton(
          onPressed: showSecondaryMenu,
          message: '更多',
          icon: Icons.more_horiz,
        );
      }

      var allSecondaryItems = [
        ...dynamicallyHiddenPrimaryItems.map((index) => widget.primaryItems[index]),
        ...widget.secondaryItems,
      ];
      // It's useless if the first item is a separator
      if (allSecondaryItems.isNotEmpty && allSecondaryItems.first is CommandBarSeparator) {
        allSecondaryItems.removeAt(0);
      }

      ///弹出框按钮
      overflowWidget = Flyout(
        openMode: FlyoutOpenMode.none, ///弹出框打开方式
        position: FlyoutPosition.below,
        placement: FlyoutPlacement.end,
        controller: secondaryFlyoutController,
        child: overflowItem.build(context, primaryMode),
        content: (context) => FlyoutContent(
          constraints: const BoxConstraints(maxWidth: 120.0),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            shrinkWrap: true,
            children: List.generate(allSecondaryItems.length, (index) {
              CommandBarItem item = allSecondaryItems[index];
              if (item is CommandBarButton){
                CommandBarButton commandBarButton = CommandBarButton(
                  icon: item.icon,
                  iconSize: item.iconSize,
                  iconColor: item.iconColor,
                  label: item.label,
                  fontSize: item.fontSize,
                  fontColor: item.fontColor,
                  onPressed: (){
                    item.onPressed?.call();
                    secondaryFlyoutController.close();
                  },
                  onLongPress: (){
                    item.onLongPress?.call();
                    secondaryFlyoutController.close();
                  },
                  focusNode: item.focusNode,
                  autofocus: item.autofocus,
                  message: item.message,
                );
                return commandBarButton.build(context, CommandBarItemDisplayMode.inSecondary,);
              }
              else if (item is CommandBarDropdown){
                CommandBarDropdown commandBarDropdown = CommandBarDropdown(
                  icon: item.icon,
                  iconSize: item.iconSize,
                  iconColor: item.iconColor,
                  label: item.label,
                  fontSize: item.fontSize,
                  fontColor: item.fontColor,
                  onPressed: item.onPressed,
                  focusNode: item.focusNode,
                  items: item.items,
                  autofocus: item.autofocus,
                  message: item.message,
                  parentFlyoutController: secondaryFlyoutController,
                  isShowTrailing: item.isShowTrailing,
                  verticalOffset: item.verticalOffset,
                  horizontalOffset: item.horizontalOffset,
                  position: item.position,
                );
                return commandBarDropdown.build(context, CommandBarItemDisplayMode.inSecondary,);
              }
              return item.build(
                context,
                CommandBarItemDisplayMode.inSecondary,
              );
            }).toList(),
          ),
        ),
      );
    }

    late Widget w;
    switch (widget.overflowBehavior) {
      case CommandBarOverflowBehavior.scrolling:
        ///水平滚动小部件
        w = HorizontalScrollView(
          child: Row(
            mainAxisAlignment: widget.mainAxisAlignment,
            crossAxisAlignment: widget.crossAxisAlignment,
            children: [
              ...builtItems,
              if (overflowWidget != null) overflowWidget,
            ],
          ),
        );
        break;
      case CommandBarOverflowBehavior.noWrap:
        w = Row(
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          children: [
            ...builtItems,
            if (overflowWidget != null) overflowWidget,
          ],
        );
        break;
      case CommandBarOverflowBehavior.wrap:
        w = Wrap(
          alignment: _getWrapAlignment(),
          crossAxisAlignment: _getWrapCrossAlignment(),
          children: [
            ...builtItems,
            if (overflowWidget != null) overflowWidget,
          ],
        );
        break;
      case CommandBarOverflowBehavior.dynamicOverflow:
        assert(overflowWidget != null);
        ///如果没有空间显示它们，它将隐藏不适合的窗口小部件并在最后显示“溢出窗口小部件”
        w = DynamicOverflow(
          alignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          alwaysDisplayOverflowWidget: widget.secondaryItems.isNotEmpty,
          overflowWidget: overflowWidget!,
          overflowWidgetAlignment: widget.overflowItemAlignment,
          overflowChangedCallback: (hiddenItems) {
            setState(() {
              // indexes should always be valid
              assert(() {
                for (var i = 0; i < hiddenItems.length; i++) {
                  if (hiddenItems[i] < 0 ||
                      hiddenItems[i] >= widget.primaryItems.length) {
                    return false;
                  }
                }
                return true;
              }());
              dynamicallyHiddenPrimaryItems = hiddenItems;
            });
          },
          children: widget.mainAxisAlignment == MainAxisAlignment.start
              || widget.mainAxisAlignment == MainAxisAlignment.center
              || widget.mainAxisAlignment == MainAxisAlignment.end ?
          List.generate(builtItems.length, (index){
            return Padding(
              padding: EdgeInsets.only(
                right: index != builtItems.length - 1 ? 12 : 0,
              ),
              child: builtItems.toList()[index],
            );
          }).toList() :
          builtItems.toList(),
        );
        break;
      case CommandBarOverflowBehavior.clip:
        ///将项目保持在一行，并根据需要进行剪辑
        w = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            mainAxisAlignment: widget.mainAxisAlignment,
            crossAxisAlignment: widget.crossAxisAlignment,
            children: [
              ...builtItems,
              if (overflowWidget != null) overflowWidget,
            ],
          ),
        );
        break;
    }
    if (widget._isExpanded) {
      w = Row(children: [Expanded(child: w)]);
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compactBreakpointWidth == null) {
      final displayMode = widget.isCompact ?? false
          ? CommandBarItemDisplayMode.inPrimaryCompact
          : CommandBarItemDisplayMode.inPrimary;
      return _buildForPrimaryMode(context, displayMode);
    }
    else {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > widget.compactBreakpointWidth!) {
            return _buildForPrimaryMode(
                context, CommandBarItemDisplayMode.inPrimary);
          } else {
            return _buildForPrimaryMode(
                context, CommandBarItemDisplayMode.inPrimaryCompact);
          }
        },
      );
    }
  }
}

/// When a [CommandBarItem] is being built, indicates the visual context
/// in which the item is being built.
enum CommandBarItemDisplayMode {
  /// The item is displayed in the horizontal area (primary command area)
  /// of the command bar.
  ///
  /// The item should be rendered by wrapping content in a
  /// [CommandBarItemInPrimary] widget.
  inPrimary,

  /// The item is displayed in the horizontal area (primary command area)
  /// of the command bar, but it is requested that the item take up less
  /// horizontal space so that more items may fit without overflow.
  ///
  /// The item should be rendered by wrapping content in a
  /// [CommandBarItemInPrimary] widget.
  inPrimaryCompact,

  /// The item is displayed within the secondary command area (within a
  /// Flyout as a drop down of the "more" button).
  ///
  /// Normally you would want to render an item in this visual context as a
  /// [TappableListTile].
  inSecondary,
}

/// An individual control displayed within a [CommandBar]. Sub-class this
/// to build a new type of widget that appears inside of a command bar.
/// It knows how to build an appropriate widget for the given
/// [CommandBarItemDisplayMode] during build time.
abstract class CommandBarItem with Diagnosticable {
  final Key? key;

  const CommandBarItem({required this.key});

  /// Builds the final widget for this display mode for this item.
  /// Sub-classes implement this to build the widget that is appropriate
  /// for the given display mode.
  Widget build(BuildContext context, CommandBarItemDisplayMode displayMode);
}

/// Signature of function that can customize the widget returned by
/// a CommandBarItem built in the given display mode. Can be useful to
/// wrap the widget in a [Tooltip] etc.
typedef CommandBarItemWidgetBuilder = Widget Function(
    BuildContext context,
    CommandBarItemDisplayMode displayMode,
    Widget child,
    );

/// A widget to help render items that will appear on the primary
/// (horizontal) area of a command bar. This widget ensures that
/// the child widget has the proper margin so the item has the proper
/// minimum height and width expected of a control within the
/// primary command area of a [CommandBar].
class CommandBarItemInPrimary extends StatelessWidget {
  final Widget child;

  const CommandBarItemInPrimary({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 3.0),
      child: child,
    );
  }
}

/// Buttons are the most common control to put within a [CommandBar].
/// They are composed of an (optional) icon and an (optional) label.
class CommandBarButton extends CommandBarItem {
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final String? label;
  final double? fontSize;
  final Color? fontColor;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? message;

  const CommandBarButton({
    Key? key,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.label,
    this.fontSize,
    this.fontColor,
    this.onPressed,
    this.onLongPress,
    this.focusNode,
    this.autofocus = false,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, CommandBarItemDisplayMode displayMode) {

    double fontSize = this.fontSize ?? Theme.of(context).textTheme.bodySmall?.fontSize ?? 12;
    double iconSize = this.iconSize ?? (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) * 1.43;
    Color fontColor = this.fontColor ?? Theme.of(context).textTheme.bodySmall!.color!;
    Color iconColor = this.iconColor ?? Theme.of(context).textTheme.bodySmall!.color!;
    Widget widget;
    switch (displayMode) {
      case CommandBarItemDisplayMode.inPrimary:
      case CommandBarItemDisplayMode.inPrimaryCompact:
        final showIcon = icon != null;
        final showLabel = label != null && (displayMode == CommandBarItemDisplayMode.inPrimary || !showIcon);

        widget = TextButton(
          key: key,
          onPressed: onPressed,
          onLongPress: onLongPress,
          focusNode: focusNode,
          autofocus: autofocus,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcon)
                  Icon(
                    icon!,
                    size: iconSize,
                    color: (onPressed == null && onLongPress == null)
                        ? Theme.of(context).disabledColor
                        : iconColor
                  ),
                if (showIcon && showLabel) const SizedBox(width: 4),
                if (showLabel)
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: (onPressed == null && onLongPress == null)
                          ? Theme.of(context).disabledColor
                          : fontColor
                    ),
                  ),
              ],
            )
          ),
        );
        break;
      case CommandBarItemDisplayMode.inSecondary:
        widget = FlyoutListTile(
          key: key,
          onPressed: onPressed,
          focusNode: focusNode,
          autofocus: autofocus,
          icon: Icon(
            icon!,
            size: iconSize,
            color: (onPressed == null && onLongPress == null)
                ? Theme.of(context).disabledColor
                : Theme.of(context).textTheme.bodySmall!.color
          ),
          text: label == null ? const SizedBox.shrink() : Text(
            label!,
            style: TextStyle(
              fontSize: fontSize,
              color: (onPressed == null && onLongPress == null)
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).textTheme.bodySmall!.color
            ),
          ),
        );
        break;
    }
    if (message != null) {
      widget = Tooltip(
        message: message,
        child: widget,
      );
    }
    return widget;
  }
}


/// Buttons are the most common control to put within a [CommandBar].
/// They are composed of an (optional) icon and an (optional) label.
class CommandBarDropdown extends CommandBarItem {
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final String? label;
  final double? fontSize;
  final Color? fontColor;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget? onEnterWidget;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? message;
  final FlyoutController? parentFlyoutController;
  /// The items in the flyout. Must not be empty
  final List<MenuFlyoutItem> items;

  final bool isShowTrailing;
  final FlyoutPosition? position;
  final double? verticalOffset;
  final double? horizontalOffset;

  const CommandBarDropdown({
    Key? key,
    required this.items,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.label,
    this.fontSize,
    this.fontColor,
    this.onPressed,
    this.onLongPress,
    this.onEnterWidget,
    this.focusNode,
    this.autofocus = false,
    this.message,
    this.parentFlyoutController,
    this.isShowTrailing = true,
    this.verticalOffset,
    this.horizontalOffset,
    this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, CommandBarItemDisplayMode displayMode) {

    double fontSize = this.fontSize ?? Theme.of(context).textTheme.bodySmall?.fontSize ?? 12;
    double iconSize = this.iconSize ?? (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) * 1.43;
    Color fontColor = this.fontColor ?? Theme.of(context).textTheme.bodySmall!.color!;
    Color iconColor = this.iconColor ?? Theme.of(context).textTheme.bodySmall!.color!;

    Widget widget;
    switch (displayMode) {
      case CommandBarItemDisplayMode.inPrimary:
      case CommandBarItemDisplayMode.inPrimaryCompact:
        final showIcon = icon != null;
        final showLabel = label != null && (displayMode == CommandBarItemDisplayMode.inPrimary || !showIcon);

        widget = DropDownButton(
          leading: !showIcon ? null : Icon(
            icon!,
            size: iconSize,
            color: (onPressed == null && onLongPress == null && items.isEmpty)
                ? Theme.of(context).disabledColor
                : iconColor
          ),
          title: !showLabel ? null : Text(
            label!,
            style: TextStyle(
              fontSize: fontSize,
              color: (onPressed == null && onLongPress == null && items.isEmpty)
                  ? Theme.of(context).disabledColor
                  : fontColor
            ),
          ),
          trailing: isShowTrailing ? Icon(
              Icons.arrow_drop_down_sharp,
              size: iconSize,
              color: (onPressed == null && onLongPress == null && items.isEmpty)
                  ? Theme.of(context).disabledColor
                  : iconColor
          ) : null,
          items: items,
          placement: FlyoutPlacement.start,
          position: position ?? FlyoutPosition.below,
          verticalOffset: verticalOffset ?? 20,
          horizontalOffset: horizontalOffset ?? 10,
        );

        break;
      case CommandBarItemDisplayMode.inSecondary:
        final showIcon = icon != null;
        final showLabel = label != null;
        widget = DropDownButton(
          leading: !showIcon ? null : Icon(
              icon!,
              size: iconSize,
              color: (onPressed == null && onLongPress == null && items.isEmpty)
                  ? Theme.of(context).disabledColor
                  : iconColor
          ),
          title: !showLabel ? null : Expanded(
            child: Text(
              label!,
              style: TextStyle(
                fontSize: fontSize,
                color: (onPressed == null && onLongPress == null && items.isEmpty)
                    ? Theme.of(context).disabledColor
                    : fontColor
              ),
            )
          ),
          trailing: isShowTrailing ? Icon(
              Icons.arrow_right,
              size: iconSize,
              color: (onPressed == null && onLongPress == null && items.isEmpty)
                  ? Theme.of(context).disabledColor
                  : iconColor
          ) : null,
          items: items,
          verticalOffset: 70,
          position: FlyoutPosition.side,
          placement: FlyoutPlacement.end,
          parentFlyoutController: parentFlyoutController,
        );
        break;
    }
    if (message != null) {
      widget = Tooltip(
        message: message,
        child: widget,
      );
    }
    return widget;
  }
}


/// Separators for grouping command bar items. Set the color property to
/// [Colors.transparent] to render the separator as space. Uses a [Divider]
/// under the hood, consequently uses the closest [DividerThemeData].
///
/// See also:
///   * [CommandBar], which is a collection of [CommandBarItem]s.
///   * [CommandBarButton], an item for a button with an icon and/or label.
class CommandBarSeparator extends CommandBarItem {
  /// Creates a command bar item separator.
  const CommandBarSeparator({
    Key? key,
    this.heightOfVertical = 24,
    this.widthOfVertical = 50,
  }) : super(key: key);

  final double heightOfVertical;
  final double widthOfVertical;

  @override
  Widget build(BuildContext context, CommandBarItemDisplayMode displayMode) {
    switch (displayMode) {
      case CommandBarItemDisplayMode.inPrimary:
      case CommandBarItemDisplayMode.inPrimaryCompact:
        return Container(
          height: heightOfVertical,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: const VerticalDivider(indent: 0, endIndent: 0,),
        );
      case CommandBarItemDisplayMode.inSecondary:
        return Container(
          width: widthOfVertical,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: const Divider(indent: 0, endIndent: 0,),
        );
    }
  }
}
