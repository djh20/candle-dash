import 'package:candle_dash/constants.dart';
import 'package:candle_dash/utils.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum VehicleGear {
  park('P'),
  reverse('R'),
  neutral('N'),
  drive('D');

  const VehicleGear(this.symbol);
  final String symbol;
}

class Vehicle with ChangeNotifier {
  Vehicle();

  int? id;
  VehicleRepresentation? representation;
  List<Metric> metrics = [];
  
  bool _disposed = false;

  // Vehicles without a representation will default to this one.
  // TODO: Use generic renders instead of leaf.
  static const defaultRepresentation = VehicleRepresentation(null, 'nissan_leaf_gen1');

  static const List<VehicleRepresentation> representations = [
    VehicleRepresentation(0x5CB5, 'nissan_leaf_gen1'),
  ];

  Future<void> init(BluetoothDevice device) async {
    if (!device.isConnected) return;

    try {
      await device.requestConnectionPriority(connectionPriorityRequest: ConnectionPriority.high);
    } catch (err) {
      debugPrint('Failed to request connection priority: $err');
      return;
    }

    late List<BluetoothService> services;

    try {
      services = await device.discoverServices();
    } catch (err) {
      debugPrint('Failed to discover services: $err');
      return;
    }

    for (final service in services) {
      debugPrint('Discovered service: ${service.uuid.str}');
    }

    final metricsService = services.firstWhere((m) => m.uuid == Guid.fromString(Constants.metricsServiceId));
    final configService = services.firstWhere((m) => m.uuid == Guid.fromString(Constants.configServiceId));

    final idCharacteristic = configService.characteristics.firstWhere((c) => c.uuid == Guid('0000'));
    id = intListToInt16(await idCharacteristic.read());
    debugPrint('Vehicle ID: $id');
    _setRepresentation();

    for (final characteristic in metricsService.characteristics) {
      final metric = await Metric.fromCharacteristic(characteristic);
      if (metric != null && !_disposed) {
        debugPrint('Registered metric: ${characteristic.uuid.str}');
        metrics = [...metrics, metric];
        
        metric.addListener(() => notifyListeners()); 
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _disposeMetrics();
    super.dispose();
  }

  void _setRepresentation() {
    representation = representations.firstWhere((r) => r.vehicleId == id, orElse: () => defaultRepresentation);
    notifyListeners();
  }

  void _disposeMetrics() {
    for (final metric in metrics) {
      metric.dispose();
    }
  }
}

class VehicleRepresentation {
  const VehicleRepresentation(this.vehicleId, this.rendersFolderName);

  final int? vehicleId;
  final String rendersFolderName;
}