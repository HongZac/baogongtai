import 'package:desktop/app/model/assignment_form_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/assignment_interface/assignment_form_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';


///任务说明编辑页面
class AssignmentFormPage extends BaseDialogPage<AssignmentFormController> {

  Widget contentWidget(BuildContext context, AssignmentFormController _) {
    return SingleChildScrollView(
      child: Wrap(
        runSpacing: 8, spacing: 8,
        children: List.generate(_.formList.length, (index){
          AssignmentFormModel item = _.formList[index];
          return TitleTextBoxWidget(
            title: item.title,
            customizeContent: Wrap(
              runSpacing: 8, spacing: 8,
              children: [
                ///已设置的校验码
                ...List.generate(item.dataList.length, (index){
                  var data = item.dataList[index];
                  return RawChip(
                    padding: const EdgeInsetsGeometry.only(
                        left: 4, right: 10, top: 12, bottom: 12
                    ),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1
                    ),
                    label: Text(
                      data.toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    onDeleted: () async {
                      controller.removeData(item, data);
                    },
                    deleteIcon: Icon(
                      FluentIcons.delete_16_regular,
                      size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                    ),
                    deleteButtonTooltipMessage: '移除',
                  );
                }),
                ///新增校验码的按钮
                MineIconButton(
                  icon: Icons.add_box,
                  iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                  iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  tooltip: '新增校验码',
                  padding: const EdgeInsets.all(12),
                  onPressed: () async {
                    await controller.addNewData(item);
                  },
                ),
                Material(
                  child: InkWell(
                    onTap: (){
                      controller.isAllConditionMustBeMetOnChanged(item);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                              value: item.isAllConditionMustBeMet,
                              onChanged: (bool? boolValue){
                                controller.isAllConditionMustBeMetOnChanged(item);
                              }
                          ),
                          Text(
                            '必须符合全部条件  ',
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            titleWidth: 120,
            width: 1000, //580,
            titleStyle: Theme.of(context).textTheme.bodyLarge,
            titleMargin: const EdgeInsets.only(top: 10),
            titleAlignment: Alignment.topRight,
            margin: const EdgeInsets.only(bottom: 6),
            titleTip: item.hintText,
          );
        }).toList(),
      ),
    );
  }

}