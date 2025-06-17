import 'dart:convert';
import 'package:http/http.dart' as http;

/// Singleton API client that manages host, token, and automatically adds X-Token header.
class ApiClientSingleton {
  ApiClientSingleton._internal();
  static final ApiClientSingleton _instance = ApiClientSingleton._internal();
  factory ApiClientSingleton() => _instance;

  String _host = '';
  String _token = '';

  /// Set the API host base URL (e.g., "https://api.example.com").
  void setHost(String host) {
    _host = host;
  }

  /// Set the authentication token for requests.
  void setToken(String token) {
    _token = token;
  }

  /// Generic HTTP request. [path] is appended to host.
  /// [method] supports GET, POST, PUT, DELETE, defaults to GET.
  /// [headers] for custom headers, [body] for request payload.
  Future<http.Response> request(
    String path, {
    String method = 'GET',
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final uri = Uri.parse('$_host$path');
    // Base headers including JSON content type and auth token
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'X-Auth-Token': _token,
      if (headers != null) ...headers,
    };

    switch (method.toUpperCase()) {
      case 'POST':
        return await http.post(uri,
            headers: requestHeaders, body: json.encode(body));
      case 'PUT':
        return await http.put(uri,
            headers: requestHeaders, body: json.encode(body));
      case 'DELETE':
        return await http.delete(uri,
            headers: requestHeaders, body: json.encode(body));
      default:
        return await http.get(uri, headers: requestHeaders);
    }
  }
}