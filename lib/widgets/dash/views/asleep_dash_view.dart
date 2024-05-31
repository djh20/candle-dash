import 'package:candle_dash/settings/app_settings.dart';
import 'package:candle_dash/widgets/dash/dash_column.dart';
import 'package:candle_dash/widgets/dash/brand_logo.dart';
import 'package:candle_dash/widgets/dash/horizontal_line.dart';
import 'package:candle_dash/widgets/dash/items/connection_status_indicator.dart';
import 'package:candle_dash/widgets/dash/views/dash_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AsleepDashView extends StatelessWidget {
  const AsleepDashView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool deviceSelected = context.select((AppSettings s) => s.selectedDeviceId != null);

    return DashView(
      children: [
        DashColumn(
          alignment: MainAxisAlignment.center,
          flex: 1,
          items: [
            deviceSelected ? 
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: BrandLogo(),
              ) :
              DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyLarge!,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Live stats unavailable',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    HorizontalLine(),
                    Text('No device selected'),
                  ],
                ),
              ),
            
            const ConnectionStatusIndicatorGizmo(),
          ],
        ),
      ],
    );
  }
}