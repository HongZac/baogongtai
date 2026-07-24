import 'package:basement/picker.dart';
import 'package:desktop/app/service/serial_com_service/setting/form/serial_com_setting_form_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_text_field.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';


///新增串口通讯服务
class SerialComSettingFormView extends BaseDialogPage<SerialComSettingFormController> {

  Widget contentWidget(BuildContext context, SerialComSettingFormController _) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reportItem(
                    context,
                    title: '串口号',
                    customizeContent: PickerInputWidget(
                      adapter: _.portNameAdapter,
                      onTap: (List<PickerDataModel> selectList) {
                        if (selectList.isNotEmpty){
                          controller.portNameOnChanged(selectList[0]);
                        }
                        else {
                          controller.portNameOnChanged(PickerDataModel());
                        }
                      },
                    )
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '默认自动打开串口通讯：',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Checkbox(
                      value: _.autoOpen,
                      onChanged: (bool? boolValue) {
                        controller.autoOpenOnChanged();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 4,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reportItem(
                  context,
                  title: '波特率',
                  customizeContent: NumPadTextField(
                    numPadController: NumPadUtil().getNumPadController('baudRate', _.numPadCTList)!,
                  ),
                ),
                reportItem(
                  context,
                  title: '数据位',
                  customizeContent: NumPadTextField(
                    numPadController: NumPadUtil().getNumPadController('bits', _.numPadCTList)!,
                  ),
                ),
                reportItem(
                  context,
                  title: '校验位',
                  customizeContent: NumPadTextField(
                    numPadController: NumPadUtil().getNumPadController('parity', _.numPadCTList)!,
                  ),
                ),
                reportItem(
                  context,
                  title: '结束位',
                  customizeContent: NumPadTextField(
                    numPadController: NumPadUtil().getNumPadController('stopBits', _.numPadCTList)!,
                  ),
                ),
              ],
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