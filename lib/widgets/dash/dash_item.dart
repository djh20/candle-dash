import 'package:flutter/material.dart';

class DashItem extends StatelessWidget {
  static Widget get incompatible => const SizedBox.shrink();
  
  const DashItem({
    super.key, 
    this.child,
    this.padding = const EdgeInsets.only(top: 8, left: 10, right: 10),
  });

  final Widget? child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
}