// Manager for running WebSocketClientImpl inside a dedicated isolate
import 'dart:async';
import 'dart:isolate';
import 'ws_impl.dart';
import 'dart:io';

class WebSocketClientIsolate {
  WebSocketClientIsolate._internal();
  static final WebSocketClientIsolate _instance = WebSocketClientIsolate._internal();
  factory WebSocketClientIsolate() => _instance;

  SendPort? _sendPort;

  Future<void> _init() async {
    if (_sendPort != null) return;
    final setupPort = ReceivePort();
    await Isolate.spawn(_isolateEntry, setupPort.sendPort);
    _sendPort = await setupPort.first as SendPort;
  }

  static void _isolateEntry(SendPort mainSendPort) {
    final impl = WebSocketClientImpl();
    final recvPort = ReceivePort();
    mainSendPort.send(recvPort.sendPort);

    recvPort.listen((dynamic message) async {
      final Map data = message as Map;
      final cmd = data['cmd'] as String;
      final replyTo = data['replyTo'] as SendPort;
      try {
        if (cmd == 'setHost') {
          impl.setHost(data['host']);
          replyTo.send({'ok': true});
        } else if (cmd == 'setToken') {
          impl.setToken(data['token']);
          replyTo.send({'ok': true});
        } else if (cmd == 'connect') {
          await impl.connect();
          replyTo.send({'ok': true});
        } else if (cmd == 'isConnected') {
          final connected = impl.isConnected();
          replyTo.send({'ok': true, 'result': connected});
        } else if (cmd == 'send') {
          impl.send(data['message']);
          replyTo.send({'ok': true});
        } else if (cmd == 'disconnect') {
          await impl.disconnect();
          replyTo.send({'ok': true});
        } else if (cmd == 'subscribe') {
          impl.messages.listen((m) {
            replyTo.send({'ok': true, 'message': m});
          });
        }
      } catch (e) {
        replyTo.send({'ok': false, 'error': e.toString()});
      }
    });
  }

  Future<void> setHost(String host) async {
    await _init();
    final rp = ReceivePort();
    _sendPort!.send({'cmd': 'setHost', 'host': host, 'replyTo': rp.sendPort});
    await rp.first;
  }

  Future<void> setToken(String token) async {
    await _init();
    final rp = ReceivePort();
    _sendPort!.send({'cmd': 'setToken', 'token': token, 'replyTo': rp.sendPort});
    await rp.first;
  }

  Future<void> connect() async {
    await _init();
    final rp = ReceivePort();
    _sendPort!.send({'cmd': 'connect', 'replyTo': rp.sendPort});
    await rp.first;
  }

  Future<bool> isConnected() async {
    await _init();
    final rp = ReceivePort();
    _sendPort!.send({'cmd': 'isConnected', 'replyTo': rp.sendPort});
    final res = await rp.first as Map;
    if (res['ok'] == true) {
      return res['result'] as bool;
    }
    return false;
  }

  Future<void> send(dynamic message) async {
    await _init();
    final rp = ReceivePort();
    _sendPort!.send({'cmd': 'send', 'message': message, 'replyTo': rp.sendPort});
    await rp.first;
  }

  Future<void> disconnect() async {
    await _init();
    final rp = ReceivePort();
    _sendPort!.send({'cmd': 'disconnect', 'replyTo': rp.sendPort});
    await rp.first;
  }

  Future<Stream<dynamic>> messages() async {
    await _init();
    final controller = StreamController<dynamic>();
    final rp = ReceivePort();
    _sendPort!.send({'cmd': 'subscribe', 'replyTo': rp.sendPort});
    rp.listen((dynamic res) {
      final Map m = res as Map;
      if (m['ok'] == true && m.containsKey('message')) {
        controller.add(m['message']);
      }
    });
    return controller.stream;
  }
}
