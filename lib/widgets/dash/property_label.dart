import 'package:candle_dash/vehicle/metric.dart';
import 'package:flutter/material.dart';

class PropertyLabel extends StatelessWidget {
  const PropertyLabel({
    super.key,
    required this.value,
    required this.unit,
    this.title,
    this.fontSize = 26,
    this.valueColor,
  });
  
  final String value;
  final Unit unit;
  final double fontSize;
  final String? title;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            title!,
            style: TextStyle(fontSize: fontSize),
          ),
        ),
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 4),
        //     child: Container(
        //       height: 1,
        //       width: 10,
        //       decoration: BoxDecoration(
        //         color: Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
        //       ),
        //     ),
        //   ),
        // ],
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        
        if (unit != Unit.none) ...[
          Opacity(
            opacity: 0.8,
            child: Text(
              unit.suffix,
              style: TextStyle(
                fontSize: fontSize, 
                color: valueColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}