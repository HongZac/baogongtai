import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/form/inv_class_frx_name_form_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_text_field.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';


///新增/编辑 根据产品类别编码区分的打印模板
class InvClassFrxNameFormView extends BaseDialogPage<InvClassFrxNameFormController> {

  Widget contentWidget(BuildContext context, InvClassFrxNameFormController _) {
    return SingleChildScrollView(
      child: Column(
        children: [
          reportItem(
              context,
              title: '产品类别',
              customizeContent: PickerInputWidget(
                adapter: _.invClassAdapter,
                customContent: (PickerDataModel item) {
                  item as InventoryClassModel;
                  return '${item.code}';
                },
                onTap: (List<PickerDataModel> selectList) {
                  controller.invClassOnChanged(selectList);
                },
              )
          ),
          reportItem(
            context,
            title: '模板名称',
            customizeContent: NumPadTextField(
              numPadController: NumPadUtil().getNumPadController('frxName', _.numPadCTList)!,
            ),
          ),
        ],
      ),
    );
  }


  Widget reportItem(BuildContext context, {
    required String title,
    required Widget customizeContent,
    bool needMargin = true,
    double width = 580,
    double titleWidth = 100,
  }) {
    return TitleTextBoxWidget(
      title: title,
      customizeContent: customizeContent,
      titleWidth: titleWidth,
      width: width,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
      margin: needMargin ? const EdgeInsets.only(bottom: 6) : null,
    );
  }

}
