// Concrete implementation of MQTT client for use inside the isolate
import 'dart:async';
import 'dart:convert'; // for utf8
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:typed_data/typed_buffers.dart';

class MqttClientImpl {
  MqttServerClient? _client;

  /// Connects to the MQTT broker at [url] with [clientId], and optional [username], [password], [port].
  /// Automatically selects TCP or WebSocket based on URL scheme.
  Future<MqttServerClient> connect({
    required String url,
    required String clientId,
    String? username,
    String? password,
    int? port,
    bool cleanSession = true,
    int keepAliveSec = 60,
  }) async {
    // Return existing connected client
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      return _client!;
    }

    final uri = Uri.parse(url);
    final useWebSocket = uri.scheme == 'ws' || uri.scheme == 'wss';
    final host = uri.host;
    final portToUse = port ?? (uri.hasPort
        ? uri.port
        : (useWebSocket
            ? (uri.scheme == 'wss' ? 443 : 80)
            : (uri.scheme == 'mqtts' ? 8883 : 1883)));
    final path = useWebSocket && uri.path.isNotEmpty ? uri.path : null;

    final client = MqttServerClient(host, clientId)
      ..port = portToUse
      ..keepAlivePeriod = keepAliveSec
      ..secure = uri.scheme == 'mqtts' || uri.scheme == 'wss'
      ..useWebSocket = useWebSocket
      ..logging(on: false);

    if (useWebSocket && path != null) {
      client.websocketProtocols = ['mqtt'];
    }

    // Build connect message
    final connMsg = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    if (username != null && password != null) {
      connMsg.authenticateAs(username, password);
    }
    client.connectionMessage = connMsg;

    try {
      await client.connect();
    } catch (e) {
      client.disconnect();
      rethrow;
    }

    _client = client;
    return _client!;
  }

  /// Disconnects the MQTT client and clears the instance.
  void disconnect() {
    _client?.disconnect();
    _client = null;
  }

  /// Publishes a message to the given topic with specified QoS.
  Future<void> publish(String topic, String payload, {MqttQos qos = MqttQos.atLeastOnce}) async {
    final dataBytes = utf8.encode(payload);
    final buffer = Uint8Buffer();
    buffer.addAll(dataBytes);
    _client?.publishMessage(topic, qos, buffer);
  }

  /// Returns true if the client is currently connected.
  bool isConnected() => _client?.connectionStatus?.state == MqttConnectionState.connected;
}
