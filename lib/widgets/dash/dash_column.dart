import 'package:flutter/material.dart';

class DashColumn extends StatelessWidget {
  const DashColumn({
    super.key,
    this.items = const [],
    required this.flex,
    //required this.widthFactor
  });

  final List<Widget> items;
  //final double widthFactor;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      fit: FlexFit.tight,
      child: Column(
        children: items,
      ),
    );
  }
}