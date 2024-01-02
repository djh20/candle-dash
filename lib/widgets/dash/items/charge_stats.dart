import 'dart:math';

import 'package:candle_dash/theme.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/custom_vertical_divider.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:candle_dash/widgets/dash/metric_label.dart';
import 'package:candle_dash/widgets/dash/property_label.dart';
import 'package:flutter/material.dart';

class ChargeStatsDashItem extends StatelessWidget {
  const ChargeStatsDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashItem(
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _ChargeIcon(),
            _BatteryStats(),
            CustomVerticalDivider(
              width: 50,
              indent: 20,
              endIndent: 20,
            ),
            _ChargeInfo(),
          ],
        ),
      ),
    );
  }
}

class _BatteryStats extends StatelessWidget {
  const _BatteryStats({super.key});

  @override
  Widget build(BuildContext context) {
    final range = Metric.watch<MetricInt>(context, StandardMetric.range.id);
    final soc = Metric.watch<MetricFloat>(context, StandardMetric.soc.id);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MetricLabel(
          soc,
          fontSize: 60,
        ),
        MetricLabel(
          range,
          fontSize: 32,
        ),
      ],
    );
  }
}

class _ChargeIcon extends StatelessWidget {
  final double size;

  const _ChargeIcon({
    Key? key,
    this.size = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool charging = Metric.watch<MetricInt>(context, StandardMetric.chargeStatus.id)?.value == 1;

    return Icon(
      Icons.bolt_rounded, 
      size: size,
      color: charging ? chargeColor : Colors.grey,
    );
  }
}

class _ChargeInfo extends StatelessWidget {
  const _ChargeInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final batteryPower = Metric.watch<MetricFloat>(context, StandardMetric.hvBattPower.id);
    final double powerInput = max(-(batteryPower?.value ?? 0), 0);

    final batteryTemperature = Metric.watch<MetricFloat>(context, StandardMetric.hvBattTemperature.id);

    final double soc = Metric.watch<MetricFloat>(context, StandardMetric.soc.id)?.value ?? 0;
    final int chargeStatus = Metric.watch<MetricInt>(context, StandardMetric.chargeStatus.id)?.value ?? 0;

    final int chargeTimeMinutes = Metric.watch<MetricInt>(context, StandardMetric.remainingChargeTime.id)?.value ?? 0;
    final Duration chargeTime = Duration(minutes: chargeTimeMinutes);

    final bool chargeFinished = (chargeStatus == 2);
    final bool chargeAlmostFinished = (soc >= 90) && (chargeStatus == 1);
    String chargeTimeText = '';

    if (chargeTime.inMinutes > 0) {
      if (chargeTime.inHours > 0) {
        chargeTimeText += '${chargeTime.inHours}h ';
      }

      chargeTimeText += '${chargeTime.inMinutes % 60}m';
    } else {
      chargeTimeText = 'TBD';
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!chargeFinished) ...[
          MetricLabel(
            batteryPower,
            title: 'Power',
            valueOverride: powerInput.round().toString(),
          ),
          MetricLabel(
            batteryTemperature,
            title: 'Battery Temperature',
            fontSize: 16,
          ),
        ],

        const SizedBox(height: 10),

        if (!chargeAlmostFinished && !chargeFinished) PropertyLabel(
          title: 'Time Left',
          value: chargeTimeText,
          unit: Unit.none,
        ),

        if (chargeAlmostFinished) const Text(
            'Almost Fully Charged',
            style: TextStyle(
              fontSize: 26,
              height: 1,
            ),
          ),

        if (chargeFinished) const Text(
          'Charging Complete',
          style: TextStyle(
            fontSize: 26,
          ),
        ),
      ],
    );
  }
}