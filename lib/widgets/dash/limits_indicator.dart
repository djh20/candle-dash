import 'package:candle_dash/utils.dart';
import 'package:flutter/material.dart';

class LimitsIndicator extends StatelessWidget {
  const LimitsIndicator({
    super.key,
    this.title,
    required this.displayValue,
    required this.value,
    required this.min,
    required this.max,
    required this.minColor,
    required this.midColor,
    required this.maxColor,
  });

  final Widget? title;
  final Widget displayValue;

  final double value;
  final double min;
  final double max;
  final Color minColor;
  final Color midColor;
  final Color maxColor;

  @override
  Widget build(BuildContext context) {
    final double range = max - min;
    final double pos = value - min;
    final double progress = pos/range;

    late final Color color;

    if (progress >= 0.5) {
      color = lerpColor((progress-0.5)*2, from: midColor, to: maxColor);
    } else {
      color = lerpColor(progress*2, from: minColor, to: midColor);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 18), 
          child: title!,
        ),
        displayValue,
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
          color: color,
        ),
      ],
    );
  }
}