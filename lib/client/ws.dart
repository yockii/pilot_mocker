import 'dart:async';
import 'shared_client_isolate.dart';

/// Singleton WebSocket client delegating to a background isolate for thread safety
class WebSocketClient {
  WebSocketClient._internal();
  static final WebSocketClient _instance = WebSocketClient._internal();
  factory WebSocketClient() => _instance;

  /// Set the WebSocket host URL (e.g., "ws://example.com/socket").
  Future<void> setHost(String host) => SharedClientIsolate().wsSetHost(host);

  /// Set the auth token to be sent as x-auth-token query parameter.
  Future<void> setToken(String token) => SharedClientIsolate().wsSetToken(token);

  Future<bool> isConnected() => SharedClientIsolate().wsIsConnected();

  /// Connects to the WebSocket server, appending x-auth-token in query.
  /// Returns an open WebSocket.
  Future<void> connect() => SharedClientIsolate().wsConnect();

  /// Sends a message over the WebSocket.
  Future<void> send(dynamic message) => SharedClientIsolate().wsSend(message);

  /// Disconnects from the WebSocket server.
  Future<void> disconnect() => SharedClientIsolate().wsDisconnect();

  /// Stream of received messages.
  Future<Stream<dynamic>> messages() => SharedClientIsolate().wsMessages();
}
