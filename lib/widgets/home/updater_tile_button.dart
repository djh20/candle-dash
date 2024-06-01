import 'package:candle_dash/ota/updater.dart';
import 'package:flutter/material.dart';

class UpdaterTileButton extends StatelessWidget {
  final Updater? updater;

  const UpdaterTileButton({
    super.key,
    required this.updater,
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
            onPressed: () => updater!.performUpdate(),
            child: const Text('Install'),
          );
        }
      }
    }

    return const SizedBox.shrink();
  }
}