import 'package:flutter/material.dart';

class DashColumn extends StatelessWidget {
  const DashColumn({
    super.key,
    this.items = const [],
    this.overlay,
    required this.flex,
    this.alignment = MainAxisAlignment.start,
    this.swipeable = false,
  });

  final List<Widget> items;
  final Widget? overlay;
  final int flex;
  final MainAxisAlignment alignment;
  final bool swipeable;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      fit: FlexFit.tight,
      child: Stack(
        children: [
          swipeable ? 
            ScrollConfiguration(
              behavior: const ScrollBehavior(), // Disable scroll effect
              child: PageView(
                scrollDirection: Axis.vertical,
                children: items.map((i) => Align(alignment: Alignment.topCenter, child: i)).toList(),
              ),
            ) :
            Column(
              mainAxisAlignment: alignment,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: items,
            ),
          if (overlay != null) overlay!,
        ],
      ),
    );
  }
}