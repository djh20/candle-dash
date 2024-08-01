import 'dart:math';
import 'dart:typed_data';
import 'package:candle_dash/utils.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';

// enum StandardMetric {
//   awake(0x8B51),
//   gear(0x2C96),
//   speed(0x75AE),
//   steeringAngle(0x35F8),
//   fanSpeed(0x3419),
//   range(0xC3E8),
//   turnSignal(0x13CA),
//   headlights(0xF20B),
//   parkBrake(0x8BFE),
//   ambientTemperature(0x2842),
//   soc(0x3DEE),
//   soh(0x22DA),
//   hvBattVoltage(0xC549),
//   hvBattCurrent(0xE27C),
//   hvBattPower(0xE2DB),
//   hvBattCapacity(0x5F5F),
//   hvBattTemperature(0x87C9),
//   chargeStatus(0x2DA6),
//   remainingChargeTime(0x31D1),
//   quickCharges(0x90FB),
//   slowCharges(0x18AB),
//   tripDistance(0x912F),
//   tripEfficiency(0x85D0);

//   const StandardMetric(this.id);
//   final int id;
// }

enum MetricType {
  parameter,
  statistic
}

enum MetricDataType {
  int,
  float,
  string
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
    required this.type,
    this.dataIndex,
    this.elementCount = 1,
    this.unit = Unit.none,
  });

  final String id;
  final int? dataIndex;
  final int elementCount;
  final MetricType type;
  final Unit unit;
  
  String? get displayValue;

  factory Metric.fromDescriptor(List<int> descriptor) {
    final id = intListToString(descriptor);
    descriptor.removeRange(0, id.length+1);

    int? dataIndex = descriptor.removeAt(0);

    // Redacted metrics don't have any associated state data.
    if (dataIndex == 0xFF) dataIndex = null;
    
    final elementCount = descriptor.removeAt(0);

    final rawType = descriptor.removeAt(0);
    final type = MetricType.values[rawType >> 4];
    final dataType = MetricDataType.values[rawType & 0x0F];

    final unit = Unit.values[descriptor.removeAt(0)];

    if (dataType == MetricDataType.int) {
      return IntMetric(
        id: id,
        dataIndex: dataIndex,
        elementCount: elementCount,
        type: type,
        unit: unit,
      );

    } else if (dataType == MetricDataType.float) {
      return FloatMetric(
        id: id,
        dataIndex: dataIndex,
        elementCount: elementCount,
        type: type,
        unit: unit,
        precision: descriptor.removeAt(0),
      );

    } else if (dataType == MetricDataType.string) {
      return StringMetric(
        id: id,
        dataIndex: dataIndex,
        elementCount: elementCount,
        type: type,
        unit: unit,
        elementSize: descriptor.removeAt(0),
      );

    } else {
      throw Error();
    }
  }

  static T? watch<T extends Metric>(BuildContext context, String metricId) {
    final metrics = context.select((Vehicle? v) => v?.metrics);
    if (metrics == null) return null;

    final metric = metrics.firstWhereOrNull((m) => m.id == metricId) as T?;

    // Watch the value so that the widget rebuilds automatically.
    context.select((Vehicle? v) => (v?.metrics.firstWhereOrNull((m) => m.id == metricId) as dynamic)?.state);
    
    return metric;
  }

  void setStateFromRawData(List<int> data);
}

class IntMetric extends Metric {
  IntMetric({
    required super.id,
    required super.type,
    super.dataIndex,
    super.elementCount,
    super.unit,
  });
  
  List<int>? state;

  @override
  String? get displayValue => state?[0].toString();

  int? getValue([int element = 0]) => state?[element];

  void setState(List<int>? newState) {
    if (listEquals(state, newState)) return;

    state = newState;
    notifyListeners();
  }

  @override
  void setStateFromRawData(List<int> data) {
    if (data[0] & 0x01 == 1) {
      final newState = List<int>.filled(elementCount, 0);
      
      final byteData = Uint8List.fromList(data.sublist(1)).buffer.asByteData();
      for (int i = 0; i < elementCount; i++) {
        newState[i] = byteData.getInt32(i*4, Endian.little);
      }
      setState(newState);
      
    } else {
      setState(null);
    }
  }
}

class FloatMetric extends Metric {
  FloatMetric({
    required super.id,
    required super.type,
    super.dataIndex,
    super.elementCount,
    super.unit,
    required this.precision,
  });

  List<double>? state;
  int precision;

  @override
  String? get displayValue => state?[0].toStringAsFixed(1);

  double? getValue([int element = 0]) => state?[element];

  void setState(List<double>? newState) {
    if (listEquals(state, newState)) return;

    state = newState;
    notifyListeners();
  }
 
  @override
  void setStateFromRawData(List<int> data) {
    if (data[0] & 0x01 == 1) {
      final newState = List<double>.filled(elementCount, 0);
      
      final byteData = Uint8List.fromList(data.sublist(1)).buffer.asByteData();
      for (int i = 0; i < elementCount; i++) {
        newState[i] = byteData.getInt32(i*4, Endian.little) / pow(10, precision);
      }
      setState(newState);
      
    } else {
      setState(null);
    }
  }
}

class StringMetric extends Metric {
  StringMetric({
    required super.id,
    required super.dataIndex,
    required super.elementCount,
    required super.type,
    super.unit,
    required this.elementSize,
  });

  List<String>? state;
  int elementSize;

  @override
  String? get displayValue => '';

  // void setValue(double? newValue) {
  //   if (value == newValue) return;

  //   value = newValue;
  //   notifyListeners();
  // }
 
  @override
  void setStateFromRawData(List<int> data) {
    // if (data[0] == 0) return setValue(null);

    // final intValue = intListToInt32(data.sublist(1, 5));
    // setValue(intValue / pow(10, precision));
  }
}