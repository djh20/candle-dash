import 'dart:async';

import 'package:candle_dash/bluetooth/bluetooth_manager.dart';
import 'package:candle_dash/dash/dash_manager.dart';
import 'package:candle_dash/material_app.dart';
import 'package:candle_dash/ota/app_updater.dart';
import 'package:candle_dash/ota/firmware_updater.dart';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:candle_dash/utils.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_state/screen_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode? suggestedThemeMode;

  late Screen _screen;
  StreamSubscription<ScreenStateEvent>? _screenSubscription;

  final _appSettings = AppSettings();
  final _dashManager = DashManager();
  late final BluetoothManager _bluetoothManager;
  late final AppUpdater _appUpdater;
  FirmwareUpdater? _firmwareUpdater;
  Vehicle? _vehicle;

  late StreamSubscription<int> _lightSensorStreamSubscription;
  final List<int> _lightSensorValues = [];
  late final Timer _themeUpdateTimer;

  @override
  void initState() {
    super.initState();
    _bluetoothManager = BluetoothManager(_appSettings);
    _bluetoothManager.addListener(_onBluetoothEvent);

    _appUpdater = AppUpdater(_appSettings);

    _appSettings.init().then((_) {
      _bluetoothManager.init();
      _appUpdater.init();
    });

    _screen = Screen();
    try {
      _screenSubscription = _screen.screenStateStream?.listen(_onScreenEvent);
    } on ScreenStateException catch (exception) {
      debugPrint(exception.toString());
    }

    _lightSensorStreamSubscription = LightSensor.luxStream().listen(_onLightSensorUpdate);
    _themeUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) => _updateSuggestedThemeMode());
  }

  @override
  void dispose() {
    _bluetoothManager.removeListener(_onBluetoothEvent);
    _bluetoothManager.dispose();
    _screenSubscription?.cancel();
    _lightSensorStreamSubscription.cancel();
    _themeUpdateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _appSettings),
        ChangeNotifierProvider.value(value: _dashManager),
        ChangeNotifierProvider.value(value: _bluetoothManager),
        ChangeNotifierProvider.value(value: _appUpdater),
        ChangeNotifierProvider.value(value: _firmwareUpdater),
        ChangeNotifierProvider.value(value: _vehicle),
      ],
      child: MyMaterialApp(
        suggestedThemeMode: suggestedThemeMode ?? ThemeMode.light,
      ),
    );
  }

  void _onScreenEvent(ScreenStateEvent event) {
    if (event == ScreenStateEvent.SCREEN_OFF) {
      _bluetoothManager.disable();

    } else if (event == ScreenStateEvent.SCREEN_ON) {
      _bluetoothManager.enable();
    }
  }

  void _onBluetoothEvent() {
    if (_bluetoothManager.isConnected && _bluetoothManager.currentDevice != null) {
      final device = _bluetoothManager.currentDevice!;

      if (_vehicle == null) {
        setState(() => _vehicle = Vehicle());
        _vehicle!.init(device);
      }

      if (_firmwareUpdater == null) {
        setState(() => _firmwareUpdater = FirmwareUpdater(_appSettings, device));
        _firmwareUpdater!.init();
      }
      
    } else {
      if (_vehicle != null) {
        _vehicle?.dispose();
        setState(() => _vehicle = null);
      }

      if (_firmwareUpdater != null) {
        setState(() => _firmwareUpdater = null);
      }
    }
  }

  void _onLightSensorUpdate(int lux) {
    _lightSensorValues.add(lux);
    if (suggestedThemeMode == null) _updateSuggestedThemeMode();
  }

  void _updateSuggestedThemeMode() {
    if (_lightSensorValues.isEmpty) return;

    final luxMedian = calculateMedian(_lightSensorValues);
    if (luxMedian >= 300) {
      _setSuggestedThemeMode(ThemeMode.light);
    } else if (luxMedian <= 30) {
      _setSuggestedThemeMode(ThemeMode.dark);
    }
    _lightSensorValues.clear();
  }

  void _setSuggestedThemeMode(ThemeMode mode) {
    if (mode == suggestedThemeMode) return;
    setState(() => suggestedThemeMode = mode);
  }
}