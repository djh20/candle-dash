import 'package:candle_dash/settings/app_settings.dart';
import 'package:candle_dash/widgets/bluetooth/device_selector_sheet.dart';
import 'package:candle_dash/widgets/home/connection_status_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

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

          // const ListTile(
          //   leading: Icon(Icons.done),
          //   title: Text('App Version'),
          //   subtitle: Text('1.8.2+4'),
          //   trailing: TextButton(
          //     onPressed: null,
          //     child: Text('Up to Date'),
          //   ),
          // ),

          const ListTile(
            leading: Icon(Icons.cloud_off),
            title: Text('App Version'),
            subtitle: Text('1.8.2+4'),
          ),

          const ListTile(
            leading: Icon(Icons.bluetooth_disabled),
            title: Text('Firmware Version'),
            subtitle: Text('N/A'),
            enabled: false,
          ),

          FilledButton.tonalIcon(
            icon: const Icon(Icons.update), 
            label: const Text('Check for Updates'),
            onPressed: () {},
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
      )
    );
  }
}