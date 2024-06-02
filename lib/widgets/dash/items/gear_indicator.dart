import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:candle_dash/widgets/dash/gizmo.dart';
import 'package:flutter/material.dart';

class GearIndicatorGizmo extends Gizmo {
  const GearIndicatorGizmo({super.key}) : super(
    name: 'Gear Indicator',
  );

  @override
  Widget buildContent(BuildContext context) {
    final gear = Metric.watch<MetricInt>(context, StandardMetric.gear.id);

    if (gear == null) return incompatible;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: VehicleGear.values.map(
        (g) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: AnimatedOpacity(
            opacity: (gear.value == g.index) ? 1 : 0.3,
            duration: const Duration(milliseconds: 100),
            child: Text(
              g.symbol,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ).toList(),
    );
  }
}