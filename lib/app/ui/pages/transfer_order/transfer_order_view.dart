import 'package:basement/picker.dart';
import 'package:desktop/app/ui/pages/transfer_order/transfer_order_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';


///单据转单 / 开工  选择员工/设备
class TransferOrderView extends BaseDialogPage<TransferOrderController> {

  @override
  Widget contentWidget(BuildContext context, TransferOrderController _) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemWidget(
          context, _,
          title: '生产人员',
          isNeedMargin: true,
          content: PickerInputWidget(
            adapter: _.personAdapter,
            onTap: (List<PickerDataModel> selectList) {
              if (selectList.isNotEmpty){
                controller.psnOnChanged(selectList[0]);
              }
              else {
                controller.psnOnChanged(PickerDataModel());
              }
            },
          ),
        ),

        itemWidget(
          context, _,
          title: '生产设备',
          content: PickerInputWidget(
            adapter: _.deviceAdapter,
            onTap: (List<PickerDataModel> selectList) {
              if (selectList.isNotEmpty){
                controller.deviceOnChanged(selectList[0]);
              }
              else {
                controller.deviceOnChanged(PickerDataModel());
              }
            },
          ),
        ),
      ],
    );
  }


  Widget itemWidget(BuildContext context, TransferOrderController _, {
    required String title,
    required Widget content,
    bool isNeedMargin = false,
    double? width,
    CrossAxisAlignment? crossAxisAlignment,
    Alignment? titleAlignment,
    EdgeInsetsGeometry? titleMargin,
  }){
    return TitleTextBoxWidget(
      title: title,
      customizeContent: content,
      titleWidth: 120, width: width,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      titleAlignment: titleAlignment,
      margin: isNeedMargin ? const EdgeInsets.only(bottom: 24) : null,
      titleMargin: titleMargin,
    );
  }

}