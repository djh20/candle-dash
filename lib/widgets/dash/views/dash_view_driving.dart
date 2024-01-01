import 'package:candle_dash/widgets/dash/dash_column.dart';
import 'package:candle_dash/widgets/dash/items/battery_meter.dart';
import 'package:candle_dash/widgets/dash/items/gear_indicator.dart';
import 'package:candle_dash/widgets/dash/items/power_bar.dart';
import 'package:candle_dash/widgets/dash/items/speedometer.dart';
import 'package:candle_dash/widgets/dash/views/dash_view.dart';
import 'package:flutter/material.dart';

class DashViewDriving extends StatelessWidget {
  const DashViewDriving({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashView(
      columns: [
        DashColumn(
          flex: 2,
          items: [
            PowerBarDashItem(),
            GearIndicatorDashItem(),
            SpeedometerDashItem(),
            BatteryMeterDashItem(),
          ],
        ),
        DashColumn(
          flex: 1,
          items: [],
        ),
      ],
    );
  }
}