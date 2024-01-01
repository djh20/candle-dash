import 'package:candle_dash/widgets/dash/dash_column.dart';
import 'package:candle_dash/widgets/dash/items/connection_status_indicator.dart';
import 'package:flutter/material.dart';

class DashSidebar extends StatelessWidget {
  const DashSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashColumn(
      flex: 1,
      items: [
        ConnectionStatusIndicatorDashItem()
      ],
    );
  }
}