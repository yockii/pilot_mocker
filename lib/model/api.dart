import 'package:flutter/foundation.dart';

class ApiModel with ChangeNotifier {
  String _apiUrl = '';
  String _token = '';

  String get apiUrl => _apiUrl;
  String get token => _token;

  void setApiUrl(String url) {
    _apiUrl = url;
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setAll(String url, String token) {
    _apiUrl = url;
    _token = token;
    notifyListeners();
  }

  void clear() {
    _apiUrl = '';
    _token = '';
    notifyListeners();
  }
}
