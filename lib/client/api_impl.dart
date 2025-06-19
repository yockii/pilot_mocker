// Concrete implementation of API client for use inside the isolate
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClientImpl {
  String _host = '';
  String _token = '';

  /// Set the API host base URL
  void setHost(String host) {
    _host = host;
  }

  /// Set the authentication token for requests
  void setToken(String token) {
    _token = token;
  }

  /// Generic HTTP request
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
        return await http.post(uri, headers: reqHeaders, body: json.encode(body));
      case 'PUT':
        return await http.put(uri, headers: reqHeaders, body: json.encode(body));
      case 'DELETE':
        return await http.delete(uri, headers: reqHeaders, body: json.encode(body));
      default:
        return await http.get(uri, headers: reqHeaders);
    }
  }
}
