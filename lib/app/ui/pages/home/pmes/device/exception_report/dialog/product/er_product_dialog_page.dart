import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/exception_report/dialog/product/er_product_dialog_controller.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../exception_report_base_dialog_page.dart';


///工作流程-产品异常报告弹出窗体
class ERProductDialogPage extends ExceptionReportBaseDialogPage<ERProductDialogController> {

  @override
  Widget contentWidget(BuildContext context, ERProductDialogController _) {
    return Column(
      children: [
        ///产品信息
        Row(
          children: [
            Expanded(
              child: dataReportItem1(
                title: '产品编号',
                customizeContent: TextField(
                  controller: _.invCodeTC,
                  maxLines: 1, readOnly: true,
                  style: Theme.of(Get.context!).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12,),
            Expanded(
              child: dataReportItem1(
                title: '产品名称',
                customizeContent: TextField(
                  controller: _.invNameTC,
                  maxLines: 1, readOnly: true,
                  style: Theme.of(Get.context!).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
                  ),
                ),
              ),
            )
          ],
        ),
        ///人员、班次
        Row(
          children: [
            Expanded(
              child: dataReportItem1(
                  title: '发现人员',
                  customizeContent: PickerInputWidget(
                    adapter: _.personAdapter,
                    pickerChoiceType: PickerChoiceType.chip,
                    onTap: (List<PickerDataModel> selectList) {
                      controller.psnOnChanged(selectList);
                    },
                  )
              ),
            ),
            const SizedBox(width: 12,),
            Expanded(
              child: dataReportItem1(
                  title: '班次',
                  customizeContent: PickerInputWidget(
                    adapter: _.teamAdapter,
                    pickerChoiceType: PickerChoiceType.chip,
                    onTap: (List<PickerDataModel> selectList) {
                      if (selectList.isNotEmpty){
                        controller.teamOnChanged(selectList[0]);
                      }
                      else {
                        controller.teamOnChanged(PickerDataModel());
                      }
                    },
                  )
              ),
            )
          ],
        ),
        ///数量、异常描述
        Row(
          children: [
            Expanded(
              child: dataReportItem1(
                  title: '数量',
                  customizeContent: TextField(
                    controller: _.qtyTC,
                    focusNode: _.qtyFN,
                    maxLines: 1,
                    style: Theme.of(Get.context!).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: '请输入',
                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                      ),
                      suffixIcon: _.qtyTC.text.isEmpty ? null : MineIconButton(
                        icon: Icons.cancel,
                        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        tooltip: '清空',
                        onPressed: () {
                          _.qtyTC.text = '';
                          controller.update();
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
                    ),
                  )
              ),
            ),
            const SizedBox(width: 12,),
            Expanded(
              child: dataReportItem1(
                  title: '异常描述',
                  customizeContent: TextField(
                    controller: _.descTC,
                    focusNode: _.descFN,
                    maxLines: 1,
                    style: Theme.of(Get.context!).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: '请输入',
                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                      ),
                      suffixIcon: _.descTC.text.isEmpty ? null : MineIconButton(
                        icon: Icons.cancel,
                        iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                        tooltip: '清空',
                        onPressed: () {
                          _.descTC.text = '';
                          controller.update();
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
                    ),
                  )
              ),
            )
          ],
        ),
        ///次品原因
        Expanded(
          child: CardWidget(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '问题类型选择',
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _.comDefectListController,
                    padding: const EdgeInsets.all(6),
                    child: Wrap(
                      runSpacing: 6, spacing: 6,
                      children: List.generate(_.comDefectList.length, (index) {
                        TreeModel item = _.comDefectList[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              controller.comDefectOnChanged(item);
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              width: 150, height: 60,
                              padding: const EdgeInsets.all(4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: item.isChoice
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : null,
                                border: item.isChoice ? null : Border.all(
                                    color: Theme.of(context).colorScheme.outline,
                                    width: 1
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FittedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (item.isChoice)
                                      Icon(
                                        Icons.done,
                                        size: Theme.of(context).textTheme.bodySmall!.fontSize! * 1.43,
                                      ),
                                    if (item.isChoice)
                                      const SizedBox(width: 4,),
                                    Text(
                                      '${(item.text ?? '').isNotEmpty ? item.text : ' '}',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          )
                        );
                      }).toList(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),

      ],
    );
  }

}