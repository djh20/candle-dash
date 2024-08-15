import 'package:candle_dash/theme.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:flutter/material.dart';

// TODO: Make these configurable.
const double inMaxPower = 30;
const double outMaxPower = 80;

class PowerBarDashItem extends StatelessWidget {
  const PowerBarDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final Color outColor = Theme.of(context).colorScheme.onSurface;
    const Color inColor = chargeColor;

    final power = Metric.watch<FloatMetric>(context, 'nl.motor_power');
    final gear = Metric.watch<IntMetric>(context, 'nl.gear');

    if (power == null) return DashItem.incompatible;
    
    return DashItem(
      child: AnimatedOpacity(
        opacity: (gear == null || (gear.getValue() ?? 0) > 0) ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Row(
          children: [
            PowerBarSegment(
              alignment: Alignment.centerRight,
              widthFactor: ((-(power.getValue() ?? 0)/ inMaxPower)).clamp(0, 1),
              color: inColor,
            ),
            const SizedBox(width: 4),
            PowerBarSegment(
              alignment: Alignment.centerLeft,
              widthFactor: (((power.getValue() ?? 0) / outMaxPower)).clamp(0, 1),
              color: outColor,
            ),
          ],
        ),
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