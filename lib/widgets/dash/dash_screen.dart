import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/views/asleep_dash_view.dart';
import 'package:candle_dash/widgets/dash/views/charging_dash_view.dart';
import 'package:candle_dash/widgets/dash/views/driving_dash_view.dart';
import 'package:candle_dash/widgets/helpers/custom_animated_switcher.dart';
import 'package:candle_dash/widgets/helpers/wakelock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashScreen extends StatefulWidget {
  const DashScreen({super.key});

  @override
  State<DashScreen> createState() => _DashScreenState();
}

class _DashScreenState extends State<DashScreen> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual, 
      overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top,
      ],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAwake = Metric.watch<MetricInt>(context, StandardMetric.awake.id)?.value == 1;
    final charging = Metric.watch<MetricInt>(context, StandardMetric.chargeStatus.id);
    final bool pluggedIn = (charging?.value != null && charging!.value! > 0);

    return GestureDetector(
      child: Scaffold(
        body: Stack(
          children: [
            CustomAnimatedSwitcher(
              child: vehicleAwake ? 
                (!pluggedIn ? const DrivingDashView() : const ChargingDashView()) :
                const AsleepDashView(),
            ),
            if (vehicleAwake) const Wakelock(),
          ],
        ),
      ),
      onLongPress: () => Navigator.pop(context),
    );
  }
}