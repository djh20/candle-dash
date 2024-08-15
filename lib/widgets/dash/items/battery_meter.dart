import 'package:candle_dash/theme.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:candle_dash/widgets/dash/metric_label.dart';
import 'package:flutter/material.dart';

class BatteryMeterDashItem extends StatelessWidget {
  const BatteryMeterDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final soc = Metric.watch<FloatMetric>(context, 'nl.soc');
    final range = Metric.watch<IntMetric>(context, 'nl.range');
    final chargeMode = Metric.watch<IntMetric>(context, 'nl.chg_mode');

    bool charging = (chargeMode != null && (chargeMode.getValue() ?? 0) > 0);

    if (soc == null) return DashItem.incompatible;
    
    return DashItem(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MetricLabel(soc, fontSize: 35),
              AnimatedOpacity(
                opacity: charging ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: const Icon(
                  Icons.bolt,
                  size: 36,
                  color: chargeColor,
                ),
              ),
              if (range != null) MetricLabel(range, fontSize: 35),
            ],
          ),
          LinearProgressIndicator(
            value: (soc.getValue() ?? 0) / 100,
            minHeight: 7,
            color: chargeColor,
            backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
