import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/vehicle/vehicle.dart';

class DummyVehicle extends Vehicle {
  DummyVehicle() {
    representation = Vehicle.defaultRepresentation;
    registerMetrics([
      MetricInt(id: StandardMetric.awake.id, initialValue: 1),
      MetricInt(id: StandardMetric.gear.id, initialValue: VehicleGear.drive.index),
      MetricFloat(id: StandardMetric.speed.id, initialValue: 24, precision: 2, unit: Unit.kilometersPerHour),
      MetricFloat(id: StandardMetric.soc.id, initialValue: 82.73, precision: 2, unit: Unit.percent),
      MetricInt(id: StandardMetric.range.id, initialValue: 142, unit: Unit.kilometers),
      MetricFloat(id: StandardMetric.soh.id, initialValue: 54.84, precision: 2, unit: Unit.percent),
      MetricFloat(id: StandardMetric.hvBattPower.id, initialValue: 40.59, precision: 2, unit: Unit.kilowatts),
      MetricFloat(id: StandardMetric.hvBattVoltage.id, initialValue: 342.4, precision: 1, unit: Unit.volts),
      MetricFloat(id: StandardMetric.hvBattCurrent.id, initialValue: 118.6, precision: 1, unit: Unit.amps),
      MetricFloat(id: StandardMetric.hvBattCapacity.id, initialValue: 24.53, precision: 2, unit: Unit.kilowattHours),
      MetricFloat(id: StandardMetric.hvBattTemperature.id, initialValue: 38.45, precision: 2, unit: Unit.celsius),
      MetricInt(id: StandardMetric.chargeStatus.id, initialValue: 0),
      MetricFloat(id: StandardMetric.steeringAngle.id, initialValue: -1, precision: 2),
      MetricInt(id: StandardMetric.tripDistance.id, initialValue: 28, unit: Unit.kilometers),
      MetricInt(id: StandardMetric.tripEfficiency.id, initialValue: -5, unit: Unit.kilometers),
      MetricInt(id: StandardMetric.headlights.id, initialValue: 1),
      MetricInt(id: StandardMetric.fanSpeed.id, initialValue: 5),
      MetricInt(id: StandardMetric.parkBrake.id, initialValue: 0),
      MetricInt(id: StandardMetric.quickCharges.id, initialValue: 52),
      MetricInt(id: StandardMetric.slowCharges.id, initialValue: 231),
    ]);
  }
}