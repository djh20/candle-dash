import 'package:candle_dash/managers/bluetooth_manager.dart';
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
    final isConnecting = context.select((BluetoothManager bm) => bm.isConnecting);

    String text = 'Not Connected';
    Color backgroundColor = Colors.red;
    IconData icon = Icons.bluetooth_disabled;

    if (isConnected) {
      text = 'Connected';
      backgroundColor = Colors.green;
      icon = Icons.bluetooth_connected;
    } else if (isConnecting) {
      text = 'Connecting...';
      backgroundColor = Colors.orange;
      icon = Icons.bluetooth_searching;
    }
    
    return DashItem(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) { 
          final compact = constraints.maxWidth < 150;

          return Center(
            child: Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                  ),
                  if (!compact) Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}