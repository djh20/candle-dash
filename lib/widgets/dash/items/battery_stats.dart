import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:candle_dash/widgets/dash/horizontal_line.dart';
import 'package:candle_dash/widgets/dash/limits_indicator.dart';
import 'package:candle_dash/widgets/dash/metric_label.dart';
import 'package:flutter/material.dart';

class BatteryStatsDashItem extends StatelessWidget {
  const BatteryStatsDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final power = Metric.watch<MetricFloat>(context, StandardMetric.hvBattPower.id);
    final temperature = Metric.watch<MetricFloat>(context, StandardMetric.hvBattTemperature.id);
    final capacity = Metric.watch<MetricFloat>(context, StandardMetric.hvBattCapacity.id);
    final soh = Metric.watch<MetricInt>(context, StandardMetric.soh.id);

    final slowCharges = Metric.watch<MetricInt>(context, StandardMetric.slowCharges.id);
    final quickCharges = Metric.watch<MetricInt>(context, StandardMetric.quickCharges.id);

    return DashItem(
      child: Column(
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

            if (temperature != null) LimitsIndicator(
              title: const Text('Temperature'),
              subtitle: MetricLabel(temperature),
              value: temperature.value ?? 0,
              min: 0,
              max: 45,
            ),

            const SizedBox(height: 20),

            if (soh != null) LimitsIndicator(
              title: const Text('Health'),
              subtitle: Row(
                children: [
                  MetricLabel(soh),
                  const HorizontalLine(width: 20),
                  MetricLabel(capacity),
                ],
              ),
              value: soh.value?.toDouble() ?? 0,
              min: 0,
              max: 100,
            ),

            const SizedBox(height: 20),

            if (slowCharges != null) MetricLabel(
              slowCharges,
              title: 'L1/L2',
              fontSize: 22,
            ),

            if (slowCharges != null) MetricLabel(
              quickCharges,
              title: 'QCs',
              fontSize: 22,
            ),
          ],
        ),
    );
  }
}