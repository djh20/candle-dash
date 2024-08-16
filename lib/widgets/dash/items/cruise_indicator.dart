import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:flutter/material.dart';

class CruiseIndicatorDashItem extends StatelessWidget {
  const CruiseIndicatorDashItem({super.key});
  
  static const _color = Color.fromRGBO(7, 152, 242, 1);

  @override
  Widget build(BuildContext context) {
    final cruiseSpeed = Metric.watch<IntMetric>(context, 'nl.cruise_speed');
    if (cruiseSpeed == null) return DashItem.incompatible;

    return DashItem(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.speed,
              size: 24,
              color: _color,
            ),
            const SizedBox(width: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${cruiseSpeed.getValue() ?? '--'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: _color,
                  fontSize: 100,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}