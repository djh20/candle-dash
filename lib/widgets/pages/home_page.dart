import 'package:candle_dash/settings/app_settings.dart';
import 'package:candle_dash/update_manager.dart';
import 'package:candle_dash/widgets/bluetooth/device_selector_sheet.dart';
import 'package:candle_dash/widgets/home/connection_status_tile.dart';
import 'package:candle_dash/widgets/home/update_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:version/version.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final updateManager = context.watch<UpdateManager>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: settings.selectedDevice != null ? 
          Text(settings.selectedDevice!.name) :
          const Text(
            'No Scanner Selected',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.bluetooth),
                onPressed: () => showDeviceSelectorSheet(context),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        children: [
          const ConnectionStatusTile(),
          const Divider(),

          UpdateTile(
            name: 'App',
            availability: updateManager.appUpdateAvailability,
            currentVersion: updateManager.currentAppVersion,
            latestVersion: updateManager.latestAppVersion,
            onUpdatePressed: () {},
          ),

          // UpdateTile(
          //   name: 'Firmware',
          //   availability: UpdateAvailability.unknown,
          //   // currentVersion: Version.parse('0.0.1-b4'),
          //   // latestVersion: Version.parse('0.0.2'),
          //   onUpdatePressed: () {},
          //   enabled: false,
          // ),

          FilledButton.tonalIcon(
            icon: const Icon(Icons.update), 
            label: const Text('Check for Updates'),
            onPressed:
              !updateManager.isCheckingForUpdates ? 
              () => updateManager.checkForUpdates() : null,
          ),

          const Divider(),

          ListTile(
            title: const Text('Dashboard'),
            leading: const Icon(Icons.dashboard),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, '/dash'),
          ),
          ListTile(
            title: const Text('App Settings'),
            leading: const Icon(Icons.phone_android),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, '/app_settings'),
          ),
          ListTile(
            title: const Text('Scanner Settings'),
            leading: const Icon(Icons.memory),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
            enabled: false,
          ),
        ],
      ),
    );
  }
}