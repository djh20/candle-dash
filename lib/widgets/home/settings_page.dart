import 'package:candle_dash/settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    if (!settings.loaded) {
      return const Center(
        child: Text('Loading...'),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 80),
      children: [
        Card(
          child: ListTile(
            title: const Text('Theme'),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: ThemeSetting.values.map(
                (option) => OptionButton(
                  label: Text(option.name), 
                  selected: settings.theme == option,
                  onPressed: () => settings.theme = option,
                ),
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class OptionButton extends StatelessWidget {
  const OptionButton({
    super.key,
    required this.label,
    required this.selected,
    this.onPressed,
  });
  
  final Widget label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: selected ? 
        FilledButton(onPressed: onPressed, child: label) :
        OutlinedButton(onPressed: onPressed, child: label),
    );
  }
}
