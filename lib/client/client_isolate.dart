// Manager for running MqttClientImpl inside a dedicated isolate
import 'dart:async';
import 'dart:isolate';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'mqtt_impl.dart';

class MqttClientIsolate {
  // Singleton of the isolate manager
  MqttClientIsolate._internal();
  static final MqttClientIsolate _instance = MqttClientIsolate._internal();
  factory MqttClientIsolate() => _instance;

  SendPort? _sendPort;

  Future<void> _init() async {
    if (_sendPort != null) return;
    final setupPort = ReceivePort();
    await Isolate.spawn(_isolateEntry, setupPort.sendPort);
    _sendPort = await setupPort.first as SendPort;
  }

  static void _isolateEntry(SendPort mainSendPort) {
    final impl = MqttClientImpl();
    final recvPort = ReceivePort();
    // send the SendPort back to manager
    mainSendPort.send(recvPort.sendPort);

    recvPort.listen((dynamic message) async {
      final Map data = message as Map;
      final cmd = data['cmd'] as String;
      final replyTo = data['replyTo'] as SendPort;
      try {
        if (cmd == 'connect') {
          await impl.connect(
            url: data['url'],
            clientId: data['clientId'],
            username: data['username'],
            password: data['password'],
            port: data['port'],
            keepAliveSec: data['keepAliveSec'],
          );
          replyTo.send({'ok': true});
        } else if (cmd == 'disconnect') {
          impl.disconnect();
          replyTo.send({'ok': true});
        }
      } catch (e) {
        replyTo.send({'ok': false, 'error': e.toString()});
      }
    });
  }

  Future<void> connect({
    required String url,
    required String clientId,
    String? username,
    String? password,
    int? port,
    int keepAliveSec = 60,
  }) async {
    await _init();
    final responsePort = ReceivePort();
    _sendPort!.send({
      'cmd': 'connect',
      'url': url,
      'clientId': clientId,
      'username': username,
      'password': password,
      'port': port,
      'keepAliveSec': keepAliveSec,
      'replyTo': responsePort.sendPort,
    });
    final result = await responsePort.first as Map;
    if (result['ok'] != true) {
      throw Exception(result['error']);
    }
  }

  Future<void> disconnect() async {
    if (_sendPort == null) return;
    final responsePort = ReceivePort();
    _sendPort!.send({ 'cmd': 'disconnect', 'replyTo': responsePort.sendPort });
    await responsePort.first;
  }
}
