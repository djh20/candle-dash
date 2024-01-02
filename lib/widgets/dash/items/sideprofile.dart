import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideprofileDashItem extends StatelessWidget {
  const SideprofileDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleRepresentation = 
      context.select((Vehicle? v) => v?.representation) ?? Vehicle.defaultRepresentation;

    return DashItem(
      child: Opacity(
        opacity: 0.4,
        child: Image.asset(
          'assets/renders/${vehicleRepresentation.rendersDirectory}/parked.png',
        ),
      ),
    );
  }
}
