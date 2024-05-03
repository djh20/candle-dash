import 'package:candle_dash/widgets/dash/dash_column.dart';
import 'package:candle_dash/widgets/dash/items/battery_meter.dart';
import 'package:candle_dash/widgets/dash/items/battery_stats.dart';
import 'package:candle_dash/widgets/dash/items/birdseye.dart';
import 'package:candle_dash/widgets/dash/items/clock.dart';
import 'package:candle_dash/widgets/dash/items/connection_status_indicator.dart';
import 'package:candle_dash/widgets/dash/items/gear_indicator.dart';
import 'package:candle_dash/widgets/dash/items/power_bar.dart';
import 'package:candle_dash/widgets/dash/items/speedometer.dart';
import 'package:candle_dash/widgets/dash/items/status_icons.dart';
import 'package:candle_dash/widgets/dash/items/trip_info.dart';
import 'package:candle_dash/widgets/dash/items/turn_signals.dart';
import 'package:candle_dash/widgets/dash/views/dash_view.dart';
import 'package:flutter/material.dart';

class AwakeDashView extends StatelessWidget {
  const AwakeDashView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashView(
      children: [
        DashColumn(
          flex: 2,
          items: [
            const ConnectionStatusIndicatorGizmo(),
            Divider(
              indent: 10,
              endIndent: 10,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
            ),
            const StatusIconsDashItem(),
          ],
        ),
        const DashColumn(
          flex: 11,
          items: [
            PowerBarGizmo(),
            Stack(
              children: [
                GearIndicatorGizmo(),
                TurnSignalsDashItem(),
              ],
            ),
            SpeedometerGizmo(),
            BatteryMeterGizmo(),
            TripInfoDashItem(),
          ],
        ),
        const DashColumn(
          flex: 8,
          overlay: BirdseyeGizmo(overlay: true),
          items: [
            ClockGizmo(),
            BatteryStatsGizmo(),
          ],
        ),
      ],
    );
  }
}