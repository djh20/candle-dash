import 'dart:ui' as ui;
import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:candle_dash/widgets/dash/new_gizmo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BirdseyeGizmo extends NewGizmo {
  const BirdseyeGizmo({super.key, super.overlay}) : super(
    name: 'Birds-eye',
  );

  @override
  State<NewGizmo> createState() => _BirdseyeGizmoState();
}

class _BirdseyeGizmoState extends NewGizmoState {
  @override
  Widget buildContent(BuildContext context) {
    final vehicleRepresentation = context.select((Vehicle? v) => v?.representation);
    if (vehicleRepresentation == null) return spinner;
    
    final speed = Metric.watch<MetricFloat>(context, StandardMetric.speed.id)?.value ?? 0;
    final gear = Metric.watch<MetricInt>(context, StandardMetric.gear.id)?.value ?? 0;

    if (isOverlayVisible && (speed >= 10 || gear == 0)) {
      hideOverlay();
    } else if (!isOverlayVisible && gear > 0 && speed == 0) {
      showOverlay();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (gear == VehicleGear.drive.index) const _Trajectory(
          travelDirection: VerticalDirection.up,
        ),
        Opacity(
          opacity: 0.5,
          child: Image.asset(
            'assets/renders/${vehicleRepresentation.rendersDirectory}/birdseye.png',
            height: 230,
          ),
        ),
        if (gear == VehicleGear.reverse.index) const _Trajectory(
          travelDirection: VerticalDirection.down,
        ),
      ],
    );
  }
}

class _Trajectory extends StatelessWidget {
  const _Trajectory({
    // ignore: unused_element
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
          color: Theme.of(context).colorScheme.onSurface,
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
    final double controlY = (size.height / 3) + yOffset;

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