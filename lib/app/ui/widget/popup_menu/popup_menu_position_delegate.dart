
import 'dart:math' as math;
import 'package:flutter/material.dart' hide PopupMenuPosition;



///菜单现在默认是水平顶端对齐方式，水平是居中
enum PopupMenuPosition { TOP, BOTTOM,LEFT, RIGHT}



/// A delegate for computing the layout of a PopupMenu to be displayed above or
/// below a target specified in the global coordinate system.
class PopupMenuPositionDelegate extends SingleChildLayoutDelegate {
  /// Creates a delegate for computing the layout of a tooltip.
  ///
  /// The arguments must not be null.
  PopupMenuPositionDelegate({
    required this.target,
    this.verticalOffset =0,
    required this.horizontalOffset ,
    required this.position,
    required this.boxSize
  });

  /// 父级对象的大小，是PopupMenu下的child对象
  final Size boxSize;

  /// 父级对象的中心点位置;
  /// The offset of the target the tooltip is positioned near in the global
  /// coordinate system.
  final Offset target;

  /// The amount of vertical distance between the target and the displayed
  /// tooltip.
  final double verticalOffset;

  ///
  final double horizontalOffset;

  /// 弹出菜单的显示位置
  final PopupMenuPosition position;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return _positionDependentBox(
      size: size,
      childSize: childSize,
      target: target,
      verticalOffset: verticalOffset,
      position: position,
    );
  }

  Offset _positionDependentBox({
    required Size size,
    required Size childSize,
    required Offset target,
    required PopupMenuPosition position,
    double verticalOffset = 0.0,
    double margin = 10.0,
  }) {

    /// VERTICAL DIRECTION 测试垂直方向是否可以有空单足够显示
    final bool fitsBelow = target.dy + verticalOffset + childSize.height <= size.height - margin;
    final bool fitsAbove = target.dy - verticalOffset - childSize.height >= margin;

    double y;

    /// HORIZONTAL DIRECTION
    double x;

    switch(position){
      case PopupMenuPosition.BOTTOM:
        x = (size.width - childSize.width) / 2.0;
        y = math.min(target.dy + verticalOffset, size.height - margin);
        break;
      case PopupMenuPosition.TOP:
        x = (size.width - childSize.width) / 2.0;
        y = math.max(target.dy - verticalOffset - childSize.height, margin);
        break;

      case PopupMenuPosition.RIGHT :
      default:
        x = target.dx + horizontalOffset + (boxSize.width / 2.0);
        y = target.dy - verticalOffset - (boxSize.height /2);

        break;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(PopupMenuPositionDelegate oldDelegate) {
    return target != oldDelegate.target
        || verticalOffset != oldDelegate.verticalOffset
        || position != oldDelegate.position;
  }
}
