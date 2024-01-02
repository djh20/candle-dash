import 'package:flutter/material.dart';

class StatusIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final bool visible;
  final String? text;
  final double size;

  const StatusIcon({ 
    super.key,
    required this.icon,
    this.color,
    this.visible = true,
    this.text,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      opacity: visible ? 1 : 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size+2),
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
          heightFactor: visible ? 1 : 0,
          child: Icon(
            icon,
            size: size,
            color: color,
          ),
        ),
      ),
    );
  }
}