import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:candle_dash/widgets/dash/metric_label.dart';
import 'package:candle_dash/widgets/dash/property_label.dart';
import 'package:flutter/material.dart';

class TripInfoDashItem extends StatelessWidget {
  const TripInfoDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final tripDistance = Metric.watch<IntMetric>(context, 'nl.trip_distance');

    if (tripDistance == null) return DashItem.incompatible;

    final tripEfficiency = Metric.watch<IntMetric>(context, 'nl.trip_efficiency');

    String efficiencyText = 'N/A';
    Color? efficiencyTextColor;
    Unit efficiencyUnit = Unit.none;

    if (tripEfficiency != null && tripEfficiency.getValue() != null) {
      final val = tripEfficiency.getValue()!;

      efficiencyText = (val == 0) ? 'Perfect' : (val >= 0) ? '+$val' : '$val';
      efficiencyTextColor = (val >= 0) ? Colors.green : Colors.red;
      efficiencyUnit = (val != 0) ? Unit.kilometers : Unit.none;
    }

    return DashItem(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MetricLabel(
            tripDistance,
            title: 'Travelled',
            defaultValue: '0',
          ),
          PropertyLabel(
            value: efficiencyText,
            title: 'Efficiency',
            valueColor: efficiencyTextColor,
            unit: efficiencyUnit,
          ),
        ],
      ),
    );
  }
}