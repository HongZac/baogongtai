import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:basement/utils.dart';
import 'package:desktop/app/service/app_print_service/app_print_service.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket 连接状态
enum WebSocketConnectionState {
  /// 连接中……
  connecting,

  /// 已连接
  connected,

  /// 已断开
  disconnected,
}



class AutoReconnectWebSocket {

  static const String WEBSOCKET_CONNECTION = 'webSocketConnection';

  final _appService = Get.find<AppService>();
  final _appPrintService = Get.find<AppPrintService>();

  ///webSocket 地址
  final Uri _uri;

  WebSocketChannel? _webSocketChannel;
  final StreamController<dynamic> _messageController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get stream => _messageController.stream;
  StreamSubscription? _messageSubscription;
  StreamSubscription<InternetConnectionStatus>? _internetStatusSubscription;

  ///WebSocket 的当前连接状态
  WebSocketConnectionState _connectionState = WebSocketConnectionState.disconnected;

  ///互联网访问是否成功
  bool _isSuccessOfInternetAccess = true;

  //File _testFile = File('${ShareStorageUtil.logDirectory!.path}\\'
  //    'web_socket_log_${DateUtil.formatDateTime(DateTime.now().toString(), DateFormat.YEAR_MONTH_DAY)}.txt');


  //region 独立的重连锁（重连机制时使用）
  ///是否正在执行重连
  ///同一时间只允许一个重连流程；
  ///新的重连请求进来时，如果已有重连任务，则直接跳过；
  ///不要使用多个 Future.delayed() 堆积，优先使用一个可取消的 Timer ；
  ///网络断开、主动关闭、销毁页面时，取消未执行的重连任务；
  bool _isReConnecting = false;
  ///重连定时器，新的重连请求进来时，如果已有重连任务，则直接跳过
  Timer? _reconnectTimer;
  ///用于取消未完成的重连任务
  Completer<bool>? _reconnectCompleter;
  //endregion

  ///是否正在清理 WebSocket 资源
  bool _isCleaningUp = false;

  ///WebSocket 执行连接的可用时长 8s
  final Duration _connectTimeout = Duration(seconds: 8);
  ///关闭 WebSocket 流接收器的可用时长 3s
  final Duration _closeTimeout = Duration(seconds: 3);

  //region WebSocket 频繁重连（如果这[_reconnectCount]次重连时间间隔在[_frequentReconnectDuration]以内的话，放弃重连，并提示）
  ///WebSocket 频繁重连允许的时间间隔 60s
  final Duration _frequentReconnectDuration = Duration(seconds: 60);
  ///频繁重连允许的次数
  final int _reconnectCount = 6;
  ///近[_reconnectCount]次重连的时间列表
  final List<DateTime> _reconnectDateTimeList = [];
  //endregion

  ///连接是否已经关闭、销毁
  ///（关闭后，不允许做任何事情，但仍可能有部分资源没来得及销毁，这里增加一个销毁标识）
  bool _isDisposed = false;
  ///是否正在执行 WebSocket 连接、启动监听操作
  bool _isConnecting = false;

  ///用于判断是否是新连接（旧连接的 onDone/onError 可能误触发并清理新连接，每次连接 WebSocket 时递增 generation，让旧连接的迟到事件直接失效）
  ///现在没有“连接代号/世代号”，
  ///如果旧连接的 onDone 在新连接建立后才回调，代码只判断 _isDisposed && !_isCleaningUp，
  ///无法确认这个 onDone 是否属于当前连接，
  ///旧回调可能调用 _reConnectWebSocket()，然后 _cleanUpWebSocket() 清掉已经成功建立的新连接，表现就是“刚连上又断、频繁异常断开”
  int _connectionGeneration = 0;


