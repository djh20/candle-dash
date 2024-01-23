import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:candle_dash/widgets/dash/status_icon.dart';
import 'package:flutter/material.dart';

class StatusIconsDashItem extends StatelessWidget {
  const StatusIconsDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final parkBrake = Metric.watch<MetricInt>(context, StandardMetric.parkBrake.id);
    final fanSpeed = Metric.watch<MetricInt>(context, StandardMetric.fanSpeed.id);
    final headlights = Metric.watch<MetricInt>(context, StandardMetric.headlights.id);

    return DashItem(
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          spacing: 6,
          runSpacing: 6,
          children: [
            if (parkBrake != null) StatusIcon(
              icon: Icons.local_parking,
              color: Colors.red,
              active: parkBrake.value == 1,
            ),
            if (headlights != null) StatusIcon(
              icon: Icons.wb_twilight,
              color: Colors.green,
              active: (headlights.value != null && headlights.value! > 0),
            ),
            if (fanSpeed != null) StatusIcon(
              icon: Icons.air_rounded,
              active: (fanSpeed.value != null && fanSpeed.value! > 0),
            ),
          ],
        ),
      ),
    );
  }
}