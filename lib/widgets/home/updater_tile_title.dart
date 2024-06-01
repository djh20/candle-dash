import 'package:candle_dash/ota/updater.dart';
import 'package:flutter/material.dart';

class UpdaterTileTitle extends StatelessWidget {
  final String name;
  final Updater? updater;

  const UpdaterTileTitle({
    super.key,
    required this.name,
    required this.updater,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUpdateAvailable = 
      updater?.updateAvailability == UpdateAvailability.newVersionAvailable;

    final String suffix = isUpdateAvailable ? 'Update' : 'Version';

    return Text('$name $suffix');
  }
}