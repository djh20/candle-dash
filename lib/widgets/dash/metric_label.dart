import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/property_label.dart';
import 'package:flutter/material.dart';

class MetricLabel extends StatelessWidget {
  const MetricLabel(this.metric, {
    super.key,
    this.title,
    this.fontSize = 26,
    this.defaultValue,
    this.valueOverride,
    this.valueColor,
  });

  final Metric metric;
  final String? title;
  final double fontSize;
  final String? defaultValue;
  final String? valueOverride;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return PropertyLabel(
      value: valueOverride ?? metric.displayValue ?? defaultValue,
      unit: metric.unit,
      title: title,
      fontSize: fontSize,
      valueColor: valueColor,
    );
  }
}