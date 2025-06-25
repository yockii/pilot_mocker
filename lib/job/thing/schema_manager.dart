import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

/// Manages loading of JSON schema files and generating payloads based on rules.
class SchemaManager {
  final Map<String, dynamic> _schema;
  final Random _random = Random();
  final Uuid _uuid = const Uuid();
  final int _startEpoch;

  SchemaManager._(this._schema) : _startEpoch = DateTime.now().millisecondsSinceEpoch;

  /// Loads a schema JSON from `schema/filename` relative to current directory.
  static Future<SchemaManager> load(String filename) async {
    final dir = Directory.current;
    final file = File(path.join(dir.path, 'schema', filename));
    if (!await file.exists()) {
      return SchemaManager._({});
    }
    final content = await file.readAsString();
    final jsonMap = jsonDecode(content) as Map<String, dynamic>;
    return SchemaManager._(jsonMap);
  }

  /// Recursively generate data based on a rule or static value.
  dynamic _generate(dynamic rule) {
    if (rule is Map<String, dynamic> && rule.containsKey('_rule')) {
      final r = rule['_rule'] as Map<String, dynamic>;
      final type = r['type'] as String?;
      switch (type) {
        case 'int':
          final min = r['min'] as int? ?? 0;
          final max = r['max'] as int? ?? min;
          return min + _random.nextInt(max - min + 1);
        case 'double':
          final minD = (r['min'] as num?)?.toDouble() ?? 0;
          final maxD = (r['max'] as num?)?.toDouble() ?? minD;
          return _random.nextDouble() * (maxD - minD) + minD;
        case 'uuid':
          return _uuid.v4();
        case 'timestamp':
          return DateTime.now().millisecondsSinceEpoch;
        case 'string':
          return r['value']?.toString() ?? '';
        case 'linear':
          final initial = (r['initial'] as num?)?.toInt() ?? 0;
          final unit = (r['unit'] as String?)?.toLowerCase() ?? 's';
          final nowMs = DateTime.now().millisecondsSinceEpoch;
          final elapsed = nowMs - _startEpoch;
          if (unit == 's') {
            return initial + (elapsed ~/ 1000);
          } else if (unit == 'ms') {
            return initial + elapsed;
          }
          return initial;
        case 'object':
          final props = r['properties'] as Map<String, dynamic>?;
          return props?.map((k, v) => MapEntry(k, _generate(v))) ?? {};
        case 'array':
          final items = r['items'];
          final count = r['count'] as int? ?? 0;
          return List.generate(count, (_) => _generate(items));
        default:
          return null;
      }
    } else if (rule is Map<String, dynamic>) {
      return rule.map((k, v) => MapEntry(k, _generate(v)));
    } else if (rule is List) {
      return rule.map(_generate).toList();
    }
    // Static or unrecognized type
    return rule;
  }

  /// Generate a full payload based on loaded schema.
  Map<String, dynamic> generate() {
    return _schema.map((k, v) => MapEntry(k, _generate(v)));
  }

  /// Generate a data structure for a specific top-level key in the schema.
  dynamic generateForKey(String key) {
    if (!_schema.containsKey(key)) return null;
    return _generate(_schema[key]);
  }
}
