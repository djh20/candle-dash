import 'package:candle_dash/theme.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/gizmo.dart';
import 'package:candle_dash/widgets/dash/metric_label.dart';
import 'package:flutter/material.dart';

class BatteryMeterGizmo extends Gizmo {
  const BatteryMeterGizmo({super.key}) : super(
    name: 'Battery Meter',
    height: 57,
  );

  @override
  Widget buildContent(BuildContext context) {
    final soc = Metric.watch<MetricFloat>(context, StandardMetric.soc.id);
    final range = Metric.watch<MetricInt>(context, StandardMetric.range.id);
    final charging = Metric.watch<MetricInt>(context, StandardMetric.chargeStatus.id)?.value == 1;

    if (soc == null) return incompatible;
    
    return Column(
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
          value: (soc.value ?? 0) / 100,
          minHeight: 7,
          color: chargeColor,
          backgroundColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
        ),
      ],
    );
  }
}
