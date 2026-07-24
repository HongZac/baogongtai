import 'package:flutter/material.dart';

import 'flyout.dart';
import 'flyout_content.dart';

/// Menu flyouts are used in menu and context menu scenarios to display a list
/// of commands or options when requested by the user. A menu flyout shows a
/// single, inline, top-level menu that can have menu items and sub-menus.
///
/// ![MenuFlyout](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/contextmenu_rs2_icons.png)
///
/// See also:
///
///  * [Flyout]
///  * [FlyoutContent]
class MenuFlyout extends StatelessWidget {
  /// Creates a menu flyout.
  const MenuFlyout({
    Key? key,
    this.items = const [],
    this.surfaceTintColor,
    this.shape,
    this.shadowColor,
    this.elevation = 8.0,
    this.constraints,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
  }) : super(key: key);

  final List<MenuFlyoutItemInterface> items;

  /// The background color of the box.
  final Color? surfaceTintColor;

  /// The shape to fill the [color] of the box.
  final ShapeBorder? shape;

  /// The shadow color.
  final Color? shadowColor;

  /// The z-coordinate relative to the box at which to place this physical
  /// object.
  final double elevation;

  /// Additional constraints to apply to the child.
  final BoxConstraints? constraints;

  /// The padding applied the [items], with correct handling when scrollable
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final bool hasLeading = () {
      try {
        items.whereType<MenuFlyoutItem>().firstWhere((i) => i.trailing != null);
        return true;
      } catch (e) {
        return false;
      }
    }();
    return FlyoutContent(
      surfaceTintColor: surfaceTintColor,
      constraints: constraints,
      elevation: elevation,
      shadowColor: shadowColor,
      padding: EdgeInsets.zero,
      child: ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: items.map<Widget>((item) {
              if (item is MenuFlyoutItem) item._useIconPlaceholder = hasLeading;
              return KeyedSubtree(
                key: item.key,
                child: item.build(context),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

abstract class MenuFlyoutItemInterface {
  final Key? key;

  const MenuFlyoutItemInterface({this.key});

  Widget build(BuildContext context);
}

class MenuFlyoutItem extends MenuFlyoutItemInterface {
  MenuFlyoutItem({
    Key? key,
    this.icon,
    this.iconSize,
    this.label,
    this.field,
    this.semanticLabel,
    this.fontSize,
    this.trailing,
    required this.onPressed,
    this.selected = false,
    this.maxWidth = 120,
  }) : super(key: key);

  final IconData? icon;
  final double? iconSize;
  final String? label;
  final double? fontSize;
  final IconData? trailing;
  final VoidCallback? onPressed;
  final bool selected;
  final String? field;
  final String? semanticLabel;
  final double maxWidth;

  bool _useIconPlaceholder = false;

  @override
  Widget build(BuildContext context) {
    double fontSize = this.fontSize ?? Theme.of(context).textTheme.bodySmall?.fontSize ?? 12;
    double iconSize = this.iconSize ?? (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) * 1.3;
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: FlyoutListTile(
        selected: selected,
        icon: icon == null ? null : Icon(
            icon!,
            size: iconSize,
            color: onPressed == null
                ? Theme.of(context).disabledColor
                : Theme.of(context).textTheme.bodySmall!.color
        ),
        text: label == null ? const SizedBox.shrink() : Text(
          label!,
          style: TextStyle(
              fontSize: fontSize,
              color: onPressed == null
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).textTheme.bodySmall!.color
          ),
        ),
        trailing: trailing == null ? null : Icon(
            trailing!,
            size: iconSize,
            color: onPressed == null
                ? Theme.of(context).disabledColor
                : Theme.of(context).textTheme.bodySmall!.color
        ),
        onPressed: onPressed,
      ),
    );
  }
}


