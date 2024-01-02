import 'package:flutter/material.dart';

class DashColumn extends StatelessWidget {
  const DashColumn({
    super.key,
    this.items = const [],
    required this.flex,
    this.padding = EdgeInsets.zero,
  });

  final List<Widget> items;
  final int flex;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      fit: FlexFit.tight,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items,
        ),
      ),
    );
  }
}