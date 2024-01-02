import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/status_icon.dart';
import 'package:flutter/material.dart';

class StatusIconsDashItem extends StatelessWidget {
  const StatusIconsDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final parkBrake = Metric.watch<MetricInt>(context, StandardMetric.parkBrake.id)?.value;
    final fanSpeed = Metric.watch<MetricInt>(context, StandardMetric.fanSpeed.id)?.value;
    final headlights = Metric.watch<MetricInt>(context, StandardMetric.headlights.id)?.value;

    return Column(
      children: [
        StatusIcon(
          icon: Icons.local_parking,
          color: Colors.red,
          visible: parkBrake == 1,
        ),
        StatusIcon(
          icon: Icons.wb_twilight,
          color: Colors.green,
          visible: (headlights != null && headlights > 0),
        ),
        StatusIcon(
          icon: Icons.air_rounded,
          visible: (fanSpeed != null && fanSpeed > 0),
        ),
      ],
    );
  }
}