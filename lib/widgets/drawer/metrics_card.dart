import 'package:candle_dash/model.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class MetricsCardContent extends StatelessWidget {
  const MetricsCardContent({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PropertyChangeConsumer<AppModel, String>(
      builder: (context, model, properties) {
        List<Widget> items = [];
        final metrics = model?.vehicle.metrics;

        if (metrics != null) {
          metrics.forEach((key, value) {
            items.add(
              Text(
                '$key: $value',
                style: const TextStyle(fontSize: 12)
              )
            );
          });
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items,
        );

      }
    );
  }
}