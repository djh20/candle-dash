import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:candle_dash/bluetooth/bluetooth_uuids.dart';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager with ChangeNotifier {
  /// The bluetooth device involved in an ongoing connection attempt or established 
  /// connection.
  BluetoothDevice? currentDevice;

  bool isEnabled = true;
  bool isScanning = false;
  bool isConnecting = false;
  bool isConnected = false;
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

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  BluetoothManager(AppSettings appSettings) :
    _appSettings = appSettings;

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

    final device = BluetoothDevice.fromId(_targetDeviceId!);
    await connectToDevice(device);
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (!isEnabled) return;
    debugPrint('Connecting to ${device.advName} (${device.remoteId.str})');
    
    _connectionStateSubscription = device.connectionState.listen(_onConnectionStateUpdate);
    isConnecting = true;
    currentDevice = device;
    notifyListeners();

    _setStatusMessage('Attempting to contact device');

    await device.connect(timeout: const Duration(seconds: 5));
    debugPrint('Connected to ${device.advName} (${device.remoteId.str})');

    _setStatusMessage('Clearing cache');
    await device.clearGattCache();

    _setStatusMessage('Requesting high priority');
    await device.requestConnectionPriority(
      connectionPriorityRequest: ConnectionPriority.high,
    );

    await Future.delayed(const Duration(milliseconds: 100));

    _setStatusMessage('Discovering services');
    final services = await device.discoverServices();

    debugPrint('Discovered ${services.length} service(s)');

    for (final service in services) {
      debugPrint('- ${service.uuid.str128}');
    }

    debugPrint('MTU: ${device.mtuNow}');

    statusMessage = 'MAC: ${device.remoteId.str}';
    isConnected = true;
    isConnecting = false;
    notifyListeners();

    _resetCountdown();
  }

  Future<void> disconnect() async {
    await currentDevice?.disconnect(queue: false);
    _resetConnection();
  }

  Future<void> enable() async {
    isEnabled = true;
    _resetCountdown();
  }

  Future<void> disable() async {
    isEnabled = false;
    await stopScan();
    await disconnect();
    _setStatusMessage('Bluetooth disabled');
  }

  Future<void> runCommand(String command) async {
    // TODO: Move to seperate class.

    if (currentDevice == null || !isConnected) return;

    debugPrint('Running command: $command');
    
    final consoleService = currentDevice!.servicesList.firstWhere(
      (s) => s.uuid == Guid.fromString(BluetoothUuids.consoleService),
    );

    final commandCharacteristic = consoleService.characteristics.firstWhere(
      (c) => c.uuid == Guid.fromString(BluetoothUuids.consoleCommandChar),
    );

    final data = command.codeUnits + <int>[10, 0];
    await commandCharacteristic.write(data);
  }

  Future<void> _onSettingsUpdate() async {
    if (_targetDeviceId != _appSettings.selectedDeviceId) {
      _targetDeviceId = _appSettings.selectedDeviceId;
      _resetCountdown();
      _setStatusMessage('Switching to new device');
      await disconnect();
    }
  }

  Future<void> _doCountdown() async {
    if (
      !isEnabled || _targetDeviceId == null ||
      isConnecting || isConnected
    ) return;

    if (_countdown <= 0) {
      await connectToTargetDevice().catchError((err) async {
        _setStatusMessage('Failed to connect');
        debugPrint(err.toString());
        _increaseCountdown();
        await disconnect();
      });
    } else {
      _setStatusMessage('Retrying in ${_countdown}s');
      _countdown--;
    }
  }

  void _increaseCountdown() {
    _countdownDuration = max(
      min(_countdownDuration*2, _maxCountdownDuration),
      _minCountdownDuration,
    );
    _countdown = _countdownDuration;
  }

  void _resetConnection() {
    isConnecting = false;
    isConnected = false;
    currentDevice = null;
    _connectionStateSubscription?.cancel();
    notifyListeners();
  }

  void _resetCountdown() {
    _countdown = 0;
    _countdownDuration = 0;
  }

  void _onScanStateUpdate(bool state) {
    isScanning = state;
    notifyListeners();
  }

  Future<void> _onScanResults(List<ScanResult> results) async {
    scanResults = results;
    notifyListeners();
  }

  void _setStatusMessage(String message) {
    statusMessage = message;
    debugPrint('Bluetooth: $statusMessage');
    notifyListeners();
  }

  void _onConnectionStateUpdate(BluetoothConnectionState state) {
    if (state == BluetoothConnectionState.disconnected && isConnected) {
      _setStatusMessage('Lost connection');
      _resetConnection();
    }
  }
}