import 'package:candle_dash/ota/updater.dart';
import 'package:flutter/material.dart';

class UpdaterTileButton extends StatelessWidget {
  final Updater? updater;
  final bool canInstall;

  const UpdaterTileButton({
    super.key,
    required this.updater,
    required this.canInstall,
  });

  @override
  Widget build(BuildContext context) {
    if (updater != null) {
      final availability = updater!.updateAvailability;
      final isUpdating = updater!.isUpdating;

      if (!isUpdating) {
        if (availability == UpdateAvailability.upToDate) {
          return const TextButton(
            onPressed: null,
            child: Text('Up to Date'),
          );

        } else if (availability == UpdateAvailability.newVersionAvailable) {
          return TextButton(
            onPressed: canInstall ? () => updater!.performUpdate() : null,
            child: const Text('Install'),
          );
        }
      }
    }

    return const SizedBox.shrink();
  }
}