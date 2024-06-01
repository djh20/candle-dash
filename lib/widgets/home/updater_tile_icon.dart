import 'package:candle_dash/ota/updater.dart';
import 'package:flutter/material.dart';

class UpdaterTileIcon extends StatelessWidget {
  final Updater? updater;
  final IconData disabledIcon;

  const UpdaterTileIcon({
    super.key,
    required this.updater,
    this.disabledIcon = Icons.bluetooth_disabled,
  });

  @override
  Widget build(BuildContext context) {
    if (updater == null) return Icon(disabledIcon);

    final availability = updater!.updateAvailability;

    if (availability == UpdateAvailability.checking || updater!.isUpdating) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(),
      );

    } else if (availability == UpdateAvailability.upToDate) {
      return const Icon(Icons.check);

    } else if (availability == UpdateAvailability.newVersionAvailable) {
      return const Icon(Icons.cloud_download);
    }

    return const Icon(Icons.cloud_off);
  }
}