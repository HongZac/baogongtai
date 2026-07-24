import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/service/serial_com_service/base_serial_port.dart';
import 'package:desktop/app/service/serial_com_service/interface/serial_port_parser_interface.dart';
import 'package:desktop/app/service/serial_com_service/setting/serial_com_setting_controller.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_model.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///串口设置
class SerialComSettingView extends BaseDialogPage<SerialComSettingController>{

  Widget contentWidget(BuildContext context, SerialComSettingController _) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double expandedBodyHeight = (constraints.maxHeight / 2) - 56;
            double allBodyHeight = expandedBodyHeight * 2;
            double expansionPanel0BodyHeight = _.serialComService.serialPortList.length * 72;
            if (expansionPanel0BodyHeight > (_.isExpandedList[1] ? expandedBodyHeight : allBodyHeight)){
              expansionPanel0BodyHeight = _.isExpandedList[1] ? expandedBodyHeight : allBodyHeight;
            }
            double expansionPanel1BodyHeight = allBodyHeight - (_.isExpandedList[0] ? expansionPanel0BodyHeight : 0);
            return SingleChildScrollView(
              child: ExpansionPanelList(
                dividerColor: Colors.transparent,
                expandedHeaderPadding: const EdgeInsets.only(),
                expansionCallback: (int index, bool boolValue){
                  _.isExpandedList[index] = boolValue;
                  controller.update();
                },
                children: [
                  ExpansionPanel(
                    isExpanded: _.isExpandedList[0],
                    canTapOnHeader: true,
                    backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return Row(
                        children: [
                          const SizedBox(width: 8,),
                          Expanded(
                            child: Text(
                              '串口设置列表',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const SizedBox(width: 8,),

                          FilledButton(
                              onPressed: () async{
                                await controller.addSerialPort();
                              },
                              child: Text(
                                '新增',
                                style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                                ),
                              )
                          ),
                        ],
                      );
                    },
                    body: Container(
                      height: expansionPanel0BodyHeight,
                      child: ListView(
                        children: List.generate(_.serialComService.serialPortList.length, (index) {
                          BaseSerialPort item = _.serialComService.serialPortList[index];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                dense: true,
                                title: SelectableText.rich(
                                  TextSpan(
                                      text: item.portName,
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                          fontWeight: FontWeight.w600
                                      ),
                                      children: [
                                        if (item.theLastDataList.isNotEmpty)
                                          TextSpan(
                                              text: '（${item.theLastDataList.join(' ')}）',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context).colorScheme.outline,
                                              )
                                          ),
                                      ]
                                  ),
                                  maxLines: 1,
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      subContentItem(
                                        context,
                                        content: '波特率：${item.config.baudRate}',
                                      ),
                                      const SizedBox(width: 4,),
                                      subContentItem(
                                        context,
                                        content: '数据位：${item.config.bits}',
                                      ),
                                      const SizedBox(width: 4,),
                                      subContentItem(
                                        context,
                                        content: '校验位：${item.config.parity}',
                                      ),
                                      const SizedBox(width: 4,),
                                      subContentItem(
                                        context,
                                        content: '结束位：${item.config.stopBits}',
                                      ),
                                      const SizedBox(width: 4,),
                                      subContentItem( ///解析类型
                                        context,
                                        content: serialPortParserList[item.parserName?.index ?? 0].name,
                                      ),
                                      const SizedBox(width: 4,),
                                      subContentItem(
                                        context,
                                        content: item.autoOpen
                                            ? '自动打开串口通讯'
                                            : '',
                                      ),
                                    ],
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //itemBtn(
                                    //    context,
                                    //    title: '修改',
                                    //    onPressed: () async {
                                    //      await controller.editSerialPort(item);
                                    //    }
                                    //),
                                    //const SizedBox(width: 4,),
                                    itemBtn(
                                        context,
                                        title: '删除',
                                        onPressed: () async {
                                          await controller.deleteSerialPort(item);
                                        }
                                    ),
                                    const SizedBox(width: 48,),
                                    Switch(
                                      value: item.isOpen,
                                      onChanged: (bool? bool) async {
                                        await controller.serialPortOpenOnChanged(item);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              if (index < _.serialComService.serialPortList.length - 1)
                                Divider(indent: 0, endIndent: 0,),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  ExpansionPanel(
                    isExpanded: _.isExpandedList[1],
                    canTapOnHeader: true,
                    backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                    headerBuilder: (BuildContext context, bool isExpanded){
                      return Row(
                        children: [
                          const SizedBox(width: 8,),
                          Expanded(
                            child: Text(
                              '串口消息接收设置',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      );
                    },
                    body: Container(
                      height: expansionPanel1BodyHeight,
                      child: ListView(
                        children: List.generate(_.weightMsgConnectService.weightMsgList.length, (index){
                          ChoiceChipModel item = _.weightMsgConnectService.weightMsgList[index];
                          WeightMsgConnectModel? model = _.weightMsgConnectService.connectList.firstWhereOrNull(
                                  (element) => element.key == item.keyName);
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                dense: true,
                                title: Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      subContentItem(
                                        context,
                                        content: '串口号：${model != null ? model.com : ''}',
                                      ),
                                      if (item.keyName.toLowerCase().contains('weight'))
                                        const SizedBox(width: 4,),
                                      if (item.keyName.toLowerCase().contains('weight'))
                                        subContentItem(
                                          context,
                                          content: '精度值：${model != null ? model.accuracy : ''}',
                                        ),
                                    ],
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    itemBtn(
                                        context,
                                        title: '修改',
                                        onPressed: () async {
                                          await controller.serialPortMsgConnectSetting(item.keyName);
                                        }
                                    ),
                                    const SizedBox(width: 4,),
                                    itemBtn(
                                        context,
                                        title: '清除',
                                        onPressed: () async {
                                          await controller.serialPortMsgConnectDelete(item.keyName);
                                        }
                                    ),
                                  ],
                                ),
                              ),
                              if (index < _.weightMsgConnectService.weightMsgList.length - 1)
                                Divider(indent: 0, endIndent: 0,),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  Widget subContentItem(BuildContext context, {
    required String content,
    int flex = 1,
  }){
    return Expanded(
      flex: flex,
      child: Text(
        content,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.outline
        ), maxLines: 1, overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget itemBtn(BuildContext context, {
    required String title,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
  }){
    return FilledButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
              backgroundColor ?? Theme.of(context).colorScheme.surface
          ),
          maximumSize: WidgetStateProperty.all(const Size(80, 35)),
          minimumSize: WidgetStateProperty.all(const Size(80, 35)),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            color: foregroundColor ?? Theme.of(context).textTheme.bodyLarge!.color,
            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
          ),
        )
    );
  }
  
}