import 'package:flutter/material.dart';

class SnackBarIcon extends StatelessWidget {
  const SnackBarIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.background;
    return Icon(
      icon,
      color: color,
    );
  }
}