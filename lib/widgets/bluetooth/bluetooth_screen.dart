import 'package:candle_dash/connection/bluetooth_manager.dart';
import 'package:candle_dash/widgets/bluetooth/discovered_device_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BluetoothScreen extends StatelessWidget {
  const BluetoothScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = context.read<BluetoothManager>();
    final isScanning = context.select((BluetoothManager bm) => bm.isScanning);
    final scanResults = context.select((BluetoothManager bm) => bm.scanResults);

    return PopScope(
      onPopInvoked: (_) => bluetoothManager.stopScan(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connect to Device'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 80),
          itemCount: scanResults.length,
          itemBuilder: (context, i) => 
            ScanResultTile(
              result: scanResults[i],
              onConnectIntent: () {
                Navigator.pop(context);
                bluetoothManager.connectToDevice(scanResults[i].device);
              },
            ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(isScanning ? Icons.close : Icons.refresh),
          onPressed: () => bluetoothManager.toggleScan(),
        ),
      ),
    );
  }
}