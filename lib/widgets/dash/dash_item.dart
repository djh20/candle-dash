import 'package:flutter/material.dart';

class DashItem extends StatelessWidget {
  const DashItem({
    super.key,
    this.child,
    this.height,
  });

  final Widget? child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 10, right: 10),
        child: child,
      ),
    );
  }
}
