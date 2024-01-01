import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:candle_dash/widgets/helpers/custom_animated_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpeedometerDashItem extends StatelessWidget {
  const SpeedometerDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final gear = Metric.watch<MetricInt>(context, StandardMetric.gear.id);
    final bool parked = (gear?.value == null || gear?.value == VehicleGear.park.index);
    
    return DashItem(
      child: SizedBox(
        height: 145,
        child: CustomAnimatedSwitcher(
          child: parked ? const _ParkedSpeedometer() : const _DrivingSpeedometer()
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
      speed?.value?.round().toString() ?? '',
      style: const TextStyle(
        fontSize: 180,
        height: 0.8,
        fontWeight: FontWeight.bold,
      ),
      // style: GoogleFonts.firaCode().copyWith(
      //   fontSize: 180,
      //   height: 1,
      //   fontWeight: FontWeight.bold,
      // ),
    );

    // return Column(
    //   children: [
    //     Text(
    //       speed?.value?.round().toString() ?? '',
    //       style: const TextStyle(
    //         fontSize: 180,
    //         height: 0.8,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     Opacity(
    //       opacity: 0.5,
    //       child: Text(
    //         speed?.unit.suffix?.toUpperCase() ?? '',
    //         style: const TextStyle(
    //           fontWeight: FontWeight.bold,
    //           fontSize: 16,
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}

class _ParkedSpeedometer extends StatelessWidget {
  // ignore: unused_element
  const _ParkedSpeedometer({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleRepresentation = 
      context.select((Vehicle? v) => v?.representation) ?? Vehicle.defaultRepresentation;

    return Opacity(
      opacity: 0.3,
      child: Image.asset(
        'assets/renders/${vehicleRepresentation.rendersFolderName}/parked.png',
      ),
    );
  }
}