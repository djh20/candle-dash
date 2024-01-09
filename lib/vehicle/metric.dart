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
  headlights(0xF20B),
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
  remainingChargeTime(0x31D1),
  rangeLastCharge(0x5E38),
  quickCharges(0x90FB),
  slowCharges(0x18AB),
  tripDistance(0x912F),
  steeringAngle(0x35F8),
  flTirePressure(0x858D),
  frTirePressure(0x5193),
  rlTirePressure(0xFA16),
  rrTirePressure(0x842D);

  const StandardMetric(this.id);
  final int id;
}

enum MetricType {
  int,
  float,
}

enum Unit {
  none(''),
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
  hours(' hour'),
  psi(' PSI');

  const Unit(this.suffix);
  final String suffix;
}

abstract class Metric with ChangeNotifier {
  Metric({
    required this.id,
    this.unit = Unit.none,
    this.characteristic,
  }) {
    _characteristicSubscription = characteristic?.onValueReceived.listen(_onCharacteristicValueReceived);
  }

  final int id;
  final Unit unit;
  final BluetoothCharacteristic? characteristic;
  String? get displayValue;

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

    // await characteristic.read();
    // await characteristic.setNotifyValue(true);

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
    
    return metric;
  }

  @override
  void dispose() {
    _characteristicSubscription?.cancel();
    super.dispose();
  }

  Future<void> readCharacteristic() async {
    debugPrint('Reading characteristic: ${characteristic!.uuid}');
    _onCharacteristicValueReceived(await characteristic!.read(timeout: 2));
  }

  Future<void> listenToCharacteristic() async {
    if (_listeningToCharacteristic || characteristic == null) return;

    _listeningToCharacteristic = true;
    debugPrint('Listening to characteristic: ${characteristic!.uuid}');
    await characteristic!.setNotifyValue(true, timeout: 2);
  }

  void _onCharacteristicValueReceived(List<int> rawValue);
}

class MetricInt extends Metric {
  MetricInt({
    required super.id,
    super.unit,
    super.characteristic,
    int? initialValue,
  }) {
    setValue(initialValue);
  }
  
  int? value;

  @override
  String? get displayValue => value?.toString();

  Future<void> setValue(int? newValue, {bool publish = false}) async {
    if (value == newValue) return;
    value = newValue;
    notifyListeners();
    
    if (publish) {
      await characteristic?.write(int32ToIntList(value));
    }
  }

  @override
  void _onCharacteristicValueReceived(List<int> rawValue) {
    setValue(intListToInt32(rawValue));
  }
}

class MetricFloat extends Metric {
  MetricFloat({
    required super.id,
    super.unit,
    super.characteristic,
    required this.precision,
    double? initialValue,
  }) {
    setValue(initialValue);
  }

  double? value; 
  int precision;

  @override
  String? get displayValue => value?.toStringAsFixed(1);

  Future<void> setValue(double? newValue, {bool publish = false}) async {
    if (value == newValue) return;
    value = newValue;
    notifyListeners();

    if (publish) {
      int? convertedValue;

      if (value != null) {
        convertedValue = (value! * pow(10, precision)).toInt();
      }
    
      characteristic?.write(int32ToIntList(convertedValue));
    }
  }
 
  @override
  void _onCharacteristicValueReceived(List<int> rawValue) {
    final intValue = intListToInt32(rawValue);
    (intValue != null) ? setValue(intValue / pow(10, precision)) : setValue(null);
  }
}