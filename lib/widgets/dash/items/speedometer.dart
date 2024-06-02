import 'package:candle_dash/theme.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:candle_dash/widgets/dash/gizmo.dart';
import 'package:candle_dash/widgets/helpers/custom_animated_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpeedometerGizmo extends Gizmo {
  const SpeedometerGizmo({super.key}) : super(
    name: 'Speedometer',
  );

  @override
  Widget buildContent(BuildContext context) {
    final speed = Metric.watch<MetricFloat>(context, StandardMetric.speed.id);
    final gear = Metric.watch<MetricInt>(context, StandardMetric.gear.id);

    if (speed == null) return incompatible;

    final bool parked = (gear?.value == null || gear?.value == VehicleGear.park.index);
    
    return SizedBox(
      height: 135,
      child: CustomAnimatedSwitcher(
        child: parked ? const _Sideprofile() : _Speedo(speed: speed.value ?? 0),
      ),
    );
  }
}

class _Speedo extends StatefulWidget {
  const _Speedo({
    // ignore: unused_element
    super.key,
    required this.speed,
  });

  final double speed;

  @override
  State<_Speedo> createState() => _SpeedoState();
}

class _SpeedoState extends State<_Speedo> {
  int displayedSpeed = 0;

  @override
  Widget build(BuildContext context) {
    // 'Deadzone' logic to stop speedo from rapidly alternating between values at rounding threshold.
    if (widget.speed >= displayedSpeed + 0.5 || widget.speed <= displayedSpeed - 1) {
      displayedSpeed = widget.speed.round();
    }

    return Text(
      displayedSpeed.toString(),
      style: const TextStyle(
        fontSize: 170,
        height: 0.8,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _Sideprofile extends StatelessWidget {
  // ignore: unused_element
  const _Sideprofile({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleRepresentation = context.select((Vehicle? v) => v?.representation);

    if (vehicleRepresentation == null) {
      return const CircularProgressIndicator();
    }

    final chargeStatus = Metric.watch<MetricInt>(context, StandardMetric.chargeStatus.id);
    final bool pluggedIn = (chargeStatus?.value != null && chargeStatus!.value! > 0);

    final String image = pluggedIn ? 'charging.png' : 'parked.png';

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.4,
          child: Image.asset(
            'assets/renders/${vehicleRepresentation.rendersDirectory}/$image',
          ),
        ),
        if (pluggedIn) AspectRatio(
          aspectRatio: vehicleRepresentation.chargingRenderAspectRatio!,
          child: _BatteryPack(
            alignment: vehicleRepresentation.chargingRenderPackAlignment!,
            heightFactor: vehicleRepresentation.chargingRenderPackHeightFactor!,
            widthFactor: vehicleRepresentation.chargingRenderPackWidthFactor!,
          ),
        ),
      ],
    );
  }
}

class _BatteryPack extends StatelessWidget {
  const _BatteryPack({
    // ignore: unused_element
    super.key,
    required this.alignment,
    required this.widthFactor,
    required this.heightFactor,
  });

  final Alignment alignment;
  final double widthFactor;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    final double soc = Metric.watch<MetricFloat>(context, StandardMetric.soc.id)?.value ?? 0;

    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: alignment,
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          heightFactor: heightFactor,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: soc/100,
              child: Container(
                decoration: BoxDecoration(
                  color: chargeColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}