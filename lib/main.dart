import 'dart:async';

import 'package:candle_dash/bluetooth/bluetooth_manager.dart';
import 'package:candle_dash/dash/dash_manager.dart';
import 'package:candle_dash/material_app.dart';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:candle_dash/update_manager.dart';
import 'package:candle_dash/utils.dart';
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
  late final UpdateManager _updateManager;
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
    _bluetoothManager.addListener(_onBluetoothEvent);

    _updateManager = UpdateManager(_appSettings, _bluetoothManager);

    _appSettings.init().then((_) {
      _bluetoothManager.init();
      _updateManager.init();
    });

    // _appSettings.init().then((_) => _bluetoothManager.targetDeviceId = _appSettings.selectedDeviceId);

    // _connectionStateStreamSubscription = _bluetoothManager.globalConnectionStateStream.listen((state) async {
    //   if (state == BluetoothConnectionState.connected && _bluetoothManager.currentDevice != null) {
    //     setState(() => _vehicle = Vehicle());
    //     try {
    //       await _vehicle!.init(_bluetoothManager.currentDevice!).onError((error, stackTrace) => null);
    //     } on PlatformException {
    //       debugPrint('Vehicle init failed!');
    //     }

    //   } else if (state == BluetoothConnectionState.disconnected) {
    //     _vehicle?.dispose();
    //     setState(() => _vehicle = null);
    //   }
    // });

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
        ChangeNotifierProvider.value(value: _dashManager),
        ChangeNotifierProvider.value(value: _bluetoothManager),
        ChangeNotifierProvider.value(value: _updateManager),
        ChangeNotifierProvider.value(value: _vehicle),
      ],
      child: MyMaterialApp(
        suggestedThemeMode: _suggestedThemeMode,
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
      _createVehicle(_bluetoothManager.currentDevice!);
    } else {
      _vehicle?.dispose();
      setState(() => _vehicle = null);
    }
  }

  Future<void> _createVehicle(BluetoothDevice device) async {
    if (_vehicle != null) return;
    setState(() => _vehicle = Vehicle());

    await _vehicle!.init(device).catchError((err) => debugPrint(err.toString()));
  }

  void _onLightSensorUpdate(int lux) {
    _lightSensorValues.add(lux);
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
    if (mode == _suggestedThemeMode) return;
    setState(() => _suggestedThemeMode = mode);
  }
}