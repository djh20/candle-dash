import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/gizmo.dart';
import 'package:candle_dash/widgets/dash/horizontal_line.dart';
import 'package:candle_dash/widgets/dash/limits_indicator.dart';
import 'package:candle_dash/widgets/dash/metric_label.dart';
import 'package:flutter/material.dart';

class BatteryStatsGizmo extends Gizmo {
  const BatteryStatsGizmo({super.key}) : super(
    name: 'Battery Stats',
    height: 320,
  );

  @override
  Widget buildContent(BuildContext context) {
    final power = Metric.watch<MetricFloat>(context, StandardMetric.hvBattPower.id);
    final voltage = Metric.watch<MetricFloat>(context, StandardMetric.hvBattVoltage.id);
    final temperature = Metric.watch<MetricFloat>(context, StandardMetric.hvBattTemperature.id);
    final capacity = Metric.watch<MetricFloat>(context, StandardMetric.hvBattCapacity.id);
    final soh = Metric.watch<MetricFloat>(context, StandardMetric.soh.id);

    final slowCharges = Metric.watch<MetricInt>(context, StandardMetric.slowCharges.id);
    final quickCharges = Metric.watch<MetricInt>(context, StandardMetric.quickCharges.id);

    if (power == null) return incompatible;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BATTERY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        
        MetricLabel(
          power,
          fontSize: 40,
        ),

        if (voltage != null) MetricLabel(
          voltage,
          fontSize: 22,
        ),

        const SizedBox(height: 10),
    
        if (temperature != null) LimitsIndicator(
          title: const Text('Temperature'),
          subtitle: MetricLabel(temperature),
          value: temperature.value ?? 0,
          min: 0,
          max: 45,
          minColor: Colors.blue,
          midColor: Colors.green,
          maxColor: Colors.red,
        ),
    
        const SizedBox(height: 15),
    
        if (soh != null && capacity != null) LimitsIndicator(
          title: const Text('Health'),
          subtitle: Row(
            children: [
              MetricLabel(soh),
              const HorizontalLine(width: 20),
              MetricLabel(capacity),
            ],
          ),
          value: soh.value ?? 0,
          min: 0,
          max: 100,
          minColor: Colors.red,
          midColor: Colors.orange,
          maxColor: Colors.green,
        ),

        const SizedBox(height: 12),

        if (slowCharges != null && quickCharges != null) Row(
          children: [
            const Icon(Icons.ev_station),
            const Icon(
              Icons.keyboard_arrow_up,
              color: Colors.orange,
            ),
            MetricLabel(
              slowCharges,
              fontSize: 22,
            ),
            const HorizontalLine(width: 20),
            const Icon(
              Icons.keyboard_double_arrow_up,
              color: Colors.green,
            ),
            MetricLabel(
              quickCharges,
              fontSize: 22,
            ),
          ],
        ),
      ],
    );
  }
}