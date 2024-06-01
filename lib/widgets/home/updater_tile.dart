import 'package:candle_dash/ota/updater.dart';
import 'package:candle_dash/widgets/home/updater_tile_button.dart';
import 'package:candle_dash/widgets/home/updater_tile_icon.dart';
import 'package:candle_dash/widgets/home/updater_tile_subtitle.dart';
import 'package:candle_dash/widgets/home/updater_tile_title.dart';
import 'package:flutter/material.dart';

class UpdaterTile extends StatelessWidget {
  final String name;
  final Updater? updater;
  final IconData disabledIcon;

  const UpdaterTile({
    super.key,
    required this.name,
    required this.updater,
    this.disabledIcon = Icons.bluetooth_disabled,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UpdaterTileIcon(
        updater: updater,
      ),
      title: UpdaterTileTitle(
        name: name,
        updater: updater,
      ),
      subtitle: UpdaterTileSubtitle(
        updater: updater,
      ),
      trailing: UpdaterTileButton(
        updater: updater,
      ),
      enabled: updater != null,
    );
  }
}