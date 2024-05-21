import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({
    super.key,
    required this.result,
    this.onAddIntent,
  });

  final ScanResult result;
  final VoidCallback? onAddIntent;

  @override
  Widget build(BuildContext context) {
    final device = result.device;

    return Card(
      child: ListTile(
        title: Text(device.advName.isNotEmpty ? device.advName : 'Unknown'),
        subtitle: Text(device.remoteId.str),
        trailing: FilledButton.tonalIcon(
          icon: const Icon(Icons.add),
          label: const Text('Add'),
          onPressed: onAddIntent,
        ),
      ),
    );
  }
}