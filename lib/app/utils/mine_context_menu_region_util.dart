import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MineContextMenuRegionUtil {
  static void showContextMenu(BuildContext context, Widget contextMenu) {
    // calculate widget position on screen
    context.contextMenuOverlay.show(contextMenu);
  }

  static Widget cardBuilderWidget(BuildContext cardContext, children){
    return Material(
      elevation: 4,
      surfaceTintColor: Theme.of(Get.context!).colorScheme.tertiary, //surfaceTint,
      borderRadius: BorderRadius.circular(2),
      child: Container(
        constraints: const BoxConstraints(minWidth: 70),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        )
      ),
    );
  }

  static ContextMenuButtonStyle contextMenuButtonStyle(BuildContext context){
    return ContextMenuButtonStyle(
      fgColor: Theme.of(context).textTheme.labelMedium!.color,
      hoverFgColor: Theme.of(context).textTheme.labelMedium!.color,
      bgColor: Colors.transparent,
      hoverBgColor: Theme.of(context).hoverColor,
      textStyle: Theme.of(context).textTheme.labelMedium,
    );
  }

}