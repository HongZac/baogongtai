import 'package:flutter/material.dart';

enum CardType{
  elevated, filled, outlined
}

class CardWidget extends StatefulWidget{

  final CardType cardType;

  ///面板内容
  final Widget content;

  final double minHeightOfContent;

  final EdgeInsetsGeometry? margin;

  ///是否在网格布局(flutter_staggered_grid_view)中
  final bool isStaggered;

  const CardWidget({
  super.key,
  this.cardType = CardType.elevated,
  required this.content,
  this.minHeightOfContent = 120,
  this.isStaggered = false,
  this.margin = const EdgeInsets.all(4.0),
  });

  @override
  State<StatefulWidget> createState() => CardWidgetState();
}

class CardWidgetState extends State<CardWidget>{

  ///内容是否已展开
  bool isDropDown = true;
  double? heightOfContent;
  BuildContext? contentContext;
  final GlobalKey key = GlobalKey(debugLabel: 'card');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.cardType){
      case CardType.elevated:
        return Card(
          clipBehavior: Clip.none,
          elevation: 1,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          margin: widget.margin,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4))
          ),
          child: widget.content,
        );
      case CardType.filled:
        return Card(
          elevation: 4,
          shadowColor: Colors.transparent,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          margin: widget.margin,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4))
          ),
          child: widget.content,
        );
      case CardType.outlined:
        return Card(
          elevation: 0,
          margin: widget.margin,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: widget.content,
        );
    }
  }

}