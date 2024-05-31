import 'package:candle_dash/bluetooth/bluetooth_manager.dart';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:candle_dash/widgets/bluetooth/scan_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BluetoothPage extends StatelessWidget {
  const BluetoothPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<AppSettings>();
    final bluetoothManager = context.read<BluetoothManager>();
    final isScanning = context.select((BluetoothManager bm) => bm.isScanning);
    final scanResults = context.select((BluetoothManager bm) => bm.scanResults);
    
    final validScanResults = scanResults.where(
      (result) => result.advertisementData.advName.isNotEmpty,
    ).toList();

    return PopScope(
      onPopInvoked: (didPop) => didPop ? bluetoothManager.stopScan() : null,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Device'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 80),
          itemCount: validScanResults.length,
          itemBuilder: (context, i) {
            final result = validScanResults[i];
            return ScanResultTile(
              result: result,
              onAddIntent: () {
                final id = result.device.remoteId.str;
                Navigator.pop(context);
                settings.addKnownDevice(id, result.device.advName);
                settings.update((s) => s.selectedDeviceId = id);
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(isScanning ? Icons.close : Icons.refresh),
          onPressed: () => bluetoothManager.toggleScan(),
        ),
      ),
    );
  }
}