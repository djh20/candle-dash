import 'package:candle_dash/widgets/dash/dash_column.dart';
import 'package:candle_dash/widgets/dash/items/charge_stats.dart';
import 'package:candle_dash/widgets/dash/items/charging_sideprofile.dart';
import 'package:candle_dash/widgets/dash/views/dash_view.dart';
import 'package:flutter/material.dart';

class ChargingDashView extends StatelessWidget {
  const ChargingDashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashView(
      children: [
        DashColumn(
          flex: 1,
          items: [
            ChargeStatsDashItem(),
            ChargingSideprofileDashItem(),
          ],
        ),
      ],
    );
  }
}