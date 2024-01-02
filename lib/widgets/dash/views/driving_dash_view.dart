import 'package:candle_dash/widgets/dash/dash_column.dart';
import 'package:candle_dash/widgets/dash/items/battery_meter.dart';
import 'package:candle_dash/widgets/dash/items/battery_stats.dart';
import 'package:candle_dash/widgets/dash/items/gear_indicator.dart';
import 'package:candle_dash/widgets/dash/items/power_bar.dart';
import 'package:candle_dash/widgets/dash/items/speedometer.dart';
import 'package:candle_dash/widgets/dash/items/trip_info.dart';
import 'package:candle_dash/widgets/dash/items/turn_signals.dart';
import 'package:candle_dash/widgets/dash/views/dash_view.dart';
import 'package:flutter/material.dart';

class DrivingDashView extends StatefulWidget {
  const DrivingDashView({super.key});

  @override
  State<DrivingDashView> createState() => _DrivingDashViewState();
}

class _DrivingDashViewState extends State<DrivingDashView> {
  bool showAdvanced = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => showAdvanced = !showAdvanced),
      child: DashView(
        children: [
          const DashColumn(
            flex: 10,
            items: [
              PowerBarDashItem(),
              Stack(
                children: [
                  GearIndicatorDashItem(),
                  TurnSignalsDashItem(),
                ],
              ),
              SpeedometerDashItem(),
              BatteryMeterDashItem(),
              TripInfoDashItem(),
            ],
          ),
          if (showAdvanced) ... const [
            // CustomVerticalDivider(),
            DashColumn(
              flex: 7,
              items: [
                BatteryStatsDashItem(),
              ],
            ),
          ],
        ],
      ),
    );
  }
}