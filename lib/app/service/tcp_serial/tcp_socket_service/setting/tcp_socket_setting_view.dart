import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_enum.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/base_tcp_socket.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_msg_process_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/setting/tcp_socket_setting_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///TCP客户端套接字设置
class TcpSocketSettingView extends BaseDialogPage<TcpSocketSettingController> {

  Widget contentWidget(BuildContext context, TcpSocketSettingController _) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double expandedBodyHeight = (constraints.maxHeight / 2) - 56;
            double allBodyHeight = expandedBodyHeight * 2;
            double expansionPanel0BodyHeight = _.tcpSocketService.tcpSocketList.length * 72;
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
                              'TCP 设置列表',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const SizedBox(width: 8,),

                          FilledButton(
                              onPressed: () async{
                                await controller.addTcpSocket();
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
                        children: List.generate(_.tcpSocketService.tcpSocketList.length, (index) {
                          BaseTcpSocket item = _.tcpSocketService.tcpSocketList[index];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                dense: true,
                                title: SelectableText.rich(
                                  TextSpan(
                                      text: '${item.host.toString()}:${item.port.toString()}',
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                          fontWeight: FontWeight.w600
                                      ),
                                      children: [
                                        if (item.errMsg.isNotEmpty)
                                          TextSpan(
                                              text: '（${item.errMsg}）',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context).colorScheme.outline,
                                              )
                                          )
                                        else if (item.theLastDataList.isNotEmpty)
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
                                      subContentItem( ///解析类型
                                        context,
                                        content: TcpSerialParserEnum.values[item.parserName?.index ?? 0].name,
                                      ),
                                      const SizedBox(width: 4,),
                                      subContentItem(
                                        context,
                                        content: item.autoOpen
                                            ? '自动打开 TCP 通讯'
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
                                          await controller.deleteTcpSocket(item);
                                        }
                                    ),
                                    const SizedBox(width: 48,),
                                    Switch(
                                      value: item.isOpen,
                                      onChanged: (bool? bool) async {
                                        await controller.tcpSocketOpenOnChanged(item);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              if (index < _.tcpSocketService.tcpSocketList.length - 1)
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
                              'TCP 消息接收设置',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      );
                    },
                    body: Container(
                      height: expansionPanel1BodyHeight,
                      child: ListView(
                        children: List.generate(AppConfig.socketDataList.length, (index){
                          ChoiceChipModel item = AppConfig.socketDataList[index];
                          TcpSocketMsgProcessModel? model = _.tcpSocketService.tcpSocketMsgProcessList.firstWhereOrNull(
                                  (element) => element.keyName == item.keyName);
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
                                        content: '发送地址：${model != null
                                            ? '${model.host.toString()}:${model.port.toString()}'
                                            : ''}',
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
                                          await controller.tcpSocketMsgConnectSetting(item.keyName);
                                        }
                                    ),
                                    const SizedBox(width: 4,),
                                    itemBtn(
                                        context,
                                        title: '清除',
                                        onPressed: () async {
                                          await controller.tcpSocketMsgConnectDelete(item.keyName);
                                        }
                                    ),
                                  ],
                                ),
                              ),
                              if (index < AppConfig.socketDataList.length - 1)
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