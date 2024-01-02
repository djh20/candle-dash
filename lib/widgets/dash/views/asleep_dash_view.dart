import 'package:candle_dash/widgets/dash/dash_column.dart';
import 'package:candle_dash/widgets/dash/items/sideprofile.dart';
import 'package:candle_dash/widgets/dash/items/trip_info.dart';
import 'package:candle_dash/widgets/dash/views/dash_view.dart';
import 'package:flutter/material.dart';

class AsleepDashView extends StatelessWidget {
  const AsleepDashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashView(
      children: [
        DashColumn(
          padding: EdgeInsets.only(top: 20),
          flex: 1,
          items: [
            SideprofileDashItem(),
            TripInfoDashItem(),
          ],
        ),
      ],
    );
  }
}