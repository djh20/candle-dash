import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:flutter/material.dart';

class CruiseIndicatorDashItem extends StatelessWidget {
  const CruiseIndicatorDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final cruiseSpeed = Metric.watch<IntMetric>(context, 'nl.cruise_speed');
    if (cruiseSpeed == null) return DashItem.incompatible;

    return DashItem(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(7, 152, 242, 1),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.speed,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                Text(
                  '${cruiseSpeed.getValue() ?? '--'}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}