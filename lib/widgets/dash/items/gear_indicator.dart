import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:flutter/material.dart';

class GearIndicatorDashItem extends StatelessWidget {
  const GearIndicatorDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final gear = Metric.watch<IntMetric>(context, 'nl.gear');

    if (gear == null) return DashItem.incompatible;

    return DashItem(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: VehicleGear.values.map(
          (g) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedOpacity(
              opacity: (gear.getValue() == g.index) ? 1 : 0.3,
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
      ),
    );
  }
}