import 'dart:async';
import 'dart:convert';

import 'package:pilot_mocker/config/mocker.dart';
import 'package:pilot_mocker/model/aircraft.dart';
import 'package:pilot_mocker/client/shared_client_isolate.dart'; // for SharedClientIsolate
import 'package:pilot_mocker/job/task_manager.dart'; // for ScheduledTask
import 'package:uuid/uuid.dart';

/// A scheduled task that periodically publishes aircraft model data to MQTT.
class AircraftReportTask implements ScheduledTask {
  Timer? _timer;
  final Duration interval;
  final AircraftModel _aircraft;
  final SharedClientIsolate _client;

  final Uuid _uuid = const Uuid();
  int _startTime = 0;

  AircraftReportTask(this._aircraft, this._client, {this.interval = const Duration(seconds: 5)});

  /// Starts the task, immediately sending data and then periodically at [interval].
  @override
  void start() {
    // schedule first tick asynchronously
    Future(() => _tick());
    // schedule periodic ticks asynchronously
    _timer = Timer.periodic(interval, (_) {
      Future(() => _tick());
    });
  }

  Future<void> _tick() async {
    if (await _client.mqttIsConnected()) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final gatewayPayload = jsonEncode({
        'bid': _uuid.v4(),
        'tid': _uuid.v4(),
        'timestamp': now,
        'gateway_sn': gatewaySerialNumber,
        'data': {
          "wireless_link": { // 无线连接信息
            "4g_freq_band": 2.4, // 4G连接使⽤的频段
            "4g_gnd_quality": 0, // 信号质量，0 表示信号差或无信号
            "4g_link_state": 0, // 4G链路状态，0表⽰未连接或链路不可⽤
            "4g_quality": 0, // 4G链路的整体质量，0表⽰质量差或⽆信号
            "4g_uav_quality": 0, //  4G⽆⼈机端的信号质量，0表⽰质量差或⽆信号
            "4g_signal_strength": -85, // 4G信号强度，使⽤RSSI（接收信号强度指示），负数表示信号强度，越接近0信号越好
            "wifi_freq_band": 5, // WiFi连接使⽤的频段
            "wifi_link_state": 1, // WiFi链路状态，1表示已连接
            "wifi_quality": 100, // WiFi链路的整体质量，0表⽰质量差或⽆信号
            "wifi_signal_strength": -70, // WiFi信号强度，负数表示信号强度，越接近0信号越好
          },
        },
      });
      await _client.mqttPublish('thing/product/$gatewaySerialNumber/osd', gatewayPayload);

      if (_aircraft.serialNumber.isNotEmpty) {
        if (_startTime == 0) _startTime = DateTime.now().millisecondsSinceEpoch;
        final payload = jsonEncode({
          'bid': _uuid.v4(),
          'tid': _uuid.v4(),
          'timestamp': now,
          'gateway_sn': gatewaySerialNumber,
          'data': [
            {
              'sn': _aircraft.serialNumber, // 无人机序列号
              'regno': 'UAC_${_aircraft.serialNumber}', // 民航局实名登记号
              'flighttime': (now - _startTime) ~/ 1000, // 飞行时间（秒）
              'longitude': 120.987654, // 经度
              'latitude': 30.123456, // 纬度
              'height': 100.5, // 海拔高度（米）
              'elevation': 50.2, // 相对地面高度（米）
              'horizontal_speed': 15.3, // 水平速度（米/秒）
              'vertical_speed': 2.5, // 垂直速度（米/秒）
              'yaw': 45.0, // 偏航角（度）
              'roll': 10.5, // 翻滚角（度）
              'pitch': 5.0, // 俯仰角（度）
              'battery': {
                // 电池信息
                'batteries': [
                  // 电池列表
                  {
                    'voltage': 15, // 电池电压（伏特）
                    'temperature': 35.5, // 电池温度（摄氏度）
                    'firmware_version': '1.0.0', // 固件版本
                    'loop_times': 50, // 循环次数
                    'capacity_percent': 80, // 剩余电量百分比
                    'sn': 'BAT123456', // 电池序列号
                  },
                  {"voltage": 14, "temperature": 36.0, "firmware_version": "1.0.1", "loop_times": 60, "capacity_percent": 75, "sn": "BAT654321"},
                ],
                "capacity_percent": 80, // 总剩余电量百分比
                "landing_power": 20, // 强制降落电量百分比
                "remain_flight_time": 1200, // 剩余飞行时间（秒）
                "return_home_power": 25, // 返航电量百分比
              },
              "home_latitude": 30.123, // Home点纬度
              "home_longitude": 120.987, // Home点经度
              "home_distance": 500.5, // 距离Home点距离（米）
              "mode": "STABILIZE", // 飞行模式
              "landed": false, // 是否着陆
              "armed": 0, // 上锁标识 0解锁 1上锁
              "mileage": 0, // 累计飞行里程（米）
              "main_current": 0, // 主电机电流（安培）
              "tail_current": 0, // 尾电机电流（安培）
              "main_power": 0, // 主电机功率（瓦特）
              "tail_power": 0, // 尾电机功率（瓦特）
              "main_rpm": 3000, // 主桨转速（转/分钟）
              "tail_rpm": 1500, // 尾桨转速（转/分钟）
              "position_state": {
                // 搜星状态
                "gps_number": 12, // GPS数量
                "rtk_number": 3, // RTK数量
              },
            },
          ],
        });
        await _client.mqttPublish('thing/product/${_aircraft.serialNumber}/osd', payload);
      }
    }
  }

  /// Stops the scheduled task.
  @override
  void stop() {
    _timer?.cancel();
  }
}
