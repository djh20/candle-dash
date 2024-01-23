import 'package:flutter/material.dart';

class StatusIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final bool active;
  final String? text;
  final double size;

  const StatusIcon({ 
    super.key,
    required this.icon,
    this.color,
    this.active = true,
    this.text,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.1,
          child: Icon(
            icon,
            size: size,
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
          opacity: active ? 1 : 0,
          child: Icon(
            icon,
            size: size,
            color: color,
          ),
        ),
      ],
    );
  }
}