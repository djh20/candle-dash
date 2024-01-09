import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:candle_dash/widgets/dash/horizontal_line.dart';
import 'package:candle_dash/widgets/dash/items/incompatible.dart';
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
    final soh = Metric.watch<MetricFloat>(context, StandardMetric.soh.id);

    //final slowCharges = Metric.watch<MetricInt>(context, StandardMetric.slowCharges.id);
    //final quickCharges = Metric.watch<MetricInt>(context, StandardMetric.quickCharges.id);

    if (power == null) return IncompatibleDashItem(this);

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
        ],
      ),
    );
  }
}