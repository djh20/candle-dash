import 'package:candle_dash/managers/dash_manager.dart';
import 'package:candle_dash/widgets/dash/horizontal_line.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditingActionsSheet extends StatelessWidget {
  const EditingActionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final stopEditing = context.select((DashManager dm) => dm.stopEditing);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Mode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              HorizontalLine(),
              Text('Using fake data'),
            ],
          ),
          Wrap(
            spacing: 5,
            children: [
              FilledButton.tonalIcon(
                label: const Text('Save'),
                icon: const Icon(Icons.save),
                onPressed: null,
              ),
              FilledButton.tonalIcon(
                label: const Text('Cancel'),
                icon: const Icon(Icons.close),
                onPressed: stopEditing,
              ),
            ],
          ),
        ],
      ),
    );
  }
}