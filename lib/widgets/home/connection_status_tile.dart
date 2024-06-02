import 'package:candle_dash/bluetooth/bluetooth_manager.dart';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectionStatusTile extends StatelessWidget {
  const ConnectionStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSelected = 
      context.select((AppSettings s) => s.selectedDeviceId != null);

    final statusMessage = context.select((BluetoothManager bm) => bm.statusMessage);

    final isConnected = context.select((BluetoothManager bm) => bm.isConnected);
    final isConnecting = context.select((BluetoothManager bm) => bm.isConnecting);

    final String title = 
      isConnected ? 'Connected' : isConnecting ? 'Connecting' : 'Not Connected';

    final Color color =
      isConnected ? Colors.green : isConnecting ? Colors.orange[600]! : Colors.red;
    
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
        deviceSelected ? (statusMessage ?? '...') : 'Please select a device',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}