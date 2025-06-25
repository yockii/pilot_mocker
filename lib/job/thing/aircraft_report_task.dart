import 'dart:async';
import 'dart:convert';

import 'package:pilot_mocker/config/mocker.dart';
import 'package:pilot_mocker/model/aircraft.dart';
import 'package:pilot_mocker/client/shared_client_isolate.dart'; // for SharedClientIsolate
import 'package:pilot_mocker/job/task_manager.dart'; // for ScheduledTask
import 'package:pilot_mocker/job/thing/schema_manager.dart';  // for SchemaManager
import 'package:uuid/uuid.dart';

/// A scheduled task that periodically publishes aircraft model data to MQTT.
class AircraftReportTask implements ScheduledTask {
  Timer? _timer;
  final Duration interval;
  final AircraftModel _aircraft;
  final SharedClientIsolate _client;
  late final Future<SchemaManager> _schemaFuture;

  final Uuid _uuid = const Uuid();

  AircraftReportTask(this._aircraft, this._client, {this.interval = const Duration(seconds: 5)}) {
    // load schema config from executable's schema folder
    _schemaFuture = SchemaManager.load('aircraft_schema.json');
  }

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
    if (!await _client.mqttIsConnected()) return;
    final manager = await _schemaFuture;
    // generate and send gateway payload
    final gatewayData = manager.generateForKey('gateway') as Map<String, dynamic>?;
    if (gatewayData != null) {
      // inject dynamic fields
      gatewayData['bid'] = _uuid.v4();
      gatewayData['tid'] = _uuid.v4();
      gatewayData['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      gatewayData['gateway_sn'] = gatewaySerialNumber;
      final payloadStr = jsonEncode(gatewayData);
      await _client.mqttPublish('thing/product/$gatewaySerialNumber/osd', payloadStr);
    }
    // generate and send aircraft payload if available
    if (_aircraft.serialNumber.isNotEmpty) {
      final osdData = manager.generateForKey('osd') as Map<String, dynamic>?;
      if (osdData != null) {
        osdData['bid'] = _uuid.v4();
        osdData['tid'] = _uuid.v4();
        osdData['timestamp'] = DateTime.now().millisecondsSinceEpoch;
        osdData['gateway_sn'] = gatewaySerialNumber;
        // insert dynamic aircraft fields
        osdData['data'] ??= [];
        osdData['data'].add({
          'sn': _aircraft.serialNumber,
        });
        final payloadStr = jsonEncode(osdData);
        await _client.mqttPublish('thing/product/${_aircraft.serialNumber}/osd', payloadStr);
      }
    }
  }

  /// Stops the scheduled task.
  @override
  void stop() {
    _timer?.cancel();
  }
}
