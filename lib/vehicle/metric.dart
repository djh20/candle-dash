import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages, unused_import
import 'package:collection/collection.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

enum StandardMetric {
  active(0x8B51),
  gear(0x2C96),
  speed(0x75AE),
  fanSpeed(0x3419),
  range(0xC3E8),
  turnSignal(0x13CA),
  parkBrake(0x8BFE),
  ambientTemperature(0x2842),
  soc(0x3DEE),
  soh(0x22DA),
  hvBattVoltage(0xC549),
  hvBattCurrent(0xE27C),
  hvBattPower(0xE2DB),
  hvBattCapacity(0x5F5F),
  hvBattTemperature(0x87C9),
  chargeStatus(0x2DA6),
  remainChargeTime(0x31D1),
  rangeLastCharge(0x5E38),
  quickCharges(0x90FB),
  slowCharges(0x18AB);

  const StandardMetric(this.id);
  final int id;
}

enum MetricType {
  int,
  float,
}

enum Unit {
  none,
  percent,
  meters,
  kilometers,
  kilometersPerHour,
  volts,
  amps,
  watts,
  kilowatts,
  kilowattHours,
  celsius,
  seconds,
  minutes,
  hours,
}

abstract class Metric with ChangeNotifier {
  Metric({
    required this.id,
    required this.unit,
    this.characteristic,
  }) {
    _characteristicSubscription = characteristic?.onValueReceived.listen(_onCharacteristicValueReceived);
  }

  final int id;
  final Unit unit;
  final BluetoothCharacteristic? characteristic;
  late final StreamSubscription<List<int>>? _characteristicSubscription;
  bool _listeningToCharacteristic = false;

  static Future<Metric?> fromCharacteristic(BluetoothCharacteristic characteristic) async {
    if (!characteristic.device.isConnected) return null;

    final descriptor = characteristic.descriptors.firstWhere((d) => d.uuid == Guid('0000'));
    late List<int> descriptorData;

    try {
      descriptorData = await descriptor.read();
    } catch (err) {
      debugPrint('Failed to read descriptor: $err');
      return null;
    }

    final id = int.parse(characteristic.uuid.str, radix: 16);

    final metricType = MetricType.values[descriptorData[0]];
    final unit = Unit.values[descriptorData[1]];

    if (metricType == MetricType.int) {
      return MetricInt(id: id, unit: unit, characteristic: characteristic);

    } else if (metricType == MetricType.float) {
      final precision = descriptorData[2];
      return MetricFloat(id: id, unit: unit, precision: precision, characteristic: characteristic);
    }

    return null;
  }

  static T? watch<T extends Metric>(BuildContext context, int metricId) {
    final metrics = context.select((Vehicle? v) => v?.metrics);
    if (metrics == null) return null;

    final metric = metrics.firstWhereOrNull((m) => m.id == metricId) as T?;

    // Watch the value so that the widget rebuilds automatically.
    context.select((Vehicle? v) => (v?.metrics.firstWhereOrNull((m) => m.id == metricId) as dynamic)?.value);
    metric?.listenToCharacteristic();
    
    return metric;
  }

  @override
  void dispose() {
    _characteristicSubscription?.cancel();
    super.dispose();
  }

  void listenToCharacteristic() async {
    if (_listeningToCharacteristic) return;

    _listeningToCharacteristic = true;
    await characteristic?.setNotifyValue(true);
  }

  int? _rawValueToInt(List<int> rawValue) {
    if (rawValue.isEmpty) return null;
    final intList = Int8List.fromList(rawValue);
    return intList.buffer.asByteData().getInt32(0, Endian.little);
  }

  void _onCharacteristicValueReceived(List<int> rawValue);
}

class MetricInt extends Metric {
  MetricInt({
    required super.id,
    required super.unit,
    super.characteristic,
  }) {
    //_onCharacteristicValueReceived(characteristic?.lastValue)
  }
  
  int? value;

  // static int? watch<T>(BuildContext context, int metricId) {
  //   return context.select((Vehicle? v) => (v?.metrics[metricId] as MetricInt?)?.value);
  // }

  // static MetricInt? watch(BuildContext context, int metricId) {
  //   final vehicle = context.read<Vehicle?>();
  //   final metric = vehicle?.metrics[metricId] as MetricInt?;

  //   // Watch the value so that the widget rebuilds automatically.
  //   context.select((Vehicle? v) => (v?.metrics[metricId] as MetricInt?)?.value);
  //   return metric;
  // }

  // void watchValue(BuildContext context) {
  //   context.select((Vehicle? v) => (v?.metrics[id] as MetricInt?)?.value);
  //   _listenToCharacteristic();
  // }

  @override
  void _onCharacteristicValueReceived(List<int> rawValue) {
    _setValue(_rawValueToInt(rawValue));
  }

  void _setValue(int? newValue) {
    if (value == newValue) return;
    value = newValue;
    notifyListeners();
  }
}

class MetricFloat extends Metric {
  MetricFloat({
    required super.id,
    required super.unit,
    super.characteristic,
    required this.precision,
  });

  double? value; 
  int precision;

  // static MetricFloat? watch(BuildContext context, int metricId) {
  //   final vehicle = context.read<Vehicle?>();
  //   final metric = vehicle?.metrics[metricId] as MetricFloat?;

  //   // Watch the value so that the widget rebuilds automatically.
  //   context.select((Vehicle? v) => (v?.metrics[metricId] as MetricFloat?)?.value);
  //   return metric;
  // }
 
  @override
  void _onCharacteristicValueReceived(List<int> rawValue) {
    final intValue = _rawValueToInt(rawValue);
    if (intValue == null) return _setValue(null);

    _setValue(intValue / pow(10, precision));
  }

  void _setValue(double? newValue) {
    if (value == newValue) return;
    value = newValue;
    notifyListeners();
  }
}