import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/vehicle/vehicle.dart';

class DummyVehicle extends Vehicle {
  DummyVehicle() {
    representation = Vehicle.defaultRepresentation;
    registerMetrics([
      /* Driving */
      IntMetric(id: 'nl.ignition', type: MetricType.statistic, initialState: [1]),
      FloatMetric(id: 'nl.speed', type: MetricType.statistic, initialState: [24], precision: 2, unit: Unit.kilometersPerHour),
      IntMetric(id: 'nl.gear', type: MetricType.statistic, initialState: [VehicleGear.drive.index]),
      IntMetric(id: 'nl.trip_distance', type: MetricType.statistic, initialState: [28], unit: Unit.kilometers),
      IntMetric(id: 'nl.trip_efficiency', type: MetricType.statistic, initialState: [-5], unit: Unit.kilometers),
      IntMetric(id: 'nl.cruise_status', type: MetricType.statistic, initialState: [2]),
      IntMetric(id: 'nl.cruise_speed', type: MetricType.statistic, initialState: [52], unit: Unit.kilometersPerHour),

      /* Battery */
      FloatMetric(id: 'nl.soc', type: MetricType.statistic, initialState: [82.73], precision: 2, unit: Unit.percent),
      FloatMetric(id: 'nl.soh', type: MetricType.statistic, initialState: [54], precision: 2, unit: Unit.percent),
      IntMetric(id: 'nl.range', type: MetricType.statistic, initialState: [142], unit: Unit.kilometers),
      FloatMetric(id: 'nl.hvb_voltage', type: MetricType.statistic, initialState: [342.4], precision: 1, unit: Unit.volts),
      FloatMetric(id: 'nl.hvb_capacity', type: MetricType.statistic, initialState: [24.53], precision: 2, unit: Unit.kilowattHours),
      FloatMetric(id: 'nl.hvb_temp', type: MetricType.statistic, initialState: [38], precision: 2, unit: Unit.celsius),

      /* Power */
      FloatMetric(id: 'nl.net_power', type: MetricType.statistic, initialState: [20.42], precision: 2, unit: Unit.kilowatts),
      FloatMetric(id: 'nl.motor_power', type: MetricType.statistic, initialState: [12.32], precision: 2, unit: Unit.kilowatts),

      /* Climate Control */
      IntMetric(id: 'nl.cc_status', type: MetricType.statistic, initialState: [1]),

      /* Vehicle Status */
      IntMetric(id: 'nl.turn_signal', type: MetricType.statistic, initialState: [1]),
      
      /* Charging */
      IntMetric(id: 'nl.chg_fast_count', type: MetricType.statistic, initialState: [52]),
      IntMetric(id: 'nl.chg_slow_count', type: MetricType.statistic, initialState: [231]),
      
      // FloatMetric(id: StandardMetric.hvBattCurrent.id, initialValue: 118.6, precision: 1, unit: Unit.amps),
      
      // 
      // IntMetric(id: StandardMetric.chargeStatus.id, initialValue: 0),
      // FloatMetric(id: StandardMetric.steeringAngle.id, initialValue: -1, precision: 2),
      
      // IntMetric(id: StandardMetric.headlights.id, initialValue: 1),
      // IntMetric(id: StandardMetric.fanSpeed.id, initialValue: 5),
      // IntMetric(id: StandardMetric.parkBrake.id, initialValue: 0),
      
    ]);
  }
}