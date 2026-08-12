import 'package:basement/picker.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/setting/connect_setting/tcp_socket_msg_connect_setting_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_text_field.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';


///TCP客户端套接字消息接收设置
class TcpSocketMsgConnectSettingView extends BaseDialogPage<TcpSocketMsgConnectSettingController> {

  Widget contentWidget(BuildContext context, TcpSocketMsgConnectSettingController _) {
    return SingleChildScrollView(
      child: Column(
        children: [
          reportItem(
              context,
              title: '服务端',
              customizeContent: PickerInputWidget(
                adapter: _.serverAdapter,
                onTap: (List<PickerDataModel> selectList) {
                  if (selectList.isNotEmpty){
                    controller.serverOnChanged(selectList[0]);
                  }
                  else {
                    controller.serverOnChanged(PickerDataModel());
                  }
                },
              )
          ),
          if (_.tcpSocketMsgProcessModel.keyName.toLowerCase().contains('weight'))
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