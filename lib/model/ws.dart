import 'package:flutter/foundation.dart';

class WsModel with ChangeNotifier {
  String _host = '';
  String _token = '';
  String _connectCallback = '';

  String get host => _host;
  String get token => _token;
  String get connectCallback => _connectCallback; 

  void setHost(String host) {
    _host = host;
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setConnectCallback(String connectCallback) {
    _connectCallback = connectCallback;
    notifyListeners();
  }

  void setAll(String host, String token, String connectCallback) {
    _host = host;
    _token = token;
    _connectCallback = connectCallback;
    notifyListeners();
  }

  void clear() {
    _host = '';
    _token = '';
    _connectCallback = '';
    notifyListeners();
  }
}