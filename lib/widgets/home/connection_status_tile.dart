import 'package:candle_dash/bluetooth/bluetooth_manager.dart';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ConnectionStatusTile extends StatelessWidget {
  const ConnectionStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSelected = context.select((AppSettings s) => s.selectedDeviceId != null);
    final statusMessage = context.select((BluetoothManager bm) => bm.statusMessage);
    final connectionState = context.select((BluetoothManager bm) => bm.connectionState);

    final connected = connectionState == BluetoothConnectionState.connected;
    final connecting = context.select((BluetoothManager bm) => bm.connecting);

    final String title = 
      connected ? 'Connected' : connecting ? 'Connecting' : 'Not Connected';

    final Color color =
      connected ? Colors.green : connecting ? Colors.orange[600]! : Colors.red;
    
    return ListTile(
      leading: Icon(
        Icons.circle,
        color: color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        (deviceSelected && statusMessage != null) ? statusMessage : 'Please select a scanner',
      ),
    );
  }
}