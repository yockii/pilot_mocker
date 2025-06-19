// Shared isolate manager for API, MQTT, and WebSocket clients
import 'dart:async';
import 'dart:isolate';
import 'mqtt_impl.dart';
import 'ws_impl.dart';
import 'api_impl.dart';
import 'package:http/http.dart' as http;
// import 'package:mqtt5_client/mqtt5_client.dart';  // unused import

class SharedClientIsolate {
  SharedClientIsolate._internal();
  static final SharedClientIsolate _instance = SharedClientIsolate._internal();
  factory SharedClientIsolate() => _instance;

  SendPort? _sendPort;

  Future<void> _init() async {
    if (_sendPort != null) return;
    final setupPort = ReceivePort();
    await Isolate.spawn(_isolateEntry, setupPort.sendPort);
    _sendPort = await setupPort.first as SendPort;
  }

  static void _isolateEntry(SendPort mainSendPort) {
    final mqttImpl = MqttClientImpl();
    final wsImpl = WebSocketClientImpl();
    final apiImpl = ApiClientImpl();
    final recvPort = ReceivePort();
    mainSendPort.send(recvPort.sendPort);

    recvPort.listen((dynamic message) async {
      final Map data = message as Map;
      final String target = data['target'];
      final String cmd = data['cmd'];
      final SendPort replyTo = data['replyTo'];
      try {
        if (target == 'mqtt') {
          if (cmd == 'connect') {
            await mqttImpl.connect(
              url: data['url'],
              clientId: data['clientId'],
              username: data['username'],
              password: data['password'],
              port: data['port'],
              keepAliveSec: data['keepAliveSec'],
            );
            replyTo.send({'ok': true});
          } else if (cmd == 'disconnect') {
            mqttImpl.disconnect();
            replyTo.send({'ok': true});
          } else if (cmd == 'publish') {
            final String topic = data['topic'];
            final String payload = data['payload'];
            await mqttImpl.publish(topic, payload);
            replyTo.send({'ok': true});
          } else if (cmd == 'isConnected') {
            final connected = mqttImpl.isConnected();
            replyTo.send({'ok': true, 'result': connected});
          }
        } else if (target == 'api') {
          if (cmd == 'setHost') {
            apiImpl.setHost(data['host']);
            replyTo.send({'ok': true});
          } else if (cmd == 'setToken') {
            apiImpl.setToken(data['token']);
            replyTo.send({'ok': true});
          } else if (cmd == 'request') {
            final resp = await apiImpl.request(
              data['path'],
              data['method'],
              Map<String, String>.from(data['headers']),
              data['body'],
            );
            replyTo.send({
              'ok': true,
              'statusCode': resp.statusCode,
              'body': resp.body,
              'headers': resp.headers,
            });
          }
        } else if (target == 'ws') {
          if (cmd == 'setHost') {
            wsImpl.setHost(data['host']);
            replyTo.send({'ok': true});
          } else if (cmd == 'setToken') {
            wsImpl.setToken(data['token']);
            replyTo.send({'ok': true});
          } else if (cmd == 'connect') {
            await wsImpl.connect();
            replyTo.send({'ok': true});
          } else if (cmd == 'isConnected') {
            final connected = wsImpl.isConnected();
            replyTo.send({'ok': true, 'result': connected});
          } else if (cmd == 'send') {
            wsImpl.send(data['message']);
            replyTo.send({'ok': true});
          } else if (cmd == 'disconnect') {
            await wsImpl.disconnect();
            replyTo.send({'ok': true});
          } else if (cmd == 'subscribe') {
            wsImpl.messages.listen((m) {
              replyTo.send({'ok': true, 'message': m});
            });
          }
        }
      } catch (e) {
        replyTo.send({'ok': false, 'error': e.toString()});
      }
    });
  }

  Future<Map> _send(String target, String cmd, Map<String, dynamic> params) async {
    await _init();
    final rp = ReceivePort();
    _sendPort!.send({
      'target': target,
      'cmd': cmd,
      ...params,
      'replyTo': rp.sendPort,
    });
    final result = await rp.first as Map;
    if (result['ok'] != true) throw Exception(result['error']);
    return result;
  }

  // MQTT
  Future<void> mqttConnect({
    required String url,
    required String clientId,
    String? username,
    String? password,
    int? port,
    int keepAliveSec = 60,
  }) async {
    await _send('mqtt', 'connect', {
      'url': url,
      'clientId': clientId,
      'username': username,
      'password': password,
      'port': port,
      'keepAliveSec': keepAliveSec,
    });
  }

  Future<void> mqttDisconnect() async {
    await _send('mqtt', 'disconnect', {});
  }

  /// Returns whether MQTT client is connected.
  Future<bool> mqttIsConnected() async {
    final res = await _send('mqtt', 'isConnected', {});
    return res['result'] as bool;
  }

  /// Publishes a message to MQTT via isolate.
  Future<void> mqttPublish(String topic, String payload) async {
    await _send('mqtt', 'publish', {'topic': topic, 'payload': payload});
  }

  // API
  Future<void> apiSetHost(String host) async {
    await _send('api', 'setHost', {'host': host});
  }

  Future<void> apiSetToken(String token) async {
    await _send('api', 'setToken', {'token': token});
  }

  Future<http.Response> apiRequest(
    String path, {
    String method = 'GET',
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final res = await _send('api', 'request', {
      'path': path,
      'method': method,
      'headers': headers ?? {},
      'body': body,
    });
    return http.Response(
      res['body'] as String,
      res['statusCode'] as int,
      headers: Map<String, String>.from(res['headers'] as Map),
    );
  }

  // WebSocket
  Future<void> wsSetHost(String host) async {
    await _send('ws', 'setHost', {'host': host});
  }

  Future<void> wsSetToken(String token) async {
    await _send('ws', 'setToken', {'token': token});
  }

  Future<void> wsConnect() async {
    await _send('ws', 'connect', {});
  }

  Future<bool> wsIsConnected() async {
    final res = await _send('ws', 'isConnected', {});
    return res['result'] as bool;
  }

  Future<void> wsSend(dynamic message) async {
    await _send('ws', 'send', {'message': message});
  }

  Future<void> wsDisconnect() async {
    await _send('ws', 'disconnect', {});
  }

  Future<Stream<dynamic>> wsMessages() async {
    await _init();
    final controller = StreamController<dynamic>();
    final rp = ReceivePort();
    _sendPort!.send({
      'target': 'ws',
      'cmd': 'subscribe',
      'replyTo': rp.sendPort,
    });
    rp.listen((dynamic res) {
      final Map m = res as Map;
      if (m['ok'] == true && m.containsKey('message')) {
        controller.add(m['message']);
      }
    });
    return controller.stream;
  }
}
