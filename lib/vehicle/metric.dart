import 'dart:async';
import 'dart:math';
import 'package:candle_dash/utils.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

enum StandardMetric {
  awake(0x8B51),
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
  none(null),
  percent('%'),
  meters(' m'),
  kilometers(' km'),
  kilometersPerHour(' kph'),
  volts(' V'),
  amps(' A'),
  watts(' W'),
  kilowatts(' kW'),
  kilowattHours(' kWh'),
  celsius('°C'),
  seconds(' sec'),
  minutes(' min'),
  hours(' hour');

  const Unit(this.suffix);
  final String? suffix;
}

abstract class Metric with ChangeNotifier {
  Metric({
    required this.id,
    required this.unit,
    this.characteristic,
  }) {
    _characteristicSubscription = characteristic?.onValueReceived.listen(_onCharacteristicValueReceived);
    if (characteristic?.lastValue != null) _onCharacteristicValueReceived(characteristic!.lastValue);
  }

  final int id;
  final Unit unit;
  final BluetoothCharacteristic? characteristic;
  String get displayValue;

  late final StreamSubscription<List<int>>? _characteristicSubscription;
  bool _listeningToCharacteristic = false;

  static Future<Metric?> fromCharacteristic(BluetoothCharacteristic characteristic) async {
    if (!characteristic.device.isConnected) return null;

    await characteristic.read();

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

  void _onCharacteristicValueReceived(List<int> rawValue);
}

class MetricInt extends Metric {
  MetricInt({
    required super.id,
    required super.unit,
    super.characteristic,
  });
  
  int? value;

  @override
  String get displayValue => value?.toString() ?? '?';

  @override
  void _onCharacteristicValueReceived(List<int> rawValue) {
    _setValue(intListToInt32(rawValue));
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

  @override
  String get displayValue => value?.round().toString() ?? '?';
 
  @override
  void _onCharacteristicValueReceived(List<int> rawValue) {
    final intValue = intListToInt32(rawValue);
    if (intValue == null) return _setValue(null);

    _setValue(intValue / pow(10, precision));
  }

  void _setValue(double? newValue) {
    if (value == newValue) return;
    value = newValue;
    notifyListeners();
  }
}