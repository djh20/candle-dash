import 'package:candle_dash/connection/bluetooth_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class VehiclePage extends StatelessWidget {
  const VehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = context.read<BluetoothManager>();
    final connectionState = context.select((BluetoothManager bm) => bm.connectionState);

    final isConnected = connectionState == BluetoothConnectionState.connected;
    final isConnecting = context.select((BluetoothManager bm) => bm.isConnecting);
    final isBonded = context.select((BluetoothManager bm) => bm.isBonded);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isConnected ? 'Connected!' : isConnecting ? 'Connecting...' : 'Not Connected',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 5),

          if (!isConnected && !isConnecting && !isBonded) 
            FilledButton.tonalIcon(
              icon: const Icon(Icons.bluetooth_searching), 
              label: const Text('Scan for Devices'),
              onPressed: () {
                Navigator.pushNamed(context, '/bluetooth');
                bluetoothManager.startScan();
              },
            ),

          if (isBonded) 
            FilledButton.tonalIcon(
              icon: const Icon(Icons.bluetooth_disabled), 
              label: const Text('Unbond'),
              onPressed: () => bluetoothManager.disconnect(unbond: true),
            ),
            
          FilledButton.tonalIcon(
            icon: const Icon(Icons.dashboard), 
            label: const Text('Launch Dash'),
            onPressed: () => Navigator.pushNamed(context, '/dash'),
          ),
        ],
      ),
    );
  }
}