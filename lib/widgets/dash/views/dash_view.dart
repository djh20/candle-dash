import 'package:flutter/material.dart';

class DashView extends StatelessWidget {
  const DashView({
    super.key,
    this.children = const [],
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children,
    );
  }
}