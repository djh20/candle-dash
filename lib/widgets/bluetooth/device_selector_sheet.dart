import 'package:candle_dash/bluetooth/bluetooth_manager.dart';
import 'package:candle_dash/bluetooth/known_bluetooth_device.dart';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:candle_dash/widgets/bluetooth/remove_device_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showDeviceSelectorSheet(BuildContext context) =>
  showModalBottomSheet<void>(
    context: context,
    enableDrag: false,
    builder: (BuildContext context) => const DeviceSelectorSheet(),
  );

class DeviceSelectorSheet extends StatelessWidget {
  const DeviceSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final bluetoothManager = context.read<BluetoothManager>();

    final bool deviceSelected = settings.selectedDeviceId != null;

    final bool devicesAvailable = 
      settings.knownDevices != null && settings.knownDevices!.isNotEmpty; 
    
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if(devicesAvailable) 
              _DeviceSelectorSheetList(devices: settings.knownDevices!),
        
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Device'),
                  onPressed: !deviceSelected ? () {
                    Navigator.pushNamed(context, '/bluetooth');
                    bluetoothManager.startScan();
                  } : null,
                ),
                if (devicesAvailable)
                  IconButton.filledTonal(
                    color: Colors.black,
                    icon: const Icon(Icons.deselect),
                    onPressed: deviceSelected ? () => settings.update((s) => s.selectedDeviceId = null) : null,
                  ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceSelectorSheetList extends StatelessWidget {
  const _DeviceSelectorSheetList({
    // ignore: unused_element
    super.key,
    required this.devices,
  });

  final List<KnownBluetoothDevice> devices;
  

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 200,
      ),
      child: ListView.builder(
        itemCount: devices.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final device = devices[index];
          final bool isSelected = settings.selectedDeviceId == device.id;

          return ListTile(
            leading: const Icon(Icons.bluetooth),
            title: Text(device.name),
            subtitle: Text(device.id),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: !isSelected ? () => settings.update((s) => s.selectedDeviceId = device.id) : null,
                  child: Text(!isSelected ? 'Select' : 'Selected'),
                ),
                const VerticalDivider(width: 5.0),
                IconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => RemoveDeviceDialog(device: device),
                  ), 
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}