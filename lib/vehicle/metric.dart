import 'dart:async';
import 'dart:math';
import 'package:candle_dash/utils.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
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
  steeringAngle(0x35F8);

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
    this.descriptor,
  });

  final int id;
  final Unit unit;
  String? get displayValue;
  List<int>? descriptor;

  final _publishStreamController = StreamController<List<int>>.broadcast();
  Stream<List<int>> get publishStream => _publishStreamController.stream;

  factory Metric.fromDescriptor(List<int> descriptor) {
    final id = intListToUint16(descriptor.sublist(0, 2));

    final metricType = MetricType.values[descriptor[3]];
    final unit = Unit.values[descriptor[4]];

    if (metricType == MetricType.int) {
      return MetricInt(
        id: id, 
        unit: unit, 
        descriptor: descriptor.sublist(0, 5),
      );

    } else if (metricType == MetricType.float) {
      return MetricFloat(
        id: id, 
        unit: unit, 
        precision: descriptor[5],
        descriptor: descriptor.sublist(0, 6),
      );

    } else {
      throw Error();
    }
  }

  @override
  void dispose() {
    _publishStreamController.close();
    super.dispose();
  }

  static T? watch<T extends Metric>(BuildContext context, int metricId) {
    final metrics = context.select((Vehicle? v) => v?.metrics);
    if (metrics == null) return null;

    final metric = metrics.firstWhereOrNull((m) => m.id == metricId) as T?;

    // Watch the value so that the widget rebuilds automatically.
    context.select((Vehicle? v) => (v?.metrics.firstWhereOrNull((m) => m.id == metricId) as dynamic)?.value);
    
    return metric;
  }

  void setValueFromRawData(List<int> data);
}

class MetricInt extends Metric {
  MetricInt({
    required super.id,
    super.unit,
    super.descriptor,
    int? initialValue,
  }) {
    setValue(initialValue);
  }
  
  int? value;

  @override
  String? get displayValue => value?.toString();

  Future<void> setValue(int? newValue, {bool publish = false}) async {
    if (value == newValue) return;

    if (publish) {
      _publishStreamController.add(int32ToIntList(newValue));
      return;
    }

    value = newValue;
    notifyListeners();
  }

  @override
  void setValueFromRawData(List<int> data) {
    if (data[0] == 0) return;
    setValue(intListToInt32(data.sublist(1, 5)));
  }
}

class MetricFloat extends Metric {
  MetricFloat({
    required super.id,
    super.unit,
    super.descriptor,
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

    if (publish) {
      if (newValue != null) {
        final convertedValue = (newValue * pow(10, precision)).toInt();
        _publishStreamController.add(int32ToIntList(convertedValue));
      }
      return;
    }

    value = newValue;
    notifyListeners();
  }
 
  @override
  void setValueFromRawData(List<int> data) {
    if (data[0] == 0) return;
    final intValue = intListToInt32(data.sublist(1, 5));
    setValue(intValue / pow(10, precision));
  }
}