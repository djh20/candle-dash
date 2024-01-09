import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:flutter/material.dart';

class IncompatibleDashItem extends StatelessWidget {
  const IncompatibleDashItem(this.incompatibleWidget, {
    super.key,
  });

  final Widget incompatibleWidget;

  @override
  Widget build(BuildContext context) {
    return DashItem(
      child: Center(
        child: Opacity(
          opacity: 0.6,
          child: Text('${incompatibleWidget.runtimeType} incompatible with current vehicle'),
        ),
      ),
    );
  }
}