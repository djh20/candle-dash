import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:candle_dash/widgets/helpers/custom_animated_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleRepresentation = context.select((Vehicle? v) => v?.representation);
    final isDarkTheme = Theme.of(context).colorScheme.brightness == Brightness.dark;

    return DashItem(
      height: 250,
      child: CustomAnimatedSwitcher(
        child: (vehicleRepresentation != null) ? 
          MediaQuery(
            data: MediaQuery.of(context).copyWith(invertColors: isDarkTheme),
            child: Image.asset(
              'assets/logos/${vehicleRepresentation.brand}.png',
            ),
          ) :
          const Center(
            child: CircularProgressIndicator(),
          ),
      ),
    );
  }
}
