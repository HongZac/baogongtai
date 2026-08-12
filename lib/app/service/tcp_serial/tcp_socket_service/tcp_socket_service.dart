import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_enum.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/base_tcp_socket.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_msg_process_model.dart';
import 'package:get/get.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';


///TCP 套接字通讯服务管理，主要功能包括TCP的注册与取消
class TcpSocketService extends GetxService {

  ///已经注册了的 TCP 套接字通讯服务列表
  final List<BaseTcpSocket> tcpSocketList = [];

  ///CP 套接字消息接收配置列表
  final List<TcpSocketMsgProcessModel> tcpSocketMsgProcessList = [];


  @override
  void onInit() {
    super.onInit();

    tcpSocketList.clear();
    var list = ShareStorageUtil.instance?.read(SharedPreferencesKeys.TCP_SOCKET_SERVICE_TCP_SOCKET_LIST_KEY) ?? [];
    if (list.isNotEmpty){
      list.forEach((element){
        BaseTcpSocket model = BaseTcpSocket.fromJson(element);
        tcpSocketList.add(model);
      });
    }

    tcpSocketMsgProcessList.clear();
    var list2 = ShareStorageUtil.instance?.read(SharedPreferencesKeys.TCP_SOCKET_SERVICE_TCP_SOCKET_MSG_PROCESS_LIST_KEY) ?? [];
    if (list2.isNotEmpty){
      list2.forEach((element){
        TcpSocketMsgProcessModel model = TcpSocketMsgProcessModel.fromJson(element);
        tcpSocketMsgProcessList.add(model);
      });
    }

    ///自动打开 TCP 通讯
    for (var element in tcpSocketList) {
      if (element.autoOpen) {
        element.open();
      }
    }

  }



  ///注册 TCP，并且保存至本地配置中
  ///
  /// [host]：主机号
  ///
  /// [port]：端口号
  ///
  /// [autoOpen]：启动程序后，默认自动打开 TCP 通讯
  ///
  /// [parserName]：解析类型 [TcpSerialParserEnum]
  Future<void> register({
    required dynamic host,
    required int port,
    bool? autoOpen,
    TcpSerialParserEnum? parserName,
  }) async {
    var tcpSocket = tcpSocketList.firstWhereOrNull((e) => e.host == host && e.port == port);
    ///如果已存在，则直接退出
    if (tcpSocket != null){
      return;
    }

    ///未进行数据正确性校验
    tcpSocket = BaseTcpSocket(
      host: host,
      port: port,
      autoOpen: autoOpen ?? false,
      parser: parserName,
    );
    tcpSocketList.add(tcpSocket);

    ///保存至本地配置文件中
    List<Map<String, dynamic>> mapList = tcpSocketList.map((e) => e.toJson()).toList();
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.TCP_SOCKET_SERVICE_TCP_SOCKET_LIST_KEY, mapList);

    if (tcpSocket.autoOpen) {
      ///自动打开 TCP 通讯
      await tcpSocket.open();
    }
  }

  ///删除 TCP
  Future<void> removeTcpSocket({
    required dynamic host,
    required int port,
  }) async {
    BaseTcpSocket? item = tcpSocketList.firstWhereOrNull((element) => element.host == host && element.port == port);
    if (item != null){
      if (item.isOpen) {
        await item.close();
      }
      tcpSocketList.removeWhere((element) => element.host == item.host && element.port == item.port);

      ///保存至本地配置文件中
      List<Map<String, dynamic>> mapList = tcpSocketList.map((e) => e.toJson()).toList();
      ShareStorageUtil.instance?.write(SharedPreferencesKeys.TCP_SOCKET_SERVICE_TCP_SOCKET_LIST_KEY, mapList);
    }
  }


  @override
  void onClose() {
    ///将所有打开的 TCP 关闭
    for (var element in tcpSocketList) {
      element.close();
    }
    super.onClose();
  }

}
