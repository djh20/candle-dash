import 'package:candle_dash/managers/dash_manager.dart';
import 'package:candle_dash/vehicle/dummy_vehicle.dart';
import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/vehicle/vehicle.dart';
import 'package:candle_dash/widgets/dash/dash_action_dialog.dart';
import 'package:candle_dash/widgets/dash/views/asleep_dash_view.dart';
import 'package:candle_dash/widgets/dash/views/awake_dash_view.dart';
import 'package:candle_dash/widgets/helpers/custom_animated_switcher.dart';
import 'package:candle_dash/widgets/helpers/wakelock.dart';
import 'package:candle_dash/widgets/snack_bar_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const _hintSnackBar = SnackBar(
  width: 350,
  behavior: SnackBarBehavior.floating,
  duration: Duration(seconds: 2),
  content: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SnackBarIcon(Icons.touch_app),
      SizedBox(width: 10),
      Text('Press and hold anywhere to access menu'),
    ],
  ),
);

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      ScaffoldMessenger.of(context).showSnackBar(_hintSnackBar);
    });
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
    final editing = context.select((DashManager dm) => dm.editing);

    if (!editing) return const _DashScreenContent();

    return ChangeNotifierProvider<Vehicle?>(
      create: (_) => DummyVehicle(),
      child: const _DashScreenContent(),
    );
  }
}

class _DashScreenContent extends StatelessWidget {
  const _DashScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleAwake = Metric.watch<MetricInt>(context, StandardMetric.awake.id)?.value == 1;

    return PopScope(
      onPopInvoked: (didPop) => didPop ? ScaffoldMessenger.of(context).clearSnackBars() : null,
      child: GestureDetector(
        child: Scaffold(
          body: Stack(
            children: [
              CustomAnimatedSwitcher(
                child: vehicleAwake ? const AwakeDashView() : const AsleepDashView(),
              ),
              if (vehicleAwake) const Wakelock(),
            ],
          ),
        ),
        onLongPress: () => showDialog<void>(context: context, builder: (_) => const DashActionDialog()),
      ),
    );
  }
}