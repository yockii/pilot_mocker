// Isolate-based manager for API client
import 'dart:async';
import 'dart:isolate';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClientIsolate {
  ApiClientIsolate._internal();
  static final ApiClientIsolate _instance = ApiClientIsolate._internal();
  factory ApiClientIsolate() => _instance;

  SendPort? _sendPort;

  Future<void> _init() async {
    if (_sendPort != null) return;
    final setupPort = ReceivePort();
    await Isolate.spawn(_isolateEntry, setupPort.sendPort);
    _sendPort = await setupPort.first as SendPort;
  }

  static void _isolateEntry(SendPort mainSendPort) {
    final _impl = _ApiClientImpl();
    final recvPort = ReceivePort();
    mainSendPort.send(recvPort.sendPort);
    recvPort.listen((dynamic message) async {
      final Map data = message as Map;
      final cmd = data['cmd'] as String;
      final replyTo = data['replyTo'] as SendPort;
      try {
        if (cmd == 'setHost') {
          _impl.setHost(data['host']);
          replyTo.send({'ok': true});
        } else if (cmd == 'setToken') {
          _impl.setToken(data['token']);
          replyTo.send({'ok': true});
        } else if (cmd == 'request') {
          final resp = await _impl.request(
            data['path'] as String,
            data['method'] as String,
            Map<String, String>.from(data['headers'] as Map),
            data['body'],
          );
          replyTo.send({
            'ok': true,
            'statusCode': resp.statusCode,
            'body': resp.body,
            'headers': resp.headers,
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

  Future<http.Response> request(
    String path, {
    String method = 'GET',
    Map<String, String>? headers,
    dynamic body,
  }) async {
    await _init();
    final rp = ReceivePort();
    _sendPort!.send({
      'cmd': 'request',
      'path': path,
      'method': method,
      'headers': headers ?? {},
      'body': body,
      'replyTo': rp.sendPort,
    });
    final result = await rp.first as Map;
    if (result['ok'] != true) {
      throw Exception(result['error']);
    }
    return http.Response(
      result['body'] as String,
      result['statusCode'] as int,
      headers: Map<String, String>.from(result['headers'] as Map),
    );
  }
}

/// Internal implementation of API client
class _ApiClientImpl {
  String _host = '';
  String _token = '';

  void setHost(String host) {
    _host = host;
  }

  void setToken(String token) {
    _token = token;
  }

  Future<http.Response> request(
    String path,
    String method,
    Map<String, String>? headers,
    dynamic body,
  ) async {
    final uri = Uri.parse('$_host$path');
    final Map<String, String> reqHeaders = {
      'Content-Type': 'application/json',
      'X-Auth-Token': _token,
      if (headers != null) ...headers,
    };
    switch (method.toUpperCase()) {
      case 'POST':
        return await http.post(uri,
            headers: reqHeaders, body: json.encode(body));
      case 'PUT':
        return await http.put(uri,
            headers: reqHeaders, body: json.encode(body));
      case 'DELETE':
        return await http.delete(uri,
            headers: reqHeaders, body: json.encode(body));
      default:
        return await http.get(uri, headers: reqHeaders);
    }
  }
}
