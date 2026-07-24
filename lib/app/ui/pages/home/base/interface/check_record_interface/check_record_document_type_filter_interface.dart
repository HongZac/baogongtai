

import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';

///次品列表-次品单据类型（次品记录 OR 材料不良记录）切换功能接口
mixin CheckRecordDocumentTypeFilterInterface {

  ///次品列表-次品单据类型（次品记录 OR 材料不良记录）
  int checkRecordDocumentTypeIndex = AppConfig.checkRecordDocumentTypeIndex;


  Future<void> checkRecordDocumentTypeIndexOnChanged(int index) async {
    checkRecordDocumentTypeIndex = index;
  }

  Widget checkRecordDocumentTypeFilterMenuBarWidget(BuildContext context){
    return Container(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _itemBtn(
            context,
            isStart: true,
            isSelected: checkRecordDocumentTypeIndex == 0,
            onTap: () async {
              await checkRecordDocumentTypeIndexOnChanged(0);
            },
            title: '次品记录',
          ),
          VerticalDivider(
            indent: 0, endIndent: 0,
            color: checkRecordDocumentTypeIndex == 0
                || checkRecordDocumentTypeIndex == 1
                ? Theme.of(context).colorScheme.inversePrimary
                : Theme.of(context).colorScheme.outline,
          ),
          _itemBtn(
            context,
            isEnd: true,
            isSelected: checkRecordDocumentTypeIndex == 1,
            onTap: () async {
              await checkRecordDocumentTypeIndexOnChanged(1);
            },
            title: '材料不良',
          ),
        ],
      ),
    );
  }

  Widget _itemBtn(BuildContext context, {
    VoidCallback? onTap,
    required String title,
    bool isStart = false,
    bool isEnd = false,
    bool isSelected = false,
  }){
    BorderSide borderSide = BorderSide(
      color: isSelected 
          ? Theme.of(context).colorScheme.inversePrimary
          : Theme.of(context).colorScheme.outline,
    );
    return InkWell(
      onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: isStart ? const Radius.circular(90) : Radius.zero,
          bottomLeft: isStart ? const Radius.circular(90) : Radius.zero,
          topRight: isEnd ? const Radius.circular(90) : Radius.zero,
          bottomRight: isEnd ? const Radius.circular(90) : Radius.zero,
        ),
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            top: borderSide,
            bottom: borderSide,
            left: isStart ? borderSide : BorderSide.none,
            right: isEnd ? borderSide : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isStart ? const Radius.circular(90) : Radius.zero,
            bottomLeft: isStart ? const Radius.circular(90) : Radius.zero,
            topRight: isEnd ? const Radius.circular(90) : Radius.zero,
            bottomRight: isEnd ? const Radius.circular(90) : Radius.zero,
          ),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : null,
          ),
        ),
      )
    );
  }

}