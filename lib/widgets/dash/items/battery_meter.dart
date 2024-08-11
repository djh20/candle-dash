import 'package:candle_dash/theme.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/metric_label.dart';
import 'package:candle_dash/widgets/dash/new_gizmo.dart';
import 'package:flutter/material.dart';

class BatteryMeterGizmo extends NewGizmo {
  const BatteryMeterGizmo({super.key, super.overlay}) : super(
    name: 'Battery Meter',
  );

  @override
  State<NewGizmo> createState() => _BatteryMeterGizmoState();
}

class _BatteryMeterGizmoState extends NewGizmoState {
  @override
  Widget buildContent(BuildContext context) {
    final soc = Metric.watch<FloatMetric>(context, 'nl.soc');
    final range = Metric.watch<IntMetric>(context, 'nl.range');
    final chargeMode = Metric.watch<IntMetric>(context, 'nl.chg_mode');

    bool charging = (chargeMode != null && (chargeMode.getValue() ?? 0) > 0);

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
          value: (soc.getValue() ?? 0) / 100,
          minHeight: 7,
          color: chargeColor,
          backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
        ),
      ],
    );
  }
}
