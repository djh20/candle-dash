import 'package:candle_dash/theme.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/gizmo.dart';
import 'package:flutter/material.dart';

// TODO: Make these configurable.
const double inMaxPower = 30;
const double outMaxPower = 80;
const double deadZone = 1;

class PowerBarGizmo extends Gizmo {
  const PowerBarGizmo({super.key}) : super(
    name: 'Power Bar',
    height: 7,
  );

  @override
  Widget buildContent(BuildContext context) {
    final Color outColor = Theme.of(context).colorScheme.onSurface;
    const Color inColor = chargeColor;

    final power = Metric.watch<MetricFloat>(context, StandardMetric.hvBattPower.id);
    final gear = Metric.watch<MetricInt>(context, StandardMetric.gear.id);

    if (power == null) return incompatible;
    
    return AnimatedOpacity(
      opacity: (gear == null || (gear.value ?? 0) > 0) ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: Row(
        children: [
          PowerBarSegment(
            alignment: Alignment.centerRight,
            widthFactor: (((-(power.value ?? 0) - deadZone) / inMaxPower)).clamp(0, 1),
            color: inColor,
          ),
          const SizedBox(width: 4),
          PowerBarSegment(
            alignment: Alignment.centerLeft,
            widthFactor: ((((power.value ?? 0) - deadZone) / outMaxPower)).clamp(0, 1),
            color: outColor,
          ),
        ],
      ),
    );
  }
}

class PowerBarSegment extends StatelessWidget {
  final Alignment alignment;
  final double widthFactor;
  final Color color;
  
  const PowerBarSegment({
    Key? key,
    required this.alignment,
    required this.widthFactor,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 7,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: AnimatedFractionallySizedBox(
          widthFactor: widthFactor,
          alignment: alignment,
          duration: const Duration(milliseconds: 100),
          child: Container(
            color: color,
          ),
        ),
      ),
    );
  }
}