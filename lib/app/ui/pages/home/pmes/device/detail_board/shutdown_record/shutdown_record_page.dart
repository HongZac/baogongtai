import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/shutdown_record/shutdown_record_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///停机记录 670003
class ShutdownRecordPage extends BaseFormWithPageDataPage<ShutdownRecordController, MoProcessModel>{

  @override
  Widget headWidget(BuildContext context, ShutdownRecordController _) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _.dateFilterInputWidget(context),
        ],
      ),
    );
  }

  @override
  Widget dataItem(BuildContext context, ShutdownRecordController _, MoProcessModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 16,),
                    Expanded(
                      child: Text(
                        '${(item.processTypeName ?? '').isNotEmpty ? item.processTypeName! : '--'}',
                            //'${(item.description ?? '').isNotEmpty ? '【${item.description!}】' : ''}',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    const SizedBox(width: 8,),

                    _.commandBarWidget(
                      context,
                      commandBarList: _.commandBarList,
                      item: item,
                      btnPadding: kIsWeb || GetPlatform.isWindows
                          ? const EdgeInsets.symmetric(vertical: 18, horizontal: 8)
                          : const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      isExpanded: item.isExpanded,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 4),
                  constraints: BoxConstraints(
                    minHeight: 40,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.end,
                    runSpacing: 4, spacing: 6,
                    children: _.getFieldList(
                      context,
                      infoFormList: _.shutdownRecordListInfoFormListMap[0] ?? [],
                      item: item,
                      customBuilder: (String keyName, ICloneable item){
                        item as MoProcessModel;
                        return customField(keyName, item);
                      },
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: !item.isExpanded ?
                  const SizedBox.shrink() :
                  Wrap(
                    runSpacing: 4, spacing: 6,
                    children: _.getFieldList(
                      context,
                      infoFormList: _.shutdownRecordListInfoFormListMap[1] ?? [],
                      item: item,
                      customBuilder: (String keyName, ICloneable item){
                        item as MoProcessModel;
                        return customField(keyName, item);
                      },
                    ),
                  ),
                  crossFadeState: item.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic>? customField(String keyName, MoProcessModel item){
    switch (keyName){
      case 'ProcessClass':
        return {
          'content': item.processClass == 1
              ? '生产中'
              : item.processClass == 2
              ? '待机'
              : item.processClass == 4
              ? '停机'
              : item.processClass == 8
              ? '关机'
              : '',
        };
      case 'StopTime':
        return {
          'content': item.processTime == null || item.overTime == null
              ? ''
              : NumFormatUtil.timeFormatConverter(item.overTime!.difference(item.processTime!).inSeconds),
        };
    }
    return null;
  }

}