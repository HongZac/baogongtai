import 'package:basement/picker.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/setting/form/tcp_socket_setting_form_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_text_field.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';


///新增TCP客户端套接字通讯服务
class TcpSocketSettingFormView extends BaseDialogPage<TcpSocketSettingFormController> {

  Widget contentWidget(BuildContext context, TcpSocketSettingFormController _) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          reportItem(
            context,
            title: '主机号',
            customizeContent: NumPadTextField(
              numPadController: NumPadUtil().getNumPadController('host', _.numPadCTList)!,
            ),
          ),
          reportItem(
            context,
            title: '端口号',
            customizeContent: NumPadTextField(
              numPadController: NumPadUtil().getNumPadController('port', _.numPadCTList)!,
            ),
          ),
          reportItem(
              context,
              title: '解析类型',
              customizeContent: PickerInputWidget(
                adapter: _.parserNameAdapter,
                onTap: (List<PickerDataModel> selectList) {
                  if (selectList.isNotEmpty){
                    controller.parserNameOnChanged(selectList[0]);
                  }
                  else {
                    controller.parserNameOnChanged(PickerDataModel());
                  }
                },
              )
          ),
          SizedBox(
            width: 580,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '默认自动打开 TCP 通讯：',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Checkbox(
                  value: _.autoOpen,
                  onChanged: (bool? boolValue) {
                    controller.autoOpenOnChanged();
                  },
                ),
              ],
            ),
          )
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