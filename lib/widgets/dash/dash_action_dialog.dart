import 'package:candle_dash/dash/dash_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashActionDialog extends StatelessWidget {
  const DashActionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final preview = context.select((DashManager dm) => dm.preview);
    final togglePreview = context.select((DashManager dm) => dm.togglePreview);

    return AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            label: const Text('Close Dashboard'),
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), 
          ),
          FilledButton.tonalIcon(
            label: Text(!preview ? 'Enable Preview Mode' : 'Disable Preview Mode'),
            icon: Icon(!preview ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              togglePreview();
              pop(context);
            },
          ),
          TextButton(
            child: const Text('Dismiss'),
            onPressed: () => pop(context),
          ),
        ],
      ),
    );
  }

  void pop(BuildContext context) => Navigator.of(context).pop();
}