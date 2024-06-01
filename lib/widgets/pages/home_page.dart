import 'package:candle_dash/ota/app_updater.dart';
import 'package:candle_dash/settings/app_settings.dart';
import 'package:candle_dash/widgets/bluetooth/device_selector_sheet.dart';
import 'package:candle_dash/widgets/home/connection_status_tile.dart';
import 'package:candle_dash/widgets/home/updater_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final appUpdater = context.watch<AppUpdater>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: settings.selectedDevice != null ? 
          Text(settings.selectedDevice!.name) :
          const Text(
            'No Device Selected',
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

          UpdaterTile(
            name: 'App',
            updater: appUpdater,
          ),

          FilledButton.tonalIcon(
            icon: const Icon(Icons.update), 
            label: const Text('Check for Updates'),
            onPressed: () => appUpdater.checkForUpdates(),
          ),

          const Divider(),

          ListTile(
            title: const Text('Dashboard'),
            leading: const Icon(Icons.dashboard),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, '/dash'),
          ),
          ListTile(
            title: const Text('Settings'), // 'App Settings'
            leading: const Icon(Icons.settings), // Icons.phone_android
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, '/app_settings'),
          ),
          // ListTile(
          //   title: const Text('Scanner Settings'),
          //   leading: const Icon(Icons.memory),
          //   trailing: const Icon(Icons.arrow_forward_ios),
          //   onTap: () {},
          //   enabled: false,
          // ),
        ],
      ),
    );
  }
}