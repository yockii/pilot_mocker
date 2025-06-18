import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pilot_mocker/model/aircraft.dart';
import 'package:provider/provider.dart';

class AircraftSelection extends StatefulWidget {
  const AircraftSelection({super.key});

  @override
  State<AircraftSelection> createState() => _AircraftSelectionState();
}

class _AircraftSelectionState extends State<AircraftSelection> {
  List<AircraftItem> aircraftList = [];
  List<Gimbal> gimbalList = [];
  AircraftItem? selectedAircraft;
  List<Gimbal> selectedGimbals = [];

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final aircraftJson = await rootBundle.loadString('assets/def/aircraft.json');
    final gimbalJson = await rootBundle.loadString('assets/def/gimbal.json');
    setState(() {
      aircraftList = (json.decode(aircraftJson) as List).map((e) => AircraftItem.fromJson(e as Map<String, dynamic>)).toList();
      gimbalList = (json.decode(gimbalJson) as List).map((e) => Gimbal.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final aircraftModel = Provider.of<AircraftModel>(context);

    // 如果已有模型且不在编辑模式，显示信息和编辑按钮
    if (aircraftModel.name.isNotEmpty && !isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aircraft: ${aircraftModel.name}'),
          Text('Type: ${aircraftModel.type}'),
          Text('SubType: ${aircraftModel.subType}'),
          Text('Serial: ${aircraftModel.serialNumber}'),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() => isEditing = true),
            child: Text('Edit'),
          ),
        ],
      );
    }
    // 正常选择或编辑模式
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        DropdownButton<AircraftItem>(
          value: selectedAircraft,
          hint: Text('Choose Aircraft'),
          isExpanded: true,
          items:
              aircraftList.map((air) {
                return DropdownMenuItem(value: air, child: Text(air.name));
              }).toList(),
          onChanged: (air) {
            setState(() {
              selectedAircraft = air;
              selectedGimbals.clear();
              selectedGimbals.addAll(air?.embedGimbals.map((id) => gimbalList.firstWhere((g) => g.id == id)) ?? []);
            });
          },
        ),
        if(selectedAircraft != null) Text('序列号: ${selectedAircraft?.serialNumber ?? ''}'),
        if (selectedAircraft != null)
          // 多选负载平铺展示
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  gimbalList.where((g) => selectedAircraft!.embedGimbals.contains(g.id) || selectedAircraft!.compatibleGimbals.contains(g.id)).map((g) {
                    final selected = selectedGimbals.contains(g);
                    return FilterChip(
                      label: Text(g.name),
                      selected: selected,
                      onSelected: (checked) {
                        setState(() {
                          if (checked) {
                            selectedGimbals.add(g);
                          } else {
                            selectedGimbals.remove(g);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
          ),
        SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [ElevatedButton(onPressed: selectedAircraft != null ? () {
            Provider.of<AircraftModel>(context, listen: false).setAll(
              selectedAircraft!.name,
              selectedAircraft!.type,
              selectedAircraft!.subType,
              selectedAircraft!.serialNumber,
            );
            // 完成后退出编辑模式
            setState(() => isEditing = false);
          } : null, child: Text('确定'))]),
      ],
    );
  }
}

// 飞行器数据
class AircraftItem {
  final String id;
  final String serialNumber;
  final String name;
  final int type;
  final int subType;
  final List<String> embedGimbals;
  final List<String> compatibleGimbals;
  AircraftItem({required this.id, required this.serialNumber, required this.name, required this.type, required this.subType, required this.embedGimbals, required this.compatibleGimbals});
  factory AircraftItem.fromJson(Map<String, dynamic> json) => AircraftItem(
    id: json['id'] as String,
    serialNumber: json['serialNumber'] as String,
    name: json['name'] as String,
    type: json['type'] as int,
    subType: json['subType'] as int,
    embedGimbals: List<String>.from(json['embedGimbals'] as List<dynamic>),
    compatibleGimbals: List<String>.from(json['compatibleGimbals'] as List<dynamic>),
  );
}

// 负载卡口
class Gimbal {
  final String id;
  final String name;
  Gimbal({required this.id, required this.name});
  factory Gimbal.fromJson(Map<String, dynamic> json) => Gimbal(id: json['id'] as String, name: json['name'] as String);
}
