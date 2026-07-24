import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';


class DragToMoveAreaWithoutDoubleTap extends StatelessWidget {
  final Widget child;
  final bool isNeedDoubleTap;

  const DragToMoveAreaWithoutDoubleTap({
    Key? key,
    required this.child,
    this.isNeedDoubleTap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isNeedDoubleTap){
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          windowManager.startDragging();
        },
        child: child,
      );
    }
    else {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          windowManager.startDragging();
        },
        onDoubleTap: () async {
          if (!isNeedDoubleTap){
            return;
          }
          bool isMaximized = await windowManager.isMaximized();
          if (!isMaximized) {
            windowManager.maximize();
          } else {
            windowManager.unmaximize();
          }
        },
        child: child,
      );
    }

  }
}
