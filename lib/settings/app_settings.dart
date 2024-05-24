import 'dart:convert';

import 'package:candle_dash/bluetooth/known_bluetooth_device.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeSetting {
  auto('Auto'),
  light('Light'),
  dark('Dark');

  const ThemeSetting(this.name);
  final String name;
}

class AppSettings with ChangeNotifier {
  bool isLoaded = false;

  late SharedPreferences _prefs;

  ThemeSetting? theme;
  List<KnownBluetoothDevice>? knownDevices;
  String? selectedDeviceId;
  bool? experimentalMode;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    theme = ThemeSetting.values[_prefs.getInt('theme') ?? 0];

    knownDevices = (_prefs.getStringList('knownDevices') ?? <String>[]).map(
      (json) => KnownBluetoothDevice.fromJson(jsonDecode(json)),
    ).toList();

    selectedDeviceId = _prefs.getString('selectedDeviceId');
    experimentalMode = _prefs.getBool('experimentalMode') ?? false;

    isLoaded = true;
    notifyListeners();
    debugPrint('Loaded settings');
  }

  Future<void> save() async {
    if (!isLoaded) return;

    _prefs.setInt('theme', theme!.index);
    
    _prefs.setStringList('knownDevices', knownDevices!.map((d) => jsonEncode(d)).toList());
    selectedDeviceId != null ? _prefs.setString('selectedDeviceId', selectedDeviceId!) : _prefs.remove('selectedDeviceId');
    
    _prefs.setBool('experimentalMode', experimentalMode!);
    
    debugPrint('Saved settings');
  }

  Future<void> update(Function(AppSettings s) callback) async {
    callback(this);
    notifyListeners();
    await save();
  }
  
  KnownBluetoothDevice? get selectedDevice {
    if (knownDevices != null && selectedDeviceId != null) {
      return knownDevices!.firstWhereOrNull((d) => d.id == selectedDeviceId);
    } else {
      return null;
    }
  }

  Future<void> addKnownDevice(String id, String name) async {
    if (knownDevices == null || knownDevices!.any((d) => d.id == id)) return;

    await update((_) => knownDevices!.add(KnownBluetoothDevice(id: id, name: name)));
  }

  Future<void> removeKnownDevice(String id) async {
    if (knownDevices == null) return;
    
    await update((_) {
      knownDevices!.removeWhere((d) => d.id == id);
      if (selectedDeviceId == id) selectedDeviceId = null;
    });
  }
}