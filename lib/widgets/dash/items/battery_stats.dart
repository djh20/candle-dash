import 'package:candle_dash/theme.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/horizontal_line.dart';
import 'package:candle_dash/widgets/dash/limits_indicator.dart';
import 'package:candle_dash/widgets/dash/metric_label.dart';
import 'package:candle_dash/widgets/dash/new_gizmo.dart';
import 'package:flutter/material.dart';

class BatteryStatsGizmo extends NewGizmo {
  const BatteryStatsGizmo({super.key, super.overlay}) : super(
    name: 'Battery Stats',
  );

  @override
  State<NewGizmo> createState() => _BatteryStatsGizmoState();
}

class _BatteryStatsGizmoState extends NewGizmoState {
  @override
  Widget buildContent(BuildContext context) {
    final netPower = Metric.watch<FloatMetric>(context, 'nl.net_power');
    final chargePower = Metric.watch<FloatMetric>(context, 'nl.chg_power');
    final chargeMode = Metric.watch<IntMetric>(context, 'nl.chg_mode');
    final bool charging = (chargeMode?.getValue() ?? 0) > 0;

    final voltage = Metric.watch<FloatMetric>(context, 'nl.hvb_voltage');
    final temperature = Metric.watch<FloatMetric>(context, 'nl.hvb_temp');
    final capacity = Metric.watch<FloatMetric>(context, 'nl.hvb_capacity');
    final soh = Metric.watch<FloatMetric>(context, 'nl.soh');

    final slowCharges = Metric.watch<IntMetric>(context, 'nl.chg_slow_count');
    final quickCharges = Metric.watch<IntMetric>(context, 'nl.chg_fast_count');

    if (netPower == null) return incompatible;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MetricLabel(
          (charging && chargePower != null) ? chargePower : netPower,
          fontSize: 40,
        ),
        
        if (voltage != null) MetricLabel(
          voltage,
          fontSize: 22,
        ),

        const SizedBox(height: 10),
    
        if (temperature != null) LimitsIndicator(
          title: const Text('Battery Temperature'),
          displayValue: MetricLabel(temperature),
          value: temperature.getValue() ?? 0,
          min: 0,
          max: 45,
          minColor: Colors.blue,
          midColor: Colors.green,
          maxColor: Colors.red,
        ),
    
        const SizedBox(height: 15),
    
        if (soh != null && capacity != null) LimitsIndicator(
          title: const Text('Battery Health'),
          displayValue: Row(
            children: [
              MetricLabel(soh),
              const HorizontalLine(width: 20),
              MetricLabel(capacity),
            ],
          ),
          value: soh.getValue() ?? 0,
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