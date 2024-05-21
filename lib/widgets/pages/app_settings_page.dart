import 'package:candle_dash/settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<AppSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: ListView(
        // padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 80),
        padding: const EdgeInsets.all(5.0),
        children: [
          ListTile(
            leading: const Icon(Icons.contrast),
            title: const Text('Theme'),
            subtitle: SegmentedButton<ThemeSetting>(
              segments: ThemeSetting.values.map(
                (option) => ButtonSegment(
                  label: Text(option.name),
                  value: option,
                ),
              ).toList(),
              selected: {settings.theme!},
              onSelectionChanged: (selection) => settings.update((s) => s.theme = selection.first),
            ),
          ),

          const Divider(),

          const ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Auto Dashboard'),
            // subtitle: const Text('Opens the dashboard when the app is launched.'),
            subtitle: Text('Coming soon...'),
            trailing: Switch(
              value: false,
              onChanged: null,
            ),
            enabled: false,
          ),

          const ListTile(
            leading: Icon(Icons.science),
            title: Text('Experimental Mode'),
            // subtitle: const Text('Allows installation of beta releases.'),
            subtitle: Text('Coming soon...'),
            trailing: Switch(
              value: false,
              onChanged: null,
            ),
            enabled: false,
          ),
        ],
      ),
    );
  }
}


class _SettingHeader extends StatelessWidget {
  const _SettingHeader({
    // ignore: unused_element
    super.key,
    required this.title,
    required this.icon
  });

  final String title;
  final IconData icon;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 5),
        Text(
          title,
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}