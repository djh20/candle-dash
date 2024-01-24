import 'dart:ui' as ui;

import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:candle_dash/widgets/dash/gizmo.dart';
import 'package:candle_dash/widgets/dash/property_label.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BirdseyeGizmo extends Gizmo {
  const BirdseyeGizmo({super.key}) : super(
    name: 'Birds-eye',
    height: 350,
  );
  
  @override
  Widget buildContent(BuildContext context) {
    final vehicleRepresentation = context.select((Vehicle? v) => v?.representation);
    if (vehicleRepresentation == null) return spinner;

    final gear = Metric.watch<MetricInt>(context, StandardMetric.gear.id)?.value ?? 0;
    final flTirePressure = Metric.watch<MetricFloat>(context, StandardMetric.flTirePressure.id);
    final frTirePressure = Metric.watch<MetricFloat>(context, StandardMetric.frTirePressure.id);
    final rlTirePressure = Metric.watch<MetricFloat>(context, StandardMetric.rlTirePressure.id);
    final rrTirePressure = Metric.watch<MetricFloat>(context, StandardMetric.rrTirePressure.id);

    return DashItem(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (gear == VehicleGear.drive.index) const _Trajectory(
            travelDirection: VerticalDirection.up,
          ),
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Opacity(
                opacity: 0.5,
                child: Image.asset(
                  'assets/renders/${vehicleRepresentation.rendersDirectory}/birdseye.png',
                  height: 230,
                ),
              ),
              if (flTirePressure != null) _TirePressureLabel(
                metric: flTirePressure,
                left: -25,
                top: 25,
              ),
              if (frTirePressure != null) _TirePressureLabel(
                metric: frTirePressure,
                right: -25,
                top: 25,
              ),
              if (rlTirePressure != null) _TirePressureLabel(
                metric: rlTirePressure,
                left: -25,
                bottom: 25,
              ),
              if (rrTirePressure != null) _TirePressureLabel(
                metric: rrTirePressure,
                right: -25,
                bottom: 25,
              ),
            ],
          ),
          if (gear == VehicleGear.reverse.index) const _Trajectory(
            travelDirection: VerticalDirection.down,
          ),
        ],
      ),
    );
  }
}

class _TirePressureLabel extends StatelessWidget {
  const _TirePressureLabel({
    super.key,
    required this.metric,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  final Metric metric;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: PropertyLabel(
        value: metric.displayValue,
        valueColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.4),
        fontSize: 20,
        unit: Unit.none,
      ),
    );
  }
}

class _Trajectory extends StatelessWidget {
  const _Trajectory({
    super.key,
    required this.travelDirection,
  });

  final VerticalDirection travelDirection;

  @override
  Widget build(BuildContext context) {
    final steeringAngle = Metric.watch<MetricFloat>(context, StandardMetric.steeringAngle.id)?.value ?? 0;

    return Transform.flip(
      flipY: (travelDirection == VerticalDirection.down),
      child: CustomPaint(
        painter: _TrajectoryPainter(
          steeringAngle: steeringAngle,
          color: Theme.of(context).colorScheme.onBackground,
        ),
        size: const Size(double.infinity, 100),
      ),
    );
  }
}

class _TrajectoryPainter extends CustomPainter {
  _TrajectoryPainter({
    required this.steeringAngle,
    required this.color,
  });

  final double steeringAngle;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const double yOffset = -15;

    final double startX = size.width / 2;
    final double startY = size.height + yOffset;
    
    const double endY = 0;
    final double controlY = (size.height / 2) + yOffset;

    final double endXOffset = steeringAngle * 100;

    final paint = Paint()
    ..strokeWidth = 30
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.square
    ..shader = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(0, size.height),
      [
        color.withOpacity(0),
        color.withOpacity(0.8),
      ],
    );

    final path = Path();
    final double endX = startX + endXOffset;
    path.moveTo(startX, startY);
    path.quadraticBezierTo(startX, controlY, endX, endY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrajectoryPainter oldDelegate) {
    return 
      oldDelegate.steeringAngle != steeringAngle ||
      oldDelegate.color != color;
  }
}