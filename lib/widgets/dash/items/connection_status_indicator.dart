import 'package:candle_dash/connection/bluetooth_manager.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class ConnectionStatusIndicatorDashItem extends StatelessWidget {
  const ConnectionStatusIndicatorDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    final connectionState = context.select((BluetoothManager bm) => bm.connectionState);
    final isConnected = (connectionState == BluetoothConnectionState.connected);

    return DashItem(
      child: Container(
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: isConnected? Colors.green : Colors.red,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isConnected ? Icons.bluetooth_searching : Icons.bluetooth_disabled,
          color: Colors.white,
        ),
      ),
    );
  }
}