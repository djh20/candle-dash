import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:candle_dash/widgets/dash/items/sideprofile.dart';
import 'package:candle_dash/widgets/helpers/custom_animated_switcher.dart';
import 'package:flutter/material.dart';

class SpeedometerDashItem extends StatelessWidget {
  const SpeedometerDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final gear = Metric.watch<MetricInt>(context, StandardMetric.gear.id);
    final bool parked = (gear?.value == null || gear?.value == VehicleGear.park.index);
    
    return DashItem(
      child: SizedBox(
        height: 135,
        child: CustomAnimatedSwitcher(
          child: parked ? const SideprofileDashItem() : const _DrivingSpeedometer(),
        ),
      ),
    );
  }
}

class _DrivingSpeedometer extends StatelessWidget {
  // ignore: unused_element
  const _DrivingSpeedometer({super.key});

  @override
  Widget build(BuildContext context) {
    final speed = Metric.watch<MetricFloat>(context, StandardMetric.speed.id);

    return Text(
      speed?.value?.round().toString() ?? '0',
      style: const TextStyle(
        fontSize: 170,
        height: 0.8,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}