import 'package:candle_dash/theme.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:flutter/material.dart';

const double inMaxPower = 30;
const double outMaxPower = 80;
const double deadZone = 1;

class PowerBarDashItem extends StatelessWidget {
  const PowerBarDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final Color outColor = Theme.of(context).colorScheme.onBackground;
    const Color inColor = chargeColor;

    double power = Metric.watch<MetricFloat>(context, StandardMetric.hvBattPower.id)?.value ?? 0;
    
    return DashItem(
      child: Row(
        children: [
          PowerBarSegment(
            alignment: Alignment.centerRight,
            widthFactor: (((-power - deadZone) / inMaxPower)).clamp(0, 1),
            color: inColor,
          ),
          const SizedBox(width: 4),
          PowerBarSegment(
            alignment: Alignment.centerLeft,
            widthFactor: (((power - deadZone) / outMaxPower)).clamp(0, 1),
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
    required this.color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
        ),
        clipBehavior: Clip.antiAlias,
        child: AnimatedFractionallySizedBox(
          widthFactor: widthFactor,
          alignment: alignment,
          duration: const Duration(milliseconds: 100),
          child: Container(
            color: color,
            height: 7,
          ),
        ),
      ),
    );
  }
}