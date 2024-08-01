import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/vehicle/vehicle.dart';

class DummyVehicle extends Vehicle {
  DummyVehicle() {
    representation = Vehicle.defaultRepresentation;
    registerMetrics([
      // IntMetric(id: 'nl.ignition', type: MetricType.statistic, initialValue: 1),
      // IntMetric(id: 'nl.gear', type: MetricType.statistic, initialValue: VehicleGear.drive.index),
      // FloatMetric(id: 'nl.speed', type: MetricType.statistic, initialValue: 24, precision: 2, unit: Unit.kilometersPerHour),
      // FloatMetric(id: 'nl.soc', type: MetricType.statistic, initialValue: 82.73, precision: 2, unit: Unit.percent),
      // IntMetric(id: 'nl.range', type: MetricType.statistic, initialValue: 142, unit: Unit.kilometers),
      // FloatMetric(id: StandardMetric.soh.id, initialValue: 54.84, precision: 2, unit: Unit.percent),
      // FloatMetric(id: StandardMetric.hvBattPower.id, initialValue: 40.59, precision: 2, unit: Unit.kilowatts),
      // FloatMetric(id: StandardMetric.hvBattVoltage.id, initialValue: 342.4, precision: 1, unit: Unit.volts),
      // FloatMetric(id: StandardMetric.hvBattCurrent.id, initialValue: 118.6, precision: 1, unit: Unit.amps),
      // FloatMetric(id: StandardMetric.hvBattCapacity.id, initialValue: 24.53, precision: 2, unit: Unit.kilowattHours),
      // FloatMetric(id: StandardMetric.hvBattTemperature.id, initialValue: 38.45, precision: 2, unit: Unit.celsius),
      // IntMetric(id: StandardMetric.chargeStatus.id, initialValue: 0),
      // FloatMetric(id: StandardMetric.steeringAngle.id, initialValue: -1, precision: 2),
      // IntMetric(id: StandardMetric.tripDistance.id, initialValue: 28, unit: Unit.kilometers),
      // IntMetric(id: StandardMetric.tripEfficiency.id, initialValue: -5, unit: Unit.kilometers),
      // IntMetric(id: StandardMetric.headlights.id, initialValue: 1),
      // IntMetric(id: StandardMetric.fanSpeed.id, initialValue: 5),
      // IntMetric(id: StandardMetric.parkBrake.id, initialValue: 0),
      // IntMetric(id: StandardMetric.quickCharges.id, initialValue: 52),
      // IntMetric(id: StandardMetric.slowCharges.id, initialValue: 231),
    ]);
  }
}