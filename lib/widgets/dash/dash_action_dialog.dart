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
          IconButton.filledTonal(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), 
            icon: const Icon(Icons.home),
          ),
          IconButton.filledTonal(
            onPressed: () {
              toggleEditing();
              pop(context);
            },
            icon: Icon(editing ? Icons.edit_off : Icons.edit),
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