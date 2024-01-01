import 'package:candle_dash/vehicle/metric.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Vehicle with ChangeNotifier {
  Vehicle();

  List<Metric> metrics = [];
  bool _disposed = false;

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

    final metricsService = services.firstWhere((m) => m.uuid == Guid.fromString('4fafc201-1fb5-459e-8fcc-c5c9c331914b'));

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

  void _disposeMetrics() {
    for (final metric in metrics) {
      metric.dispose();
    }
  }
}