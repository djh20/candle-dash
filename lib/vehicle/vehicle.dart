import 'dart:async';

import 'package:candle_dash/bluetooth/bluetooth_uuids.dart';
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

  // Vehicles without a representation will default to this one.
  // TODO: Use generic renders instead of leaf.
  static const defaultRepresentation = VehicleRepresentation(
    rendersDirectory: 'nissan_leaf_gen1',
    brand: 'nissan',

    chargingRenderAspectRatio: 32 / 11,
    chargingRenderPackAlignment: Alignment(0.16, 0.6),
    chargingRenderPackWidthFactor: 0.36,
    chargingRenderPackHeightFactor: 0.15,
  );

  static const List<VehicleRepresentation> representations = [];

  final List<StreamSubscription> _streams = [];

  Future<void> init(BluetoothDevice device) async {
    if (!device.isConnected) return;

    return; // CURRENTLY DISABLED

    final metricsService = device.servicesList.firstWhere(
      (m) => m.uuid == Guid.fromString(BluetoothUuids.metricsService),
    );

    // final configService = device.servicesList.firstWhere(
    //   (m) => m.uuid == Guid.fromString(BluetoothUuids.configService),
    // );

    // final vehicleIdCharacteristic = configService.characteristics.firstWhere(
    //   (c) => c.uuid == Guid.fromString(BluetoothUuids.configVehicleIdChar),
    // );

    // id = intListToUint16(await vehicleIdCharacteristic.read());
    debugPrint('Vehicle ID: $id');
    _setRepresentation();

    for (final characteristic in metricsService.characteristics) {
      final descriptor = characteristic.descriptors.firstWhere(
        (d) => d.uuid == Guid.fromString(BluetoothUuids.metricsDescriptor),
      );

      var descriptorData = await descriptor.read();

      final List<Metric> characteristicMetrics = [];

      while (descriptorData.isNotEmpty) {
        final metric = Metric.fromDescriptor(descriptorData);
        if (metric.descriptor != null) {
          descriptorData = descriptorData.sublist(metric.descriptor!.length);
        }
        characteristicMetrics.add(metric);
        registerMetric(metric);
      }
      
      var characteristicData = await characteristic.read();
      processCharacteristicData(characteristicData, characteristicMetrics);
      _streams.add(
        characteristic.onValueReceived.listen(
          (data) => processCharacteristicData(data, characteristicMetrics),
        ),
      );

      await characteristic.setNotifyValue(true, timeout: 2);
    }
  }

  @override
  void dispose() {
    for (var stream in _streams) {
      stream.cancel();
    }
    _disposeMetrics();
    super.dispose();
  }

  void processCharacteristicData(List<int> data, List<Metric> characteristicMetrics) {
    for (final metric in characteristicMetrics) {
      if (metric.descriptor != null) {
        final metricData = data.sublist(metric.descriptor![2]);
        metric.setValueFromRawData(metricData);
      }
    }
  }

  void registerMetric(Metric newMetric) {
    metrics = [...metrics, newMetric];
    notifyListeners();
    newMetric.addListener(() => notifyListeners()); 

    debugPrint('Registered metric: ${newMetric.id}');
  }

  void registerMetrics(List<Metric> newMetrics) => newMetrics.forEach(registerMetric);

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
  const VehicleRepresentation({
    this.vehicleId,
    required this.rendersDirectory,
    required this.brand,
    this.chargingRenderAspectRatio,
    this.chargingRenderPackAlignment,
    this.chargingRenderPackHeightFactor,
    this.chargingRenderPackWidthFactor,
  });

  final int? vehicleId;
  final String rendersDirectory;
  final String brand;
  
  final double? chargingRenderAspectRatio;
  final Alignment? chargingRenderPackAlignment;
  final double? chargingRenderPackHeightFactor;
  final double? chargingRenderPackWidthFactor;
}