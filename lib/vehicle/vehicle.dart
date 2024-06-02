import 'dart:async';

import 'package:candle_dash/bluetooth/bluetooth_uuids.dart';
import 'package:candle_dash/utils.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';

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
  StreamSubscription<Position>? _gpsPositionSubscription;
  Position? _gpsPosition;
  bool _disposed = false;

  Future<void> init(BluetoothDevice device) async {
    if (!device.isConnected) return;

    final metricsService = device.servicesList.firstWhere(
      (m) => m.uuid == Guid.fromString(BluetoothUuids.metricsService),
    );

    final configService = device.servicesList.firstWhere(
      (m) => m.uuid == Guid.fromString(BluetoothUuids.configService),
    );

    final vehicleIdCharacteristic = configService.characteristics.firstWhere(
      (c) => c.uuid == Guid.fromString(BluetoothUuids.configVehicleIdChar),
    );

    id = intListToUint16(await vehicleIdCharacteristic.read());
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
        // _streams.add(
        //   metric.publishStream.listen((data) {
        //     if (metric.descriptor == null) return;
        //     final fullData = metric.descriptor!.sublist(0, 2) + data;
        //     commandCharacteristic.write(fullData);
        //   }),
        // );
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

    if (!_disposed) await _initGps();
  }

  @override
  void dispose() {
    _disposed = true;
    _gpsPositionSubscription?.cancel();
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

  Future<void> _initGps() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 30,
    );
    
    _gpsPositionSubscription = 
      Geolocator.getPositionStream(locationSettings: locationSettings).listen(_onGpsPositionUpdate);
  }

  void _onGpsPositionUpdate(Position? newPosition) {
    debugPrint(newPosition.toString());

    final tripDistance = 
      metrics.firstWhereOrNull((m) => m.id == StandardMetric.tripDistance.id) as MetricFloat?;

    final gear = 
      metrics.firstWhereOrNull((m) => m.id == StandardMetric.gear.id) as MetricInt?;

    final bool parked = (gear?.value == null || gear?.value == VehicleGear.park.index);
    
    if (_gpsPosition != null && tripDistance != null && gear != null) {
      final distanceKm = Geolocator.distanceBetween(
        _gpsPosition!.latitude,
        _gpsPosition!.longitude,
        newPosition!.latitude,
        newPosition.longitude,
      ) / 1000;

      if (distanceKm <= 100 && !parked) {
        tripDistance.setValue((tripDistance.value ?? 0.0) + distanceKm, publish: true);
      }
    }

    _gpsPosition = newPosition; 
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