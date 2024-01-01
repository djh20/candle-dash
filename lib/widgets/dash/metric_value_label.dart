import 'package:candle_dash/vehicle/metric.dart';
import 'package:flutter/material.dart';

class MetricValueLabel extends StatelessWidget {
  const MetricValueLabel(this.metric, {
    super.key,
    this.fontSize = 26,
  });

  final Metric? metric;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          metric?.displayValue ?? '?',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (metric?.unit != Unit.none) ...[
          Opacity(
            opacity: 0.8,
            child: Text(
              metric?.unit.suffix ?? '?',
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ]
      ],
    );
  }
}