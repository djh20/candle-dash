import 'package:candle_dash/widgets/helpers/custom_animated_switcher.dart';
import 'package:flutter/material.dart';

class DashColumn extends StatefulWidget {
  const DashColumn({
    super.key,
    this.items = const [],
    required this.flex,
    this.padding = EdgeInsets.zero,
    this.alignment = MainAxisAlignment.start,
    this.panel = false,
  });

  final List<Widget> items;
  final int flex;
  final EdgeInsets padding;
  final MainAxisAlignment alignment;
  final bool panel;

  @override
  State<DashColumn> createState() => _DashColumnState();
}

class _DashColumnState extends State<DashColumn> {
  int currentWidgetIndex = 0;

  void nextWidget() {
    int newIndex = currentWidgetIndex + 1;
    if (newIndex >= widget.items.length) newIndex = 0;

    setState(() => currentWidgetIndex = newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: widget.flex,
      fit: FlexFit.tight,
      child: Padding(
        padding: widget.padding,
        child: widget.panel ? 
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => nextWidget(),
            child: CustomAnimatedSwitcher(
              child: widget.items[currentWidgetIndex],
            ),
          ) :
          Column(
            mainAxisAlignment: widget.alignment,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.items,
          ),
      ),
    );
  }
}