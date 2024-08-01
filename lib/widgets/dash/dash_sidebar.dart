import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_column.dart';
import 'package:candle_dash/widgets/dash/items/connection_status_indicator.dart';
import 'package:candle_dash/widgets/dash/items/status_icons.dart';
import 'package:flutter/material.dart';

class DashSidebar extends StatelessWidget {
  const DashSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleAwake = Metric.watch<IntMetric>(context, 'nl.ignition')?.getValue() == 1;

    return DashColumn(
      flex: 1,
      items: [
        const ConnectionStatusIndicatorGizmo(),
        if (vehicleAwake) ...[
          Divider(
            indent: 10,
            endIndent: 10,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          ),
          const StatusIconsDashItem(),
        ],
      ],
    );
  }
}