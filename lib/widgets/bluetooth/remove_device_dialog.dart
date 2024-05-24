import 'package:candle_dash/bluetooth/known_bluetooth_device.dart';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RemoveDeviceDialog extends StatelessWidget {
  const RemoveDeviceDialog({
    super.key,
    required this.device,
  });

  final KnownBluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    final appSettings = context.read<AppSettings>();

    return AlertDialog(
      title: const Text('Remove device?'),
      content: Text('Do you really want to remove ${device.name}?'),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text(
            'Remove',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            appSettings.removeKnownDevice(device.id);
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}