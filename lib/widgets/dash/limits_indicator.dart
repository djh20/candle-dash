import 'package:flutter/material.dart';

class LimitsIndicator extends StatelessWidget {
  const LimitsIndicator({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
  });

  final Widget title;
  final Widget subtitle;

  final double value;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    final double range = max - min;
    final double pos = value - min;
    final double progress = pos/range;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 18), 
          child: title,
        ),
        subtitle,
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
        ),
      ],
    );
  }
}