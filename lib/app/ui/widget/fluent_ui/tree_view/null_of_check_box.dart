import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class NullOfCheckbox extends StatelessWidget {
  const NullOfCheckbox({
    Key? key,
    required this.checked,
    required this.onChanged,
    this.content,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.margin,
    this.padding,
    this.size = 20,
    this.iconSize = 14
  }) : super(key: key);

  final bool? checked;
  final ValueChanged<bool?>? onChanged;
  final Widget? content;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double size;
  final double iconSize;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('checked', value: checked, ifFalse: 'unchecked'))
      ..add(ObjectFlagProperty('onChanged', onChanged, ifNull: 'disabled'))
      ..add(StringProperty('semanticLabel', semanticLabel))
      ..add(DiagnosticsProperty<FocusNode>('focusNode', focusNode))
      ..add(FlagProperty(
        'autofocus',
        value: autofocus,
        defaultValue: false,
        ifFalse: 'manual focus',
      ));
  }

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedContainer(
      alignment: Alignment.center,
      duration: const Duration(milliseconds: 150),
      curve: Curves.linear,
      padding: padding,
      width: size,
      height: size,
      decoration: checked == null ?
      BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ) :
      checked! ?
      BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ) :
      BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Theme.of(context).colorScheme.primary,
          width: 0.5
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: checked == null ?
      Icon(Icons.remove, color: Colors.white, size: iconSize,) :
      checked! ?
      Icon(Icons.check, color: Colors.white, size: iconSize,) :
      null,
    );
    if (content != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(width: 6.0),
          content!,
        ]
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          focusNode: focusNode,
          onTap: (){
            onChanged?.call(checked == null ? null : !(checked!));
          },
          child: child,
        ),
      ),
    );
  }
}