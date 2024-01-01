import 'package:candle_dash/vehicle/metric.dart';
import 'package:flutter/material.dart';

class Speedometer extends StatelessWidget {
  const Speedometer({super.key});

  static const List<String> gearSymbols = ['P', 'R', 'N', ''];

  @override
  Widget build(BuildContext context) {
    final gear = Metric.watch<MetricInt>(context, StandardMetric.gear.id);
    final speed = Metric.watch<MetricFloat>(context, StandardMetric.speed.id);

    final soc = Metric.watch<MetricFloat>(context, StandardMetric.soc.id);
    final power = Metric.watch<MetricFloat>(context, StandardMetric.hvBattPower.id);
    
    final String gearSymbol = gearSymbols[gear?.value ?? 3];
    final String speedText = gearSymbol == '' ? (speed?.value ?? 0).round().toString() : gearSymbol;
    
    return Column(
      children: [
        Text(
          "32",
          style: const TextStyle(
            fontSize: 180,
            height: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Power: ${power?.value ?? 0} kW',
          style: const TextStyle(
            fontSize: 26,
          ),
        ),
        Text(
          'Charge: ${soc?.value ?? 0}%',
          style: const TextStyle(
            fontSize: 26,
          ),
        ),
      ],
    );
  }
}