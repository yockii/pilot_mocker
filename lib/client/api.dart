import 'dart:convert';
import 'package:http/http.dart' as http;
import 'shared_client_isolate.dart';

/// Singleton API client that manages host, token, and automatically adds X-Token header.
class ApiClientSingleton {
  ApiClientSingleton._internal();
  static final ApiClientSingleton _instance = ApiClientSingleton._internal();
  factory ApiClientSingleton() => _instance;

  /// Set the API host base URL (e.g., "https://api.example.com").
  Future<void> setHost(String host) => SharedClientIsolate().apiSetHost(host);

  /// Set the authentication token for requests.
  Future<void> setToken(String token) => SharedClientIsolate().apiSetToken(token);

  /// Generic HTTP request. [path] is appended to host.
  /// [method] supports GET, POST, PUT, DELETE, defaults to GET.
  /// [headers] for custom headers, [body] for request payload.
  Future<http.Response> request(
    String path, {
    String method = 'GET',
    Map<String, String>? headers,
    dynamic body,
  }) {
    return SharedClientIsolate().apiRequest(
      path,
      method: method,
      headers: headers,
      body: body,
    );
  }
}