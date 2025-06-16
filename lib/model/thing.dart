import 'package:flutter/material.dart';

class ThingModel with ChangeNotifier {
  String _host = '';
  String _connectCallback = '';
  String _username = '';
  String _password = '';

  String get host => _host;
  String get connectCallback => _connectCallback;
  String get username => _username;
  String get password => _password;

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }
  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }
  void setHost(String host) {
    _host = host;
    notifyListeners();
  }
  void setConnectCallback(String connectCallback) {
    _connectCallback = connectCallback;
    notifyListeners();
  }

  void clear() {
    _host = '';
    _connectCallback = '';
    _username = '';
    _password = '';
    notifyListeners();
  }
}
