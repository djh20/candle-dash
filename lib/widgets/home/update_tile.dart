import 'package:candle_dash/update_manager.dart';
import 'package:flutter/material.dart';
import 'package:version/version.dart';

class UpdateTile extends StatelessWidget {
  const UpdateTile({
    super.key,
    required this.name,
    required this.availability,
    required this.onUpdatePressed,
    this.currentVersion,
    this.latestVersion,
    this.enabled = true,
    this.disabledIcon = Icons.bluetooth_disabled,
  });

  final String name;
  final UpdateAvailability availability;
  final VoidCallback onUpdatePressed;
  final Version? currentVersion;
  final Version? latestVersion;
  final bool enabled;
  final IconData disabledIcon;

  @override
  Widget build(BuildContext context) {
    Widget title = Text('$name Version');
    Widget leading = Icon(disabledIcon);
    Widget subtitle = Text(
      enabled ? (currentVersion?.toString() ?? 'Unknown') : 'N/A',
    );
    Widget? trailing;

    if (enabled) {
      switch (availability) {
        case UpdateAvailability.unknown:
          leading = const Icon(Icons.cloud_off);

        case UpdateAvailability.checking:
          leading = const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(),
          );

        case UpdateAvailability.upToDate:
          leading = const Icon(Icons.check);
        
        case UpdateAvailability.newVersionAvailable:
          leading = const Icon(Icons.cloud_download);
          title = Text('$name Update');
          subtitle = Row(
            children: [
              Text(currentVersion!.toString()),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(Icons.arrow_right_alt_rounded),
              ),
              Text(latestVersion!.toString()),
            ],
          );
          // trailing = TextButton(
          //   onPressed: onUpdatePressed,
          //   child: const Text('Install'),
          // );
      }
    }
  
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      enabled: enabled,
    );
  }
}