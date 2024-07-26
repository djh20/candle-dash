import 'package:candle_dash/bluetooth/bluetooth_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<TerminalPage> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = context.read<BluetoothManager>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter command',
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: () {
              _focusNode.unfocus();
              bluetoothManager.runCommand(_textController.text);
            },
            label: const Text('Run'),
          ),
        ],
      )
    );
  }
}