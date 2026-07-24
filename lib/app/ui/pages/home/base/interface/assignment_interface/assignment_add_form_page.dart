import 'package:basement/picker.dart' show PickerDataModel;
import 'package:desktop/app/ui/pages/home/base/interface/assignment_interface/assignment_add_form_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///任务说明新增单个项
class AssignmentAddFormPage extends BaseDialogPage<AssignmentAddFormController> {

  @override
  Widget contentWidget(BuildContext context, AssignmentAddFormController _) {
    return Container(
      alignment: Alignment.center,
      child: _.tC != null ?
      TextField(
        focusNode: _.fn,
        controller: _.tC,
        maxLines: 1,
        style: Theme.of(context).textTheme.bodyLarge,
        onChanged: (String string) async {
          controller.tcDataOnChanged(string);
        },
        decoration: InputDecoration(
          hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
              fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
          ),
          contentPadding: kIsWeb || GetPlatform.isWindows
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 18)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          suffixIcon: _.tC!.text.isEmpty ? null : MineIconButton(
            icon: Icons.cancel,
            iconSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
            tooltip: '清空',
            onPressed: () {
              _.tC!.clear();
              controller.tcDataOnChanged(_.tC!.text);
            },
          ),
        ),
      ) :
      _.adapter != null ?
      PickerInputWidget(
        adapter: _.adapter,
        onTap: (List<PickerDataModel> selectList) {
          controller.adapterDataOnChanged(selectList);
        },
      ) :
      SizedBox(),
    );
  }

}