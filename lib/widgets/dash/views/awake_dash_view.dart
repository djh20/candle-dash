import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_column.dart';
import 'package:candle_dash/widgets/dash/items/battery_meter.dart';
import 'package:candle_dash/widgets/dash/items/battery_stats.dart';
import 'package:candle_dash/widgets/dash/items/clock.dart';
import 'package:candle_dash/widgets/dash/items/connection_status_indicator.dart';
import 'package:candle_dash/widgets/dash/items/cruise_indicator.dart';
import 'package:candle_dash/widgets/dash/items/gear_indicator.dart';
import 'package:candle_dash/widgets/dash/items/power_bar.dart';
import 'package:candle_dash/widgets/dash/items/speedometer.dart';
import 'package:candle_dash/widgets/dash/items/status_icons.dart';
import 'package:candle_dash/widgets/dash/items/trip_info.dart';
import 'package:candle_dash/widgets/dash/items/turn_signals.dart';
import 'package:candle_dash/widgets/dash/views/dash_view.dart';
import 'package:candle_dash/widgets/helpers/custom_animated_switcher.dart';
import 'package:flutter/material.dart';

class AwakeDashView extends StatelessWidget {
  const AwakeDashView({super.key});

  @override
  Widget build(BuildContext context) {
    final cruiseStatus = Metric.watch<IntMetric>(context, 'nl.cruise_status')?.getValue();

    return DashView(
      children: [
        DashColumn(
          flex: 2,
          items: [
            const ConnectionStatusDashItem(),
            Divider(
              indent: 10,
              endIndent: 10,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
            const StatusIconsDashItem(),
          ],
        ),
        DashColumn(
          flex: 11,
          items: [
            const PowerBarDashItem(),
            Stack(
              children: [
                SizedBox(
                  height: 42,
                  child: CustomAnimatedSwitcher(
                    child: (cruiseStatus != 2) ? 
                      const GearIndicatorDashItem() : 
                      const CruiseIndicatorDashItem(),
                  ),
                ),
  
                const TurnSignalsDashItem(),
              ],
            ),
            const SpeedometerDashItem(),
            const BatteryMeterDashItem(),
            const TripInfoDashItem(),
          ],
        ),
        const DashColumn(
          flex: 8,
          items: [
            ClockDashItem(),
            BatteryStatsDashItem(),
          ],
        ),
      ],
    );
  }
}