  AutoReconnectWebSocket(this._uri) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async { ///页面加载完成后执行
      _webSocketInit();
    });
  }

  ///连接、监听、发送、检测
  void _webSocketInit() {

    ///通过网络连接检测 webSocket 连接状态（访问不到互联网直接重连）
    unawaited(_internetListen());
    ///连接并监听 WebSocket（这里不能重连，可能会使程序卡死）
    unawaited(_webSocketConnectAndListen()/*.then((value){
      if (!_isDisposed
          && _connectionState == WebSocketConnectionState.disconnected){
        _reConnectWebSocket(isByInternet: false);
      }
    })*/);

    /*
    //_webSocketChannel?.sink.add('connected'); ///发送消息
    //region 发送消息
    _isSendMsgRunning = true;
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: sendMsgSecond));
      if (!_isSendMsgRunning){ return false; }
      if (_webSocket != null){
        _webSocket!.send(sendMsg);
      }
      return _isSendMsgRunning;
    });
    //endregion

    //region doWhile 发送消息后传回，检测是否 WebSocket 连接
    _webSocketConnectCheckRunning = true;
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: sendMsgSecond));
      if (!_webSocketConnectCheckRunning){ return false; }
      Duration? difference = _lastTimeWebSocketGot == null ? null : DateTime.now().difference(_lastTimeWebSocketGot!);
      if (difference == null || difference > Duration(seconds: sendMsgSecond)){ ///已经和服务器断开连接 重连
        //await _reConnectWebSockeet();
      }
      return _webSocketConnectCheckRunning;
    });
    //endregion
    */
  }

  ///连接 WebSocket, 并监听 webSocket
  Future<void> _webSocketConnectAndListen() async {
    if (_isDisposed) {
      await _writeLog('WebSocket 服务已销毁，跳过此次连接尝试');
      return;
    }
    if (_connectionState == WebSocketConnectionState.connected){
      await _writeLog('连接已建立，跳过此次连接尝试');
      return;
    }
    if (_isConnecting
        || _connectionState == WebSocketConnectionState.connecting){
      await _writeLog('连接正在进行中，跳过此次连接尝试');
      return;
    }

    _isConnecting = true;
    final generation = ++_connectionGeneration;
    try {
      //region 创建连接
      await _writeLog('正在创建连接...');
      await _updateWebSocketConnectionState(WebSocketConnectionState.connecting);
      try {
        _webSocketChannel = WebSocketChannel.connect(_uri);
        await _webSocketChannel!.ready.timeout(_connectTimeout, onTimeout: () async {
          throw TimeoutException('WebSocket 连接超时', _connectTimeout);
        });
      } catch (e) {
        await _writeLog('WebSocket 连接失败：${e.toString()}');
        //todo 检查 err 内容
        /*if (e is WebSocketChannelException) {
          if (e.inner != null) {
            final err = e.inner as dynamic;
            await _writeLog('WebSocket 连接失败: ${err.message.toString()}');
          }
          else {
            await _writeLog('WebSocket 连接失败: ${e.message}');
          }
        }
        else {
          await _writeLog('WebSocket 连接失败：${e.toString()}');
        }*/
        await _cleanUpWebSocket();
        await _updateWebSocketConnectionState(WebSocketConnectionState.disconnected);
      }
      if (_webSocketChannel != null) {
        await _writeLog('连接成功！');
        await _updateWebSocketConnectionState(WebSocketConnectionState.connected);
      }
      //endregion
      //region 监听 webSocket
      if (_webSocketChannel != null) {
        try {
          _messageSubscription = _webSocketChannel!.stream.listen((event) async {
            if (!_messageController.isClosed) {
              _messageController.add(event);
            }
            if (kDebugMode){
              PrintUtil.printDebug("============== web socket receive message ==========\n${event.toString()}");
            }
          }, onError: (e) async {
            ///“服务端关闭”，“由于套接字没有连接并且没有提供地址，发送或接收数据的请求没有被接受”时会返回
            await _writeLog('ws channel error ${e.toString()}');
            if (generation != _connectionGeneration) {
              await _writeLog('是旧连接，跳过重连');
              return;
            }
            await _updateWebSocketConnectionState(WebSocketConnectionState.disconnected);
            if (!_isDisposed && !_isCleaningUp) {
              await _reConnectWebSocket(isByInternet: false);
            }
          }, onDone: () async {
            ///如果流关闭并发送一个完成事件（执行[_webSocketChannel?.sink.close()）后且该监听未关闭会回调到这里
            await _writeLog('ws channel closed');
            if (generation != _connectionGeneration) {
              await _writeLog('是旧连接，跳过重连');
              return;
            }
            await _updateWebSocketConnectionState(WebSocketConnectionState.disconnected);
            if (!_isDisposed && !_isCleaningUp) {
              await _reConnectWebSocket(isByInternet: false);
            }
          }, cancelOnError: true); ///cancelOnError-true：在传递第一个错误事件时会自动取消订阅
        } catch (e) {
          await _writeLog('webSocket 监听出错：${e.toString()}');
          if (generation != _connectionGeneration) {
            await _writeLog('是旧连接，跳过重连');
            return;
          }
          await _updateWebSocketConnectionState(WebSocketConnectionState.disconnected);
          if (!_isDisposed && !_isCleaningUp) {
            await _reConnectWebSocket(isByInternet: false);
          }
        }
      }
      //endregion
    } finally {
      _isConnecting = false;
    }
  }

  ///互联网访问监听消息接收
  ///网络重连之后其他地方会返回已关闭连接的 sessionEnd
  Future<void> _internetListen() async {
    await _internetStatusSubscription?.cancel();
    _internetStatusSubscription = _appService.eventBus.on<InternetConnectionStatus>().listen((event) async {
      bool isConnected = event == InternetConnectionStatus.connected;
      bool needReConnect = isConnected && !_isSuccessOfInternetAccess;
      _isSuccessOfInternetAccess = isConnected;

      if (_isDisposed) { return; }

      if (needReConnect) { /// 新接收的消息是访问互联网成功，并且之前访问互联网失败，则重连 websocket
        await _writeLog('网络连接恢复，尝试重新连接WebSocket');
        await _reConnectWebSocket();
      }
      else if (!_isSuccessOfInternetAccess){
        await _writeLog('网络连接丢失，清理WebSocket资源');
        _cancelReconnectTimer();
        await _cleanUpWebSocket();
        await _updateWebSocketConnectionState(WebSocketConnectionState.disconnected);
      }
    });
  }

  ///重连 Websocket
  Future<void> _reConnectWebSocket({bool isByInternet = true}) async {
    Future<bool> func({int? dtSeconds}) async {
      if (_isDisposed) {
        await _writeLog('WebSocket 服务已销毁，取消重连');
        return false;
      }
      if (_isCleaningUp){
        await _writeLog('正在清理 WebSocket 资源，跳过此次重连');
        return false;
      }
      if (!_isSuccessOfInternetAccess){
        await _writeLog('互联网访问失败，跳过此次重连');
        return false;
      }
      if (_connectionState == WebSocketConnectionState.connected){
        await _writeLog('连接已建立，取消重连');
        return false;
      }
      if (_isConnecting
          || _connectionState == WebSocketConnectionState.connecting){
        await _writeLog('连接正在进行中，取消重连');
        return false;
      }
      if (_isReConnecting || _reconnectTimer?.isActive == true){
        await _writeLog('已有重连任务正在进行中，取消重连');
        return false;
      }

      ///连接等待的时长是随机的，防止多个客户端同时重新建立连接，出现卡顿
      var dt = Duration(seconds: (dtSeconds ?? 10) + Random().nextInt(15));
      await _writeLog('${dt.inSeconds}秒后安排重新连接');
      _cancelReconnectTimer();
      final completer = Completer<bool>();
      _reconnectCompleter = completer;
      _reconnectTimer = Timer(dt, () async {
        _isReConnecting = true;
        try {
          if (_isDisposed) {
            await _writeLog('WebSocket 服务已销毁，取消重连');
            return;
          }
          if (_isCleaningUp) {
            await _writeLog('正在清理 WebSocket 资源，跳过此次重连');
            return;
          }
          if (!_isSuccessOfInternetAccess) {
            await _writeLog('互联网访问失败，跳过此次重连');
            return;
          }
          if (_connectionState == WebSocketConnectionState.connected) {
            await _writeLog('连接已建立，取消重连');
            return;
          }
          if (_isConnecting
              || _connectionState == WebSocketConnectionState.connecting) {
            await _writeLog('连接正在进行中，取消重连');
            return;
          }

          await _writeLog('ws 正在重连...');

          await _cleanUpWebSocket();
          await _webSocketConnectAndListen();

          if (_connectionState == WebSocketConnectionState.connected){
            //region App 打印服务
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) async { ///页面加载完成后执行
              if (_appPrintService.printServiceList.isNotEmpty){
                try {
                  ///todo 断开之后，重新启动前，需要取消之前的注册吗
                  _appPrintService.reRegister();
                } catch(e){}
              }
            });
            //endregion
          }

          await _writeLog('ws 重连结束');
        } catch (e) {
          await _writeLog('ws 重连异常: ${e.toString()}');
        } finally {
          _isReConnecting = false;
          _reconnectTimer = null;
          if (identical(_reconnectCompleter, completer)) {
            _reconnectCompleter = null;
          }
          if (!completer.isCompleted) {
            completer.complete(_connectionState == WebSocketConnectionState.connected);
          }
        }
      });
      return completer.future;
    }

    if (isByInternet){
      ///因网络问题重连时执行：如果[_reconnectCount]次重连时间间隔在一分钟以内的话，放弃重连，并提示
      if (_reconnectDateTimeList.length == _reconnectCount){
        _reconnectDateTimeList.removeAt(0);
      }
      _reconnectDateTimeList.add(DateTime.now());
      if (_reconnectDateTimeList.length == _reconnectCount
          && _reconnectDateTimeList.last.difference(_reconnectDateTimeList.first)
              < _frequentReconnectDuration){
        ToastNotification(Get.overlayContext!).error('短时间内重连多次，放弃连接 WebSocket，请检查网络或防火墙！');
        await onClose();
      }
      else {
        await func();
      }
    }
    else {
      ///服务器端主动关闭 或 websocket 监听出错：15 秒重连一次，如果 5 次重连都失败的话，则停止重连，返回
      int count = 0;
      await Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        if (_isDisposed
            || _connectionState == WebSocketConnectionState.connected
            || _isConnecting
            || _connectionState == WebSocketConnectionState.connecting
            || _isReConnecting
            || _reconnectTimer?.isActive == true){
          return false;
        }
        count ++;
        if (count > 5){
          String msg = '短时间内重连多次，放弃连接 WebSocket，请检查服务器端！';
          await _writeLog(msg);
          ToastNotification(Get.overlayContext!).error(msg);
          await onClose();
          return false;
        }
        bool success = await func();
        if (success
            || _isDisposed
            || _connectionState == WebSocketConnectionState.connected
            || _isConnecting
            || _connectionState == WebSocketConnectionState.connecting
            || _isReConnecting
            || _reconnectTimer?.isActive == true) {
          return false;
        }
        return true;
      });
    }
  }

  ///取消 Websocket 重连
  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    final completer = _reconnectCompleter;
    _reconnectCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }
  }

  /// 清理 WebSocket 资源
  Future<void> _cleanUpWebSocket() async {
    if (_isCleaningUp) {
      return;
    }
    _isCleaningUp = true;

    try {
      ///先置空引用，再异步关闭旧连接，避免后续逻辑误用旧 channel
      final subscription = _messageSubscription;
      final channel = _webSocketChannel;
      _messageSubscription = null;
      _webSocketChannel = null;

      if (subscription != null) {
        try {
          await subscription.cancel().timeout(_closeTimeout);
        } catch (e) {}
      }

      if (channel != null) {
        try {
          ///长时间待机，此处 close() 出错
          ///在网络异常、服务端断开、系统休眠恢复等场景下，
          ///sink.close() 可能卡住或耗时较长，
          ///如果这个方法被重连流程、页面生命周期、按钮事件间接等待，
          ///就会表现为“界面假死、按钮无响应”；
          ///这里加超时处理
          await channel.sink.close().timeout(_closeTimeout);
        } catch (e) {
          await _writeLog('Close WebSocket failed: $e');
        }
      }
    } finally {
      _isCleaningUp = false;
    }
  }

  ///关闭并销毁该连接（页面关闭 或 关闭连接时必须调用该函数）
  Future<void> onClose() async{
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;

    await _writeLog('ws 主动关闭并销毁');
    _cancelReconnectTimer();
    await _updateWebSocketConnectionState(WebSocketConnectionState.disconnected);
    await _cleanUpWebSocket();
    if (_internetStatusSubscription != null){
      await _internetStatusSubscription?.cancel();
      _internetStatusSubscription = null;
    }
    if (!_messageController.isClosed){
      await _messageController.close();
    }
  }

  Future<void> _writeLog(String msg) async {
    PrintUtil.printDebug(msg);
    /*try {
      await _testFile.writeAsString(
          '${DateTime.now().toString()}: \n$msg\n\n',
          mode: FileMode.append
      );
    } catch (e){  }*/
  }

  /// 更新连接状态并发送出去
  Future<void> _updateWebSocketConnectionState(WebSocketConnectionState newState) async {
    _connectionState = newState;
    await _writeLog('连接状态变更: $newState');

    bool? value = _connectionState == WebSocketConnectionState.connecting
        ? null
        : _connectionState == WebSocketConnectionState.connected;
    Map<String, dynamic> msg = {'name': WEBSOCKET_CONNECTION, 'data': value};
    if (!_messageController.isClosed){
      _messageController.add(json.encode(msg));
    }
  }

}