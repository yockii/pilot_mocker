// Singleton MQTT5 client wrapper with auto TCP/WebSocket transport selection
import 'dart:async';
import 'shared_client_isolate.dart';

class MqttClientSingleton {
  // Private constructor
  MqttClientSingleton._internal();

  static final MqttClientSingleton _instance = MqttClientSingleton._internal();
  factory MqttClientSingleton() => _instance;

  // Delegates to shared isolate

  /// Connects to the MQTT broker at [url] with [clientId], and optional [username], [password], [port].
  Future<void> connect({
    required String url,
    required String clientId,
    String? username,
    String? password,
    int? port,
    bool cleanSession = true,
    int keepAliveSec = 60,
  }) async {
    await SharedClientIsolate().mqttConnect(
      url: url,
      clientId: clientId,
      username: username,
      password: password,
      port: port,
      keepAliveSec: keepAliveSec,
    );
  }

  /// Disconnects the MQTT client.
  void disconnect() {
    SharedClientIsolate().mqttDisconnect();
  }
}
