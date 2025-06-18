import 'package:flutter/foundation.dart';

// 飞行器，domain=0
class AircraftModel with ChangeNotifier {
  String _name = '';
  int _type = 0;
  int _subType = 0;
  String _serialNumber = '';

  String get name => _name;
  int get type => _type;
  int get subType => _subType;
  String get serialNumber => _serialNumber;

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setType(int type) {
    _type = type;
    notifyListeners();
  }

  void setSubType(int subType) {
    _subType = subType;
    notifyListeners();
  }

  void setSerialNumber(String serialNumber) {
    _serialNumber = serialNumber;
    notifyListeners();
  }

  void setAll(String name, int type, int subType, String serialNumber) {
    _name = name;
    _type = type;
    _subType = subType;
    _serialNumber = serialNumber;
    notifyListeners();
  }

  void clear() {
    _name = '';
    _type = 0;
    _subType = 0;
    _serialNumber = '';
    notifyListeners();
  }

}