import 'package:flutter/material.dart';

class CustomVerticalDivider extends StatelessWidget {
  const CustomVerticalDivider({
    super.key,
    this.width = 0,
    this.indent = 0,
    this.endIndent = 0,
  });

  final double width;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: width,
      indent: indent,
      endIndent: endIndent,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
    );
  }
}