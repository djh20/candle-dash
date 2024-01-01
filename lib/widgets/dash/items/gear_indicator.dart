import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:flutter/material.dart';

class GearIndicatorDashItem extends StatelessWidget {
  const GearIndicatorDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    int? gearIndex = Metric.watch<MetricInt>(context, StandardMetric.gear.id)?.value;

    return DashItem(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: VehicleGear.values.map(
          (g) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AnimatedOpacity(
              opacity: (gearIndex == g.index) ? 1 : 0.3,
              duration: const Duration(milliseconds: 100),
              child: Text(
                g.symbol,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
          )
        ).toList(),
      ),
    );
  }
}