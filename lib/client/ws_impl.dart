// Concrete implementation of WebSocket client for use inside isolate
import 'dart:async';
import 'dart:io';

class WebSocketClientImpl {
  String _host = '';
  String _token = '';
  WebSocket? _socket;

  void setHost(String host) {
    _host = host;
  }

  void setToken(String token) {
    _token = token;
  }

  Future<WebSocket> connect() async {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      return _socket!;
    }
    final uri = Uri.parse(_host);
    final authUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'x-auth-token': _token,
      },
    );
    _socket = await WebSocket.connect(authUri.toString());
    return _socket!;
  }

  void send(dynamic message) {
    _socket?.add(message);
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
  }

  Stream<dynamic> get messages => _socket!;
  /// Whether the WebSocket is currently connected
  bool isConnected() => _socket != null && _socket!.readyState == WebSocket.open;
}
