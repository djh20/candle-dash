import 'package:candle_dash/widgets/dash/dash_column.dart';
import 'package:candle_dash/widgets/dash/dash_sidebar.dart';
import 'package:flutter/material.dart';

class DashView extends StatelessWidget {
  const DashView({
    super.key,
    this.columns = const [],
  });

  final List<DashColumn> columns;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Row(
        children: [
          const DashSidebar(),
          Flexible(
            flex: 10,
            child: Row(
              children: columns,
            ),
          ),
        ],
      )
    );
  }
}