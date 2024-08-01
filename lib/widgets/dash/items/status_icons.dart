import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:candle_dash/widgets/dash/status_icon.dart';
import 'package:flutter/material.dart';

class StatusIconsDashItem extends StatelessWidget {
  const StatusIconsDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final parkBrake = Metric.watch<IntMetric>(context, 'nl.park_brake');
    final ccFanSpeed = Metric.watch<IntMetric>(context, 'nl.cc_fan_speed');
    final headlights = Metric.watch<IntMetric>(context, 'nl.headlights');

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
              active: parkBrake.getValue() == 1,
            ),
            if (headlights != null) StatusIcon(
              icon: Icons.wb_twilight,
              color: Colors.green,
              active: (headlights.getValue() != null && headlights.getValue()! > 0),
            ),
            if (ccFanSpeed != null) StatusIcon(
              icon: Icons.air_rounded,
              active: (ccFanSpeed.getValue() != null && ccFanSpeed.getValue()! > 0),
            ),
          ],
        ),
      ),
    );
  }
}