import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:basement/utils.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/interface/tcp_socket_interface.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';


///TCP 客户端套接字通讯实现，内置自动重连机制。
///
/// 内网 TCP 连接，不监听网络状态，直接根据连接结果和 Socket 事件驱动重连。
class TcpSocket extends TcpSocketInterface {

  Socket? sock;

  StreamSubscription<Uint8List>? listen;

  /// 数据节流最小间隔（毫秒），避免高频数据冲击业务
  final int _minDataDelayTime = 700;

  //region 重连参数
  /// 单次连接超时，避免设备不可达时单次尝试长时间占住连接流程
  static const Duration _connectTimeout = Duration(seconds: 8);

  /// 监听取消等待上限，超时后仍继续销毁 Socket
  static const Duration _listenCancelTimeout = Duration(seconds: 3);

  /// 重试等待间隔（秒），到达最后一个值后保持不变
  static const List<int> _reconnectIntervals = [2, 5, 10, 20, 30];

  /// 稳定连接阈值（秒）：连续连接满该时长后，下一次断线从 2 秒开始重试
  static const int _stableConnectionSeconds = 30;
  //endregion

  //region 重连控制字段
  /// 单次连接锁：防止手动打开、定时重试同时创建连接
  bool _isConnecting = false;

  /// 连接代号（generation）：每次新连接或主动关闭时递增，
  /// 用于忽略旧连接迟到的回调、解析结果以及连接完成结果
  int _connectionGeneration = 0;

  /// 重连定时器：同一时刻最多存在一个待执行的重连任务，避免堆积 Future.delayed
  Timer? _reconnectTimer;

  /// 本次连接成功的时间，用于稳定连接阈值判断
  DateTime? _connectSuccessTime;
  //endregion


  TcpSocket({
    required super.host,
    required super.port,
    super.parserName,
  });


  @override
  Future<bool> open() async {
    /// 启用“保持连接”，之后发生断线会自动重连
    keepConnected = true;
    errMsg = '';

    /// 已连接则直接返回成功
    if (connectStatus == TcpSocketConnectStatus.connected) {
      return true;
    }
    /// 正在连接中则复用当前连接任务，不重复创建
    if (_isConnecting) {
      return false;
    }
    /// 之前可能处于等待重连状态，先取消已有定时器，立即发起一次连接
    _cancelReconnectTimer();

    return _connect();
  }


  /// 执行单次连接尝试并监听数据。
  /// 连接失败时返回 false，由断线处理流程安排自动重连。
  Future<bool> _connect() async {
    if (_isConnecting) {
      return false;
    }
    _isConnecting = true;
    final generation = ++_connectionGeneration;

    /// 通知状态：连接中
    _updateConnectStatus(TcpSocketConnectStatus.connecting);

    bool success = false;
    try {
      try {
        sock = await Socket.connect(host, port).timeout(_connectTimeout);
      } catch (e) {
        /// 连接失败，先检查连接是否已失效（用户在连接过程中关闭）
        if (generation != _connectionGeneration || !keepConnected) {
          return false;
        }
        errMsg = 'TCP $host:$port 连接时出错：${e.toString()}';
        _handleDisconnect();
        return false;
      }

      /// 连接成功后再次校验：用户在连接过程中关闭，则立即销毁并忽略
      if (generation != _connectionGeneration || !keepConnected) {
        try {
          sock?.destroy();
        } catch (_) {}
        sock = null;
        return false;
      }

      /// 监听数据
      listen = sock?.listen((Uint8List data) async {
        /// 旧连接的迟到回调直接忽略
        if (generation != _connectionGeneration) {
          return;
        }

        ///这里不要用防抖（Timer），会导致称重数据无法传递（称重消息每 50ms 发送一次，Timer 计时需要 1000ms）
        int currentKeyPressTime = DateTime.now().millisecondsSinceEpoch;
        PrintUtil.printDebug('两次 TCP 消息间隔：${currentKeyPressTime - theLastDataTime}');
        if (theLastDataTime != 0 && currentKeyPressTime - theLastDataTime < _minDataDelayTime) {
          PrintUtil.printDebug('两次 TCP 消息之间的时间间隔小于 $_minDataDelayTime 毫秒，拦截该消息');
        }
        else {
          theLastDataTime = currentKeyPressTime;
          errMsg = '';
          theLastDataList.clear();
          theLastDataList.addAll(data);
          eventBus.fire(TcpSocketDataModel(
            host: host,
            port: port,
            data: jsonEncode({'-2': theLastDataList}),
            isConnectMsg: true,
          ));
          var parsedData = await parser.parse(data.toList());

          /// 异步解析完成后再次校验 generation，避免旧连接的解析结果影响新连接
          if (generation != _connectionGeneration) {
            return;
          }
          if (parsedData != null && parsedData.isNotEmpty) {
            eventBus.fire(TcpSocketDataModel(
              host: host,
              port: port,
              data: parsedData,
            ));
          }
        }
      }, onError: (error) async {
        if (generation != _connectionGeneration) {
          return;
        }
        errMsg = 'TCP $host:$port 连接出错：${error.toString()}，请检查！';
        _handleDisconnect();
      }, onDone: () async {
        if (generation != _connectionGeneration) {
          return;
        }
        errMsg = 'TCP $host:$port 连接关闭！';
        _handleDisconnect();
      });

      /// 重置节流时间，避免新连接首包被旧时间拦截
      theLastDataTime = 0;
      _connectSuccessTime = DateTime.now();

      /// 连接成功，重置连续失败计数
      reconnectFailCount = 0;
      nextReconnectTime = null;

      isOpen = true;
      _updateConnectStatus(TcpSocketConnectStatus.connected);
      success = true;
    } finally {
      /// 无论成功失败，都释放连接锁，允许后续重连或再次打开
      _isConnecting = false;
    }
    return success;
  }


