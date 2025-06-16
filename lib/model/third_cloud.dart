import 'package:flutter/foundation.dart';

class ThirdCloudModel extends ChangeNotifier {
  String _platformName = '';
  String _workspaceName = '';
  String _desc = '';

  String get platformName => _platformName;
  String get workspaceName => _workspaceName;
  String get desc => _desc;

  void setPlatformName(String platformName) {
    _platformName = platformName;
    notifyListeners();
  }

  void setWorkspaceName(String workspaceName) {
    _workspaceName = workspaceName;
    notifyListeners();
  }

  void setDesc(String desc) {
    _desc = desc;
    notifyListeners();
  }

  // 同时设置
  void setAll(String platformName, String workspaceName, String desc) {
    _platformName = platformName;
    _workspaceName = workspaceName;
    _desc = desc;
    notifyListeners();
  }

  void clear() {
    _platformName = '';
    _workspaceName = '';
    _desc = '';
    notifyListeners();
  }
}
