import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:candle_dash/widgets/dash/items/incompatible.dart';
import 'package:candle_dash/widgets/dash/metric_label.dart';
import 'package:candle_dash/widgets/dash/property_label.dart';
import 'package:flutter/material.dart';

class TripInfoDashItem extends StatelessWidget {
  const TripInfoDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final tripDistance = Metric.watch<MetricFloat>(context, StandardMetric.tripDistance.id);

    if (tripDistance == null) {
      return IncompatibleDashItem(this);
    }

    final range = Metric.watch<MetricInt>(context, StandardMetric.range.id);
    final rangeLastCharge = Metric.watch<MetricInt>(context, StandardMetric.rangeLastCharge.id);
    
    int rangeVariation = 0;

    if (tripDistance.value != null && range?.value != null && rangeLastCharge?.value != null && rangeLastCharge!.value! > 0) {
      final double idealRange = rangeLastCharge.value! - tripDistance.value!;
      rangeVariation = (range!.value! - idealRange).round();
    }

    final String rangeVariationText = 
      (rangeVariation == 0) ? 'Perfect' :
      (rangeVariation >= 0) ? '+$rangeVariation' : '$rangeVariation';

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
            value: rangeVariationText,
            title: 'Efficiency',
            valueColor: (rangeVariation >= 0) ? Colors.green : Colors.red,
            unit: (rangeVariation != 0) ? Unit.kilometers : Unit.none,
          ),
        ],
      ),
    );
  }
}