  /// 统一断线处理入口：onError / onDone / 首次连接失败都汇入这里。
  /// 同一次断线只处理一次，避免重复安排重连。
  void _handleDisconnect() {
    /// 主动关闭后不再重连
    if (!keepConnected) {
      return;
    }
    /// 已经处于等待重连或已关闭状态，说明本次断线已处理过，直接忽略
    if (connectStatus == TcpSocketConnectStatus.waitingReconnect
        || connectStatus == TcpSocketConnectStatus.closed) {
      return;
    }

    isOpen = false;

    /// 判断上一次连接是否达到稳定阈值，达到则重置失败计数，从 2 秒开始重试
    bool wasStable = _connectSuccessTime != null
        && DateTime.now().difference(_connectSuccessTime!).inSeconds >= _stableConnectionSeconds;
    if (wasStable) {
      reconnectFailCount = 0;
    }
    _connectSuccessTime = null;

    /// 先清理旧连接资源
    _cleanUp();

    reconnectFailCount++;

    /// 通知状态：等待重连
    _updateConnectStatus(TcpSocketConnectStatus.waitingReconnect);

    /// 首次失败或已连接后断线提示一次，后续重试失败只更新状态不重复弹窗
    if (reconnectFailCount == 1) {
      eventBus.fire(TcpSocketDataModel(
        host: host,
        port: port,
        data: jsonEncode({'-1': errMsg}),
        isConnectMsg: true,
      ));
    }

    _scheduleReconnect();
  }


  /// 安排下一次重连，使用有上限的退避间隔
  void _scheduleReconnect() {
    if (!keepConnected) {
      return;
    }
    /// 先取消已有定时器，确保同一时刻只有一个待执行重连任务
    _cancelReconnectTimer();

    /// 根据连续失败次数计算退避间隔，超过列表长度后保持最后一个值
    int interval = reconnectFailCount <= _reconnectIntervals.length
        ? _reconnectIntervals[reconnectFailCount - 1]
        : _reconnectIntervals.last;

    nextReconnectTime = DateTime.now().add(Duration(seconds: interval));

    _reconnectTimer = Timer(Duration(seconds: interval), () async {
      /// 定时器触发时再次校验，避免在等待期间被 close 取消
      if (!keepConnected) {
        return;
      }
      await _connect();
    });
  }


  /// 取消待执行的重连定时器
  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    nextReconnectTime = null;
  }


  /// 清理当前连接资源：先摘除引用，再取消监听、销毁 Socket
  Future<void> _cleanUp() async {
    final oldListen = listen;
    final oldSock = sock;
    listen = null;
    sock = null;

    if (oldListen != null) {
      try {
        await oldListen.cancel().timeout(_listenCancelTimeout);
      } catch (_) {}
    }
    if (oldSock != null) {
      try {
        oldSock.destroy();
      } catch (_) {}
    }
  }


  /// 更新连接状态并发送事件，供设置页刷新界面
  void _updateConnectStatus(TcpSocketConnectStatus status) {
    connectStatus = status;
    eventBus.fire(TcpSocketDataModel(
      host: host,
      port: port,
      data: '',
      isConnectMsg: true,
      connectStatus: status,
      keepConnected: keepConnected,
    ));
  }


  @override
  Future<bool> close() async {
    /// 标记不再保持连接，停止自动重连
    keepConnected = false;

    /// 取消待执行的重连定时器
    _cancelReconnectTimer();

    /// 递增连接代号，使在途连接（正在 await Socket.connect）的迟到结果失效
    _connectionGeneration++;

    /// 清理当前连接资源
    await _cleanUp();

    isOpen = false;
    reconnectFailCount = 0;
    _connectSuccessTime = null;
    nextReconnectTime = null;

    /// 通知状态：已关闭
    _updateConnectStatus(TcpSocketConnectStatus.closed);
    return true;
  }

}
