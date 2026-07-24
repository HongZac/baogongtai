import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MineScrollBar extends StatefulWidget{

  final ScrollForType scrollForType;
  final ValueChanged<Offset>? onBack;
  final Axis scrollDirection;

  const MineScrollBar({
    super.key,
    this.scrollForType = ScrollForType.sfPdfViewer,
    this.onBack,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<StatefulWidget> createState() => MineScrollBarState();

}

class MineScrollBarState extends State<MineScrollBar>{

  double alignmentX = -1;
  double? width;
  double? globalStartX;
  double? globalEndX;
  double? amongX;

  double alignmentY = -1;
  double? height;
  double? globalStartY;
  double? globalEndY;
  double? amongY;


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints trackConstraints){
        if (widget.scrollDirection == Axis.vertical){ ///垂直滚动条
          return Container(
              width: 32,
              alignment: Alignment(0, alignmentY),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: Theme.of(context).colorScheme.onInverseSurface,
              child: GestureDetector(
                onVerticalDragUpdate: (DragUpdateDetails details){
                  globalStartY ??= details.globalPosition.dy - details.localPosition.dy;
                  if (height != Get.height){
                    height = Get.height;
                    globalEndY = globalStartY! + trackConstraints.maxHeight;
                    amongY = globalStartY! + trackConstraints.maxHeight / 2;
                  }
                  if (globalStartY! > details.globalPosition.dy || details.globalPosition.dy /trackConstraints.maxHeight > 1){
                    return;
                  }
                  if (details.globalPosition.dy < amongY!){
                    alignmentY = (details.globalPosition.dy - amongY!) / (trackConstraints.maxHeight / 2);
                  }
                  else {
                    alignmentY = details.globalPosition.dy / (trackConstraints.maxHeight / 2) - 1;
                  }
                  setState(() {  });
                  if (widget.scrollForType == ScrollForType.sfPdfViewer){
                    widget.onBack?.call(details.globalPosition);
                  }
                },
                child: Container(
                  width: 32, height: 150,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(40)
                  ),
                ),
              )
          );
        }
        else { ///水平滚动条
          return Container(
            height: 32,
            alignment: Alignment(alignmentX, 0),
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: Theme.of(context).colorScheme.onInverseSurface,
            child: GestureDetector(
              onHorizontalDragUpdate: (DragUpdateDetails details){
                globalStartX ??= details.globalPosition.dx - details.localPosition.dx;
                if (width != Get.width){
                  width = Get.width;
                  globalEndX = globalStartX! + trackConstraints.maxWidth;
                  amongX = globalStartX! + trackConstraints.maxWidth / 2;
                }
                if (globalStartX! > details.globalPosition.dx || details.globalPosition.dx /trackConstraints.maxWidth > 1){
                  return;
                }
                if (details.globalPosition.dx < amongX!){
                  alignmentX = (details.globalPosition.dx - amongX!) / (trackConstraints.maxWidth / 2);
                }
                else {
                  alignmentX = details.globalPosition.dx / (trackConstraints.maxWidth / 2) - 1;
                }
                setState(() {  });
                if (widget.scrollForType == ScrollForType.sfPdfViewer){
                  widget.onBack?.call(details.globalPosition);
                }
              },
              child: Container(
                width: 150, height: 32,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(40)
                ),
              ),
            )
          );
        }
      },
    );
  }

}

enum ScrollForType{
  sfPdfViewer,
}