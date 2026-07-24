import 'package:flutter/material.dart';


class BlinkWidget extends StatefulWidget{

  final bool isBlink;
  final int rate;
  final BoxDecoration? decoration;
  final Widget child;
  final Color? blinkColor;

  const BlinkWidget({
    super.key,
    required this.isBlink,
    this.rate = 500,
    required this.child,
    this.decoration,
    this.blinkColor,
  });

  @override
  State<StatefulWidget> createState() => BlinkWidgetState();

}
class BlinkWidgetState extends State<BlinkWidget> with SingleTickerProviderStateMixin {

  late final AnimationController animationController;
  late final Animation animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: widget.rate));
    animationController.addListener(() => setState(() {}));
    animation = ColorTween(begin: Colors.transparent, end: widget.blinkColor ?? Colors.red)
        .animate(CurvedAnimation(parent: animationController, curve: Curves.easeInCubic));
    onStatusChanged(widget.isBlink);
  }

  @override
  void didUpdateWidget(covariant BlinkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rate != oldWidget.rate){
      animationController.stop();
      animationController.duration = Duration(milliseconds: widget.rate);
      onStatusChanged(widget.isBlink);
    }
    else if (widget.isBlink != oldWidget.isBlink){
      onStatusChanged(widget.isBlink);
    }
  }

  void onStatusChanged(bool isBlink) {
    if (isBlink){
      animationController.repeat(reverse: true);
    }
    else {
      animationController.stop();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (widget.isBlink){
      color = animation.value;
    }
    return Container(
      decoration: widget.decoration != null ? widget.decoration!.copyWith(
        color: color
      ) : BoxDecoration(color: color),
      child: widget.child
    );
  }

}