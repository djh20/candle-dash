import 'dart:async';

import 'package:candle_dash/bluetooth/bluetooth_manager.dart';
import 'package:candle_dash/dash/dash_manager.dart';
import 'package:candle_dash/material_app.dart';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:candle_dash/utils.dart';
import 'package:flutter/services.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
  late Screen _screen;
  StreamSubscription<ScreenStateEvent>? _screenSubscription;

  final _appSettings = AppSettings();
  final _dashManager = DashManager();
  late final BluetoothManager _bluetoothManager;
  Vehicle? _vehicle;

  late StreamSubscription<BluetoothConnectionState?> _connectionStateStreamSubscription;
  late StreamSubscription<int> _lightSensorStreamSubscription;
  final List<int> _lightSensorValues = [];
  late final Timer _themeUpdateTimer;

  ThemeMode _suggestedThemeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _bluetoothManager = BluetoothManager(_appSettings);

    _appSettings.init().then((_) {
      _bluetoothManager.init();
    });

    // _appSettings.init().then((_) => _bluetoothManager.targetDeviceId = _appSettings.selectedDeviceId);

    _connectionStateStreamSubscription = _bluetoothManager.globalConnectionStateStream.listen((state) async {
      if (state == BluetoothConnectionState.connected && _bluetoothManager.currentDevice != null) {
        setState(() => _vehicle = Vehicle());
        try {
          await _vehicle!.init(_bluetoothManager.currentDevice!).onError((error, stackTrace) => null);
        } on PlatformException {
          debugPrint('Vehicle init failed!');
        }

      } else if (state == BluetoothConnectionState.disconnected) {
        _vehicle?.dispose();
        setState(() => _vehicle = null);
      }
    });

    _screen = Screen();
    try {
      _screenSubscription = _screen.screenStateStream?.listen(onScreenEvent);
    } on ScreenStateException catch (exception) {
      debugPrint(exception.toString());
    }

    _lightSensorStreamSubscription = LightSensor.luxStream().listen(onLightSensorUpdate);
    _themeUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) => updateSuggestedThemeMode());
  }

  void onScreenEvent(ScreenStateEvent event) {
    if (event == ScreenStateEvent.SCREEN_OFF) {
      _bluetoothManager.disable();

    } else if (event == ScreenStateEvent.SCREEN_ON) {
      _bluetoothManager.enable();
    }
  }

  void onLightSensorUpdate(int lux) {
    _lightSensorValues.add(lux);
  }

  void updateSuggestedThemeMode() {
    if (_lightSensorValues.isEmpty) return;

    final luxMedian = calculateMedian(_lightSensorValues);
    if (luxMedian >= 300) {
      setSuggestedThemeMode(ThemeMode.light);
    } else if (luxMedian <= 30) {
      setSuggestedThemeMode(ThemeMode.dark);
    }
    _lightSensorValues.clear();
  }

  void setSuggestedThemeMode(ThemeMode mode) {
    if (mode == _suggestedThemeMode) return;
    setState(() => _suggestedThemeMode = mode);
  }

  @override
  void dispose() {
    _connectionStateStreamSubscription.cancel();
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
        ChangeNotifierProvider.value(value: _bluetoothManager),
        ChangeNotifierProvider.value(value: _dashManager),
        ChangeNotifierProvider.value(value: _vehicle),
      ],
      child: MyMaterialApp(
        suggestedThemeMode: _suggestedThemeMode,
      ),
    );
  }
}