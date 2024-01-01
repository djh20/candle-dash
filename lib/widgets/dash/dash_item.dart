import 'package:flutter/material.dart';

class DashItem extends StatelessWidget {
  const DashItem({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 10, right: 10),
      child: child,
    );
  }
}