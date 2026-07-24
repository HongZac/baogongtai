import 'package:desktop/app/ui/widget/fluent_ui/command_bars/flyout.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/flyout_controller.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


const double _kVerticalOffset = 20.0;
const double _kHorizontalOffset = 10;
const Widget _kDefaultDropdownButtonTrailing = Icon(
  Icons.arrow_drop_down_sharp,
  size: 16,
);

typedef DropDownButtonBuilder = Widget Function(
  BuildContext context,
  VoidCallback? onOpen,
);

/// A `DropDownButton` is a button that shows a chevron as a visual indicator that
/// it has an attached flyout that contains more options. It has the same
/// behavior as a standard Button control with a flyout; only the appearance is
/// different.
///
/// ![DropDownButton Showcase](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/drop-down-button-align.png)
///
/// See also:
///
///   * [Flyout], a light dismiss container that can show arbitrary UI as its
///  content. Used to back this button
///   * [ComboBox], a list of items that a user can select from
///   * <https://docs.microsoft.com/en-us/windows/apps/design/controls/buttons#create-a-drop-down-button>

class DropDownButton extends StatefulWidget {
  /// Creates a dropdown button.
  const DropDownButton({
    Key? key,
    this.buttonBuilder,
    required this.items,
    this.leading,
    this.title,
    this.trailing,
    this.verticalOffset = _kVerticalOffset,
    this.horizontalOffset = _kHorizontalOffset,
    this.closeAfterClick = true,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
    this.buttonStyle,
    this.placement = FlyoutPlacement.center,
    this.openMode = FlyoutOpenMode.none,
    this.position = FlyoutPosition.below,
    this.menuShape,
    this.surfaceTintColor,
    this.onOpen,
    this.onClose,
    this.parentFlyoutController,
  })  : assert(items.length > 0, 'You must provide at least one item'),
        super(key: key);

  /// A builder for the button. If null, a [Button] with [leading], [title] and
  /// [trailing] is used.
  ///
  /// If [disabled] is true, [DropDownButtonBuilder.onOpen] will be null
  final DropDownButtonBuilder? buttonBuilder;

  /// The content at the start of this widget.
  ///
  /// Usually an [Icon]
  final Widget? leading;

  /// Title show a content at the center of this widget.
  ///
  /// Usually a [Text]
  final Widget? title;

  /// Trailing show a content at the right of this widget.
  ///
  /// If null, a chevron_down is displayed.
  final Widget? trailing;

  /// The space between the button and the flyout.
  ///
  /// 20.0 is used by default
  final double verticalOffset;

  final double horizontalOffset;

  /// The items in the flyout. Must not be empty
  final List<MenuFlyoutItem> items;

  /// Whether the flyout will be closed after an item is tapped.
  ///
  /// Defaults to `true`
  final bool closeAfterClick;

  /// If `true`, the button won't be clickable.
  final bool disabled;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Customizes the button's appearance.
  @Deprecated('buttonStyle was deprecated in 3.11.1. Use buttonBuilder instead')
  final ButtonStyle? buttonStyle;

  final FlyoutOpenMode openMode;

  /// The placement of the flyout.
  ///
  /// [FlyoutPlacement.center] is used by default
  final FlyoutPlacement placement;

  final FlyoutPosition position;

  /// The menu shape
  final ShapeBorder? menuShape;

  /// The menu color. If null, [ThemeData.menuColor] is used
  final Color? surfaceTintColor;

  /// Called when the flyout is opened
  ///
  /// See also:
  ///
  ///  * [Flyout.onClose]
  final VoidCallback? onOpen;

  /// Called when the flyout is closed
  ///
  /// See also:
  ///
  ///  * [Flyout.onClose]
  final VoidCallback? onClose;

  final FlyoutController? parentFlyoutController;

  @override
  State<DropDownButton> createState() => _DropDownButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<MenuFlyoutItemInterface>('items', items))
      ..add(DoubleProperty(
        'verticalOffset',
        verticalOffset,
        defaultValue: _kVerticalOffset,
      ))
      ..add(FlagProperty(
        'close after click',
        value: closeAfterClick,
        defaultValue: false,
        ifFalse: 'do not close after click',
      ))
      ..add(EnumProperty<FlyoutPlacement>('placement', placement))
      ..add(DiagnosticsProperty<ShapeBorder>('menu shape', menuShape))
      ..add(ColorProperty('menu color', surfaceTintColor));
  }
}

class _DropDownButtonState extends State<DropDownButton> {
  final flyoutController = FlyoutController();

  final flyoutStateKey = GlobalKey<FlyoutState>();

  @override
  void dispose() {
    flyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    final buttonChildren = [
      if (widget.leading != null) widget.leading!,
      if (widget.leading != null && widget.title != null) const SizedBox(width: 4),
      if (widget.title != null) widget.title!,
      widget.trailing ?? _kDefaultDropdownButtonTrailing,
    ];

    return Flyout(
      key: flyoutStateKey,
      openMode: widget.openMode, ///弹出框打开方式
      placement: widget.placement,
      position: widget.position,
      verticalOffset: widget.verticalOffset,
      horizontalOffset: widget.horizontalOffset,
      controller: flyoutController,
      onOpen: widget.onOpen,
      onClose: widget.onClose,
      child: Builder(builder: (context) {
        return widget.buttonBuilder?.call(
          context,
          widget.disabled ? null : flyoutController.open,
        ) ??
        TextButton(
          onPressed: widget.disabled ? null : flyoutController.open,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          child: Padding(
            padding: const EdgeInsets.only(left: 6, top: 6, bottom: 6, right: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: buttonChildren,
            )
          ),
        );
      }),
      content: (context) {
        return MenuFlyout(
          surfaceTintColor: widget.surfaceTintColor,
          shape: widget.menuShape,
          items: widget.items.map((item) {
            MenuFlyoutItem menuFlyoutItem = MenuFlyoutItem(
              icon: item.icon,
              iconSize: item.iconSize,
              label: item.label,
              fontSize: item.fontSize,
              trailing: item.trailing,
              selected: item.selected,
              maxWidth: item.maxWidth,
              onPressed: (){
                item.onPressed?.call();
                flyoutStateKey.currentState!.controller.close();
                widget.parentFlyoutController?.close();
              },
            );
            return menuFlyoutItem;
          }).toList(),
        );
      },
    );
  }
}