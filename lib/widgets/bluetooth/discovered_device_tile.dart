import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({
    super.key,
    required this.result,
    this.onConnectIntent,
  });

  final ScanResult result;
  final VoidCallback? onConnectIntent;

  @override
  Widget build(BuildContext context) {
    final device = result.device;

    return Card(
      child: ListTile(
        title: Text(device.advName.isNotEmpty ? device.advName : 'Unknown'),
        subtitle: Text(device.remoteId.str),
        trailing: TextButton(
          onPressed: onConnectIntent,
          child: const Text('Connect'),
        ),
      ),
    );
  }
}