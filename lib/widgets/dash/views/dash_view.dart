import 'package:candle_dash/widgets/dash/dash_sidebar.dart';
import 'package:flutter/material.dart';

class DashView extends StatelessWidget {
  const DashView({
    super.key,
    this.children = const [],
    this.showSidebar = true,
  });

  final bool showSidebar;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Row(
        children: [
          if (showSidebar) ...const [
            DashSidebar(),
            // CustomVerticalDivider(),
          ],
          Flexible(
            flex: 10,
            child: Row(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}