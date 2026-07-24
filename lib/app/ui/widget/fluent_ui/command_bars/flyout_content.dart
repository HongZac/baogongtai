
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/color_utils.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/popup.dart';
import 'package:desktop/app/ui/widget/fluent_ui/mine_hover_button.dart';
import 'package:flutter/material.dart';

/// The content of the flyout.
///
/// See also:
///
///   * [Flyout], which is a light dismiss container that can show arbitrary UI
///     as its content
///   * [FlyoutListTile],
class FlyoutContent extends StatelessWidget {
  /// Creates a flyout content
  const FlyoutContent({
    Key? key,
    required this.child,
    this.surfaceTintColor,
    this.padding = const EdgeInsets.all(8.0),
    this.elevation = 8,
    this.shadowColor,
    this.constraints,
  }) : super(key: key);

  final Widget child;
  /// The background color of the box.
  final Color? surfaceTintColor;
  /// Empty space to inscribe around the [child]
  final EdgeInsetsGeometry padding;
  /// The z-coordinate relative to the box at which to place this physical object.
  final double elevation;
  final Color? shadowColor;
  /// Additional constraints to apply to the child.
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      surfaceTintColor: surfaceTintColor, ///在“材质设计3”中，某些组件将使用“表面着色”颜色覆盖，并将不透明度应用于其基础颜色，以表示其已升高
      shadowColor: shadowColor,
      borderRadius: const BorderRadius.all(Radius.circular(2)),
      child: Container(
        constraints: constraints,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}


class FlyoutListTile extends StatelessWidget {
  /// Creates a flyout list tile.
  const FlyoutListTile({
    Key? key,
    this.onPressed,
    this.icon,
    required this.text,
    this.trailing,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.selected = false,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget text;
  final Widget? trailing;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final size = ContentSizeInfo.of(context).size;
    return HoverButton(
      key: key,
      onPressed: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      margin: EdgeInsets.zero,
      builder: (context, states) {
        if (selected) {
          states = {ButtonStates.hovering};
        }
        Widget content = Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                decoration: BoxDecoration(
                  color: ColorUtils.getUnCheckedInputColor(
                    states,
                    transparentWhenNone: true,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) icon!,
                    if (icon != null) const SizedBox(width: 4),
                    Flexible(
                      fit: size.isEmpty ? FlexFit.loose : FlexFit.tight,
                      child: text,
                    ),
                    if (trailing != null) trailing!
                  ]
                ),
              ),
              if (selected)
                Positioned(
                  top: 0,
                  bottom: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    width: 2.5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: trailing  ?? const SizedBox.shrink(),
                  ),
                ),
            ]
        );
        return content;
      },
    );
  }
}


