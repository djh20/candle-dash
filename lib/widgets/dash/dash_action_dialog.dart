import 'package:candle_dash/managers/dash_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashActionDialog extends StatelessWidget {
  const DashActionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final editing = context.select((DashManager dm) => dm.editing);
    final toggleEditing = context.select((DashManager dm) => dm.toggleEditing);

    return AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            label: const Text('Close Dash'),
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), 
          ),
          if (!editing) FilledButton.tonalIcon(
            label: const Text('Enable Edit Mode'),
            icon: const Icon(Icons.edit),
            onPressed: () {
              toggleEditing();
              pop(context);
            },
          ),
          if (editing) ...[
            FilledButton.tonalIcon(
              label: const Text('Save Layout'),
              icon: const Icon(Icons.save),
              onPressed: () {},
            ),
            FilledButton.tonalIcon(
              label: const Text('Change Layout'),
              icon: const Icon(Icons.layers),
              onPressed: () {},
            ),
            FilledButton.tonalIcon(
              label: const Text('Disable Edit Mode'),
              icon: const Icon(Icons.edit_off),
              onPressed: () {
                toggleEditing();
                pop(context);
              },
            ),
          ],
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