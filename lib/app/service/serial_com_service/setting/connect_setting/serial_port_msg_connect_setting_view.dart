import 'package:basement/picker.dart';
import 'package:desktop/app/service/serial_com_service/setting/connect_setting/serial_port_msg_connect_setting_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_text_field.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';


///串口消息接收设置
class SerialPortMsgConnectSettingView extends BaseDialogPage<SerialPortMsgConnectSettingController> {

  Widget contentWidget(BuildContext context, SerialPortMsgConnectSettingController _) {
    return SingleChildScrollView(
      child: Column(
        children: [
          reportItem(
              context,
              title: '串口号',
              customizeContent: PickerInputWidget(
                adapter: _.comAdapter,
                onTap: (List<PickerDataModel> selectList) {
                  if (selectList.isNotEmpty){
                    controller.comOnChanged(selectList[0]);
                  }
                  else {
                    controller.comOnChanged(PickerDataModel());
                  }
                },
              )
          ),
          if (_.weightMsgConnectModel.key.toLowerCase().contains('weight'))
            reportItem(
              context,
              title: '精度值',
              customizeContent: NumPadTextField(
                numPadController: NumPadUtil().getNumPadController('accuracy', _.numPadCTList)!,
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