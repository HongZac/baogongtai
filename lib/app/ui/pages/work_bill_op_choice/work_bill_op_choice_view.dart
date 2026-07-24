

import 'package:basement/model.dart';
import 'package:desktop/app/ui/pages/work_bill_op_choice/work_bill_op_choice_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:flutter/material.dart';


///选择工序计划单的明细工序
class WorkBillOpChoiceView extends BaseDialogPage<WorkBillOpChoiceController>{

  Widget contentWidget(BuildContext context, WorkBillOpChoiceController _) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2, right: 42),
      child: Container(
        alignment: Alignment.topLeft,
        child: Wrap(
          runSpacing: 6, spacing: 6,
          children: List.generate(_.workBillEntryList.length, (index) {
            MoWorkBillEntryModel item = _.workBillEntryList[index];
            return Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: () {
                      controller.choiceOnChanged(item);
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 220, height: 80,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                                '${(item.opCode ?? '').isNotEmpty ? item.opCode : ' '}',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w600
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                                '${(item.opName ?? '').isNotEmpty ? item.opName : ' '}',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w600
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis
                            ),
                          ),
                        ],
                      ),
                    )
                )
            );
          }).toList(),
        ),
      ),
    );
  }


}