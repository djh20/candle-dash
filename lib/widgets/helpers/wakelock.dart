import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class Wakelock extends StatefulWidget {
  const Wakelock({super.key});

  @override
  State<Wakelock> createState() => _WakelockState();
}

class _WakelockState extends State<Wakelock> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    debugPrint('WAKELOCK ENABLED');
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
    debugPrint('WAKELOCK DISABLED');
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}