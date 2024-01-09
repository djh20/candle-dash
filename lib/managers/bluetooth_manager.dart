import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager with ChangeNotifier {
  BluetoothDevice? currentDevice;
  String? bondedDeviceId;
  bool get isBonded => bondedDeviceId != null;

  BluetoothConnectionState connectionState = BluetoothConnectionState.disconnected;
  bool enabled = true;
  bool isScanning = false;
  bool isConnecting = false;
  List<ScanResult> scanResults = [];

  final _globalConnectionStateStreamController = StreamController<BluetoothConnectionState?>.broadcast();
  Stream<BluetoothConnectionState?> get globalConnectionStateStream => _globalConnectionStateStreamController.stream;

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  Timer? _reconnectTimer;

  void init() {
    FlutterBluePlus.setLogLevel(LogLevel.none);

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      notifyListeners();
    });

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      scanResults = results;
      notifyListeners();
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      isScanning = state;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _adapterStateSubscription.cancel();
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future<void> startScan() async {
    if (isScanning) return;

    if (_adapterState != BluetoothAdapterState.on) {
      debugPrint('Failed to start scan; bluetooth not active.');
      return;
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

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (!enabled) return;
    _connectionStateSubscription = device.connectionState.listen(_updateConnectionState);

    isConnecting = true;
    currentDevice = device;
    bondedDeviceId = device.remoteId.str;
    notifyListeners();

    try {
      await device.connect(timeout: const Duration(seconds: 5), mtu: 23);

    } on FlutterBluePlusException catch (err) {
      debugPrint(err.toString());
      await disconnect();
      scheduleReconnect();
    }
  }

  Future<void> reconnect() async {
    if (bondedDeviceId == null || !enabled) return;
    final device = BluetoothDevice.fromId(bondedDeviceId!);
    await connectToDevice(device);
  }

  void scheduleReconnect({Duration delay = const Duration(seconds: 1)}) {
    if (!enabled || isConnecting) return;
    _reconnectTimer = Timer(delay, reconnect);
  }

  Future<void> disconnect({bool unbond = false}) async {
    isConnecting = false;
    _reconnectTimer?.cancel();
    _updateConnectionState(BluetoothConnectionState.disconnected);
    if (unbond) bondedDeviceId = null;
    notifyListeners();
    
    await currentDevice?.disconnect(queue: false);
    _connectionStateSubscription?.cancel();
    currentDevice = null;
    notifyListeners();
  }

  Future<void> enable() async {
    enabled = true;
    await reconnect();
  }

  Future<void> disable() async {
    enabled = false;
    await disconnect();
  }

  void _updateConnectionState(BluetoothConnectionState state) {
    if (connectionState == state) return;
    connectionState = state;
    _globalConnectionStateStreamController.add(state);
    notifyListeners();

    if (state == BluetoothConnectionState.connected) {
      isConnecting = false;
    } else if (state == BluetoothConnectionState.disconnected) {
      debugPrint('TRYING TO RECONNECT');
      scheduleReconnect();
    }
  }
}