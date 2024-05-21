import 'dart:async';
import 'dart:io';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager with ChangeNotifier {
  BluetoothDevice? currentDevice;

  BluetoothConnectionState connectionState = BluetoothConnectionState.disconnected;
  bool get connected => connectionState == BluetoothConnectionState.connected;
  bool enabled = true;
  bool scanning = false;
  bool connecting = false;
  String? statusMessage;
  List<ScanResult> scanResults = [];
  
  int _countdown = 0;
  int _countdownStart = 5;

  String? _targetDeviceId;
  AppSettings _appSettings;

  final _globalConnectionStateStreamController = StreamController<BluetoothConnectionState?>.broadcast();
  Stream<BluetoothConnectionState?> get globalConnectionStateStream => _globalConnectionStateStreamController.stream;

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _scanningSubscription;

  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  late Timer _countdownPeriodicTimer;
  // Timer? _reconnectTimer;
  Completer<BluetoothDevice?>? _targetDeviceCompleter;

  BluetoothManager(AppSettings settings) :
    _appSettings = settings;

  void init() {
    FlutterBluePlus.setLogLevel(LogLevel.error, color: false);
    
    _targetDeviceId = _appSettings.selectedDeviceId;

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      notifyListeners();
    });

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(_onScanResults);

    _scanningSubscription = FlutterBluePlus.isScanning.listen(_onScanStateUpdate);

    _countdownPeriodicTimer = Timer.periodic(
      const Duration(seconds: 1), 
      (_) => _doCountdown(),
    );

    _appSettings.addListener(_onSettingsUpdate);
  }

  @override
  void dispose() {
    _appSettings.removeListener(_onSettingsUpdate);
    _adapterStateSubscription.cancel();
    _scanResultsSubscription.cancel();
    _scanningSubscription.cancel();
    _countdownPeriodicTimer.cancel();
    super.dispose();
  }

  Future<void> startScan() async {
    if (scanning) return;

    if (_adapterState != BluetoothAdapterState.on) {
      debugPrint('Turning on bluetooth');
      if (Platform.isAndroid) {
        try {
          await FlutterBluePlus.turnOn();
        } on PlatformException catch (err) {
          debugPrint(err.toString());
        }
      }
    }

    /// Android is slow when asking for all advertisments,
    /// so instead we only ask for 1/8 of them.
    int divisor = Platform.isAndroid ? 8 : 1;
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      continuousUpdates: true,
      continuousDivisor: divisor,
    );
  }

  Future<void> stopScan() async {
    if (!scanning) return;
    await FlutterBluePlus.stopScan();
  }

  Future<void> toggleScan() async {
    if (scanning) {
      await stopScan();
    } else {
      await startScan();
    }
  }

  Future<void> connectToTargetDevice() async {
    if (!enabled || _targetDeviceId == null) return;

    connecting = true;

    BluetoothDevice? device = _getTargetDeviceFromScan();

    if (device == null) {
      statusMessage = 'Searching for target device';
      notifyListeners();
      debugPrint(statusMessage);
      
      _targetDeviceCompleter = Completer();
      await startScan();
      device = await _targetDeviceCompleter!.future;
    }

    if (device != null) {
      await connectToDevice(device);
    } else {
      statusMessage = 'Failed to find target device';
      notifyListeners();
      _countdown = 5;
      debugPrint(statusMessage);
    }

    connecting = false;
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (!enabled) return;
    debugPrint('Connecting to ${device.advName} (${device.remoteId.str})');
    statusMessage = 'MAC: ${device.remoteId.str}';
    
    _connectionStateSubscription = device.connectionState.listen(_updateConnectionState);

    connecting = true;
    currentDevice = device;
    // selectedDeviceId = device.remoteId.str;
    notifyListeners();

    try {
      await device.connect(timeout: const Duration(seconds: 5), mtu: 115);
      debugPrint('Connected to ${device.advName} (${device.remoteId.str})');

    } on FlutterBluePlusException catch (err) {
      debugPrint(err.toString());
      statusMessage = 'Failed to connect';
      notifyListeners();
      _countdown = 5;
      await disconnect();
      // scheduleReconnect();
    }
  }

  Future<void> disconnect() async {
    connecting = false;
    _updateConnectionState(BluetoothConnectionState.disconnected);
    notifyListeners();
    
    await currentDevice?.disconnect(queue: false);
    _connectionStateSubscription?.cancel();
    currentDevice = null;
    notifyListeners();
  }

  Future<void> enable() async {
    enabled = true;
    _countdown = 0;
  }

  Future<void> disable() async {
    enabled = false;
    await stopScan();
    await disconnect();
  }

  void _onSettingsUpdate() {
    if (_targetDeviceId != _appSettings.selectedDeviceId) {
      _targetDeviceId = _appSettings.selectedDeviceId;
      disconnect();
    }
  }

  Future<void> _doCountdown() async {
    if (!enabled || _targetDeviceId == null) return;
    if (connecting || connectionState == BluetoothConnectionState.connected) return;

    if (_countdown > 0) {
      _countdown--;
      statusMessage = 'Retrying in ${_countdown}s';
      notifyListeners();
    }

    if (_countdown <= 0) await connectToTargetDevice();
  }

  void _onScanStateUpdate(bool state) {
    scanning = state;
    notifyListeners();

    if (!scanning) {
      _targetDeviceCompleter?.complete(null);
      _targetDeviceCompleter = null;
    }
  }

  Future<void> _onScanResults(List<ScanResult> results) async {
    scanResults = results;
    notifyListeners();

    if (_targetDeviceCompleter != null) {
      final targetDevice = _getTargetDeviceFromScan();
      if (targetDevice != null) {
        _targetDeviceCompleter!.complete(targetDevice);
        _targetDeviceCompleter = null;
        await stopScan();
      }
    }
  }

  BluetoothDevice? _getTargetDeviceFromScan() {
    return scanResults.firstWhereOrNull((r) => r.device.remoteId.str == _targetDeviceId)?.device;
  }

  void _updateConnectionState(BluetoothConnectionState state) {
    if (connectionState == state) return;

    if (state == BluetoothConnectionState.connected) {
      connecting = false;
    }

    connectionState = state;
    notifyListeners();
    _globalConnectionStateStreamController.add(state);
  }
}