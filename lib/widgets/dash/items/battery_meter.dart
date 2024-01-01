import 'package:candle_dash/theme.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:candle_dash/widgets/dash/metric_value_label.dart';
import 'package:flutter/material.dart';

class BatteryMeterDashItem extends StatelessWidget {
  const BatteryMeterDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final Color outColor = Theme.of(context).colorScheme.onBackground;
    const Color inColor = chargeColor;

    final soc = Metric.watch<MetricFloat>(context, StandardMetric.soc.id);
    final range = Metric.watch<MetricInt>(context, StandardMetric.range.id);
    
    return DashItem(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MetricValueLabel(soc, fontSize: 35),
              MetricValueLabel(range, fontSize: 35),
            ],
          ),
          LinearProgressIndicator(
            value: (soc?.value ?? 0) / 100,
            minHeight: 7,
            color: chargeColor,
          ),
        ],
      )
    );
  }
}
