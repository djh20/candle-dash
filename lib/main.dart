import 'dart:async';

import 'package:candle_dash/managers/bluetooth_manager.dart';
import 'package:candle_dash/managers/dash_manager.dart';
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
  StreamSubscription<ScreenStateEvent>? screenSubscription;

  final appSettings = AppSettings();
  final bluetoothManager = BluetoothManager();
  final dashManager = DashManager();
  Vehicle? vehicle;

  late StreamSubscription<BluetoothConnectionState?> connectionStateStreamSubscription;
  late StreamSubscription<int> lightSensorStreamSubscription;
  final List<int> lightSensorValues = [];
  late final Timer themeUpdateTimer;

  ThemeMode suggestedThemeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    bluetoothManager.init();
    appSettings.init();

    connectionStateStreamSubscription = bluetoothManager.globalConnectionStateStream.listen((state) async {
      if (state == BluetoothConnectionState.connected && bluetoothManager.currentDevice != null) {
        setState(() => vehicle = Vehicle());
        try {
          await vehicle!.init(bluetoothManager.currentDevice!).onError((error, stackTrace) => null);
        } on PlatformException {
          debugPrint('Vehicle init failed!');
        }

      } else if (state == BluetoothConnectionState.disconnected) {
        vehicle?.dispose();
        setState(() => vehicle = null);
      }
    });

    _screen = Screen();
    try {
      screenSubscription = _screen.screenStateStream?.listen(onScreenEvent);
    } on ScreenStateException catch (exception) {
      debugPrint(exception.toString());
    }

    lightSensorStreamSubscription = LightSensor.luxStream().listen(onLightSensorUpdate);
    themeUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) => updateSuggestedThemeMode());
  }

  void onScreenEvent(ScreenStateEvent event) {
    if (event == ScreenStateEvent.SCREEN_OFF) {
      bluetoothManager.disable();

    } else if (event == ScreenStateEvent.SCREEN_ON) {
      bluetoothManager.enable();
    }
  }

  void onLightSensorUpdate(int lux) {
    lightSensorValues.add(lux);
  }

  void updateSuggestedThemeMode() {
    if (lightSensorValues.isEmpty) return;

    final luxMedian = calculateMedian(lightSensorValues);
    if (luxMedian >= 300) {
      setSuggestedThemeMode(ThemeMode.light);
    } else if (luxMedian <= 30) {
      setSuggestedThemeMode(ThemeMode.dark);
    }
    lightSensorValues.clear();
  }

  void setSuggestedThemeMode(ThemeMode mode) {
    if (mode == suggestedThemeMode) return;
    setState(() => suggestedThemeMode = mode);
  }

  @override
  void dispose() {
    connectionStateStreamSubscription.cancel();
    bluetoothManager.dispose();
    screenSubscription?.cancel();
    lightSensorStreamSubscription.cancel();
    themeUpdateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appSettings),
        ChangeNotifierProvider.value(value: bluetoothManager),
        ChangeNotifierProvider.value(value: dashManager),
        ChangeNotifierProvider.value(value: vehicle),
      ],
      child: MyMaterialApp(
        suggestedThemeMode: suggestedThemeMode,
      ),
    );
  }
}