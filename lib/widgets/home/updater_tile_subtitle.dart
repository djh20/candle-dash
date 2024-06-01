import 'package:candle_dash/ota/updater.dart';
import 'package:flutter/material.dart';

class UpdaterTileSubtitle extends StatelessWidget {
  final Updater? updater;

  const UpdaterTileSubtitle({
    super.key,
    required this.updater,
  });

  @override
  Widget build(BuildContext context) {
    if (updater == null) return const Text('N/A');
    if (updater!.currentVersion == null) return const Text('Unknown');

    if (updater!.isUpdating && updater!.currentTask != null) {
      String text = updater!.currentTask!.description;
      if (updater!.currentTaskProgress != null) {
        final progress = (updater!.currentTaskProgress! * 100).floor();
        text += ' ($progress%)';
      }
      return Text(text);

    } else if (updater!.updateAvailability == UpdateAvailability.newVersionAvailable) {
      return Row(
        children: [
          Text(updater!.currentVersion!.toString()),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(Icons.arrow_right_alt_rounded),
          ),
          Text(updater!.latestVersion!.toString()),
        ],
      );
    }

    return Text(updater!.currentVersion!.toString());
  }
}