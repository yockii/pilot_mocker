import 'dart:async';
import 'dart:io';

/// Singleton WebSocket client that manages host, token, and adds x-auth-token on connect.
class WebSocketClient {
  WebSocketClient._internal();
  static final WebSocketClient _instance = WebSocketClient._internal();
  factory WebSocketClient() => _instance;

  String _host = '';
  String _token = '';
  WebSocket? _socket;

  /// Set the WebSocket host URL (e.g., "ws://example.com/socket").
  void setHost(String host) {
    _host = host;
  }

  /// Set the auth token to be sent as x-auth-token query parameter.
  void setToken(String token) {
    _token = token;
  }

  bool get isConnected => _socket != null && _socket!.readyState == WebSocket.open;

  /// Connects to the WebSocket server, appending x-auth-token in query.
  /// Returns an open WebSocket.
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

  /// Sends a message over the WebSocket.
  void send(dynamic message) {
    _socket?.add(message);
  }

  /// Disconnects from the WebSocket server.
  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
  }

  /// Stream of received messages.
  Stream<dynamic>? get messages => _socket;
}
