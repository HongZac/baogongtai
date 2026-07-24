import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/ui/widget/prefix_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../exception_report_base_dialog_page.dart';
import 'er_mould_dialog_controller.dart';


///工作流程-模具异常报告弹出窗体
class ERMouldDialogPage extends ExceptionReportBaseDialogPage<ERMouldDialogController>{

  @override
  Widget contentWidget(BuildContext context, ERMouldDialogController _){
    return Column(
      children: [
        ///模具信息
        Row(
          children: [
            Expanded(
              child: dataReportItem1(
                title: '模具编号',
                customizeContent: TextField(
                  controller: _.mouldCodeTC,
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
                title: '模具名称',
                customizeContent: TextField(
                  controller: _.mouldNameTC,
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
        ///人员、期望日期
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
                  title: '期望完成时间',
                  customizeContent: PrefixTextField(
                    object: 4, readOnly: true,
                    initText: DateUtil.formatDateTime(
                        (_.expectDate ?? '').toString(),
                        DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE
                    ),
                    valueOnChanged: (String string) async{
                      await controller.expectDateOnChanged(DateTime.tryParse(string));
                    },
                  )
              ),
            )
          ],
        ),
        dataReportItem1(
          title: '故障描述',
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
          ),
        ),
        ///故障类型、等级
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: CardWidget(
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '故障类型选择',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _.problemTypeListController,
                          padding: const EdgeInsets.all(6),
                          child: Wrap(
                            runSpacing: 6, spacing: 6,
                            children: List.generate(_.problemTypeList.length, (index) {
                              TreeModel item = _.problemTypeList[index];
                              return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                      onTap: () async{
                                        await controller.problemTypeOnChanged(item);
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
              const SizedBox(width: 12,),
              Expanded(
                child: CardWidget(
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '故障等级选择',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _.faultLevelListController,
                          padding: const EdgeInsets.all(6),
                          child: Wrap(
                            runSpacing: 6, spacing: 6,
                            children: List.generate(_.faultLevelList.length, (index) {
                              TreeModel item = _.faultLevelList[index];
                              return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                      onTap: () async{
                                        await controller.faultLevelOnChanged(item);
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
          ),
        ),

      ],
    );
  }

}