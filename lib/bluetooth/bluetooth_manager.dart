import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager with ChangeNotifier {
  /// The bluetooth device involved in an ongoing connection attempt or established 
  /// connection.
  BluetoothDevice? currentDevice;

  BluetoothConnectionState connectionState = BluetoothConnectionState.disconnected;
  bool isEnabled = true;
  bool isScanning = false;
  bool isConnecting = false;
  bool get isConnected => connectionState == BluetoothConnectionState.connected;
  List<ScanResult> scanResults = [];

  /// An informative message describing the current task.
  String? statusMessage;

  /// The MAC address of the target device (as specified in app settings).
  String? _targetDeviceId;

  final AppSettings _appSettings;

  /// The number of seconds remaining before attempting to connect/reconnect to the target
  /// device.
  int _countdown = 0;

  /// The total duration (in seconds) of the countdown used for connecting/reconnecting.
  /// 
  /// This is increased by a factor of two whenever a failed connection attempt occurs.
  /// The value is reset to zero after a successful connection or when the bluetooth
  /// manager is re-enabled.
  int _countdownDuration = 0;

  /// Specifies the upper limit of [_countdownDuration].
  static const int _minCountdownDuration = 1;

  /// Specifies the lower limit of [_countdownDuration].
  /// 
  /// This value is ignored on the first connection attempt, which always uses a duration
  /// of zero seconds.
  static const int _maxCountdownDuration = 20;

  /// Runs the [_doCountdown()] method once every second.
  late Timer _countdownPeriodicTimer;

  final _globalConnectionStateStreamController = 
    StreamController<BluetoothConnectionState?>.broadcast();
  
  Stream<BluetoothConnectionState?> get globalConnectionStateStream => 
    _globalConnectionStateStreamController.stream;

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  /// Used during the connection process when scanning for the target device.
  Completer<BluetoothDevice?>? _targetDeviceCompleter;

  BluetoothManager(AppSettings settings) :
    _appSettings = settings;

  void init() {
    FlutterBluePlus.setLogLevel(LogLevel.error, color: false);
    
    _targetDeviceId = _appSettings.selectedDeviceId;

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen(
      (state) => _adapterState = state,
    );
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(_onScanResults);
    _isScanningSubscription = FlutterBluePlus.isScanning.listen(_onScanStateUpdate);

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
    _isScanningSubscription.cancel();
    _countdownPeriodicTimer.cancel();
    super.dispose();
  }

  Future<void> startScan() async {
    if (isScanning) return;

    if (_adapterState != BluetoothAdapterState.on) {
      debugPrint('Turning on bluetooth');
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
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
    if (!isScanning) return;
    await FlutterBluePlus.stopScan();
  }

  Future<void> toggleScan() async {
    if (isScanning) {
      await stopScan();
    } else {
      await startScan();
    }
  }

  Future<void> connectToTargetDevice() async {
    if (!isEnabled || _targetDeviceId == null) return;

    isConnecting = true;

    BluetoothDevice? device = _getTargetDeviceFromScan();

    if (device == null) {
      _setStatusMessage('Searching for target device');
      
      _targetDeviceCompleter = Completer();
      await startScan();
      device = await _targetDeviceCompleter!.future;
    }

    if (device != null) {
      await connectToDevice(device);
    } else {
      _setStatusMessage('Failed to find target device');
      throw Exception(statusMessage);
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (!isEnabled) return;
    debugPrint('Connecting to ${device.advName} (${device.remoteId.str})');
    
    _connectionStateSubscription = device.connectionState.listen(_updateConnectionState);
    isConnecting = true;
    currentDevice = device;
    notifyListeners();

    _setStatusMessage('Establishing connection');
    await device.connect(timeout: const Duration(seconds: 5));
    debugPrint('Connected to ${device.advName} (${device.remoteId.str})');

    _setStatusMessage('Requesting high priority');
    await device.requestConnectionPriority(
      connectionPriorityRequest: ConnectionPriority.high,
    );

    _setStatusMessage('Discovering services');
    await device.discoverServices();

    _setStatusMessage('MAC: ${device.remoteId.str}');

    // Ensure bluetooth has initalized.
    await Future.delayed(const Duration(milliseconds: 100));

    _resetCountdown();
  }

  Future<void> disconnect() async {
    isConnecting = false;
    _updateConnectionState(BluetoothConnectionState.disconnected);
    notifyListeners();
    
    await currentDevice?.disconnect(queue: false);
    _connectionStateSubscription?.cancel();
    currentDevice = null;
    notifyListeners();
  }

  Future<void> enable() async {
    isEnabled = true;
    _resetCountdown();
  }

  Future<void> disable() async {
    isEnabled = false;
    await stopScan();
    await disconnect();
  }

  Future<void> _onSettingsUpdate() async {
    if (_targetDeviceId != _appSettings.selectedDeviceId) {
      _targetDeviceId = _appSettings.selectedDeviceId;
      _resetCountdown();
      await disconnect();
    }
  }

  Future<void> _doCountdown() async {
    if (
      !isEnabled || _targetDeviceId == null ||
      isConnecting || isConnected
    ) return;

    if (_countdown > 0) {
      _countdown--;
      _setStatusMessage('Retrying in ${_countdown}s');
    }

    if (_countdown <= 0) {
      await connectToTargetDevice().catchError((err) async {
        _setStatusMessage(err.toString());
        _increaseCountdown();
        await disconnect();
      });
    }
  }

  void _increaseCountdown() {
    _countdownDuration = max(
      min(_countdownDuration*2, _maxCountdownDuration),
      _minCountdownDuration,
    );
    _countdown = _countdownDuration;
  }

  void _resetCountdown() {
    _countdown = 0;
    _countdownDuration = 0;
  }

  void _onScanStateUpdate(bool state) {
    isScanning = state;
    notifyListeners();

    if (!isScanning) {
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

  void _setStatusMessage(String message) {
    statusMessage = message;
    debugPrint('Bluetooth: $statusMessage');
    notifyListeners();
  }

  BluetoothDevice? _getTargetDeviceFromScan() =>
    scanResults.firstWhereOrNull(
      (r) => r.device.remoteId.str == _targetDeviceId,
    )?.device;

  void _updateConnectionState(BluetoothConnectionState state) {
    if (connectionState == state) return;

    if (state == BluetoothConnectionState.connected) {
      isConnecting = false;
    }

    connectionState = state;
    notifyListeners();
    _globalConnectionStateStreamController.add(state);
  }
}