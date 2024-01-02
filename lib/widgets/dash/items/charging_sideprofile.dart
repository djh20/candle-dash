import 'package:candle_dash/theme.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChargingSideprofileDashItem extends StatelessWidget {
  const ChargingSideprofileDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleRepresentation = 
      context.select((Vehicle? v) => v?.representation) ?? Vehicle.defaultRepresentation;

    // final charging = Metric.watch<MetricInt>(context, StandardMetric.chargeStatus.id);
    // final bool pluggedIn = (charging?.value != null && charging!.value! > 0);

    return DashItem(
      child: AspectRatio(
        aspectRatio: vehicleRepresentation.chargingRenderAspectRatio!,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/renders/${vehicleRepresentation.rendersDirectory}/charging.png',
              ),
            ),
            _BatteryPack(
              alignment: vehicleRepresentation.chargingRenderPackAlignment!,
              heightFactor: vehicleRepresentation.chargingRenderPackHeightFactor!,
              widthFactor: vehicleRepresentation.chargingRenderPackWidthFactor!,
            ),
          ],
        ),
      ),
    );
  }
}

class _BatteryPack extends StatelessWidget {
  const _BatteryPack({
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