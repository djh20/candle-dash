import 'package:candle_dash/managers/dash_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashColumn extends StatelessWidget {
  const DashColumn({
    super.key,
    this.items = const [],
    required this.flex,
    this.alignment = MainAxisAlignment.start,
    this.swipeable = false,
  });

  final List<Widget> items;
  final int flex;
  final MainAxisAlignment alignment;
  final bool swipeable;

  @override
  Widget build(BuildContext context) {
    final editing = context.select((DashManager dm) => dm.editing);

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
          if (editing) ...[
            IgnorePointer(
              child: Container(
                height: MediaQuery.of(context).size.height,
                margin: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.orange,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: IconButton.filledTonal(
                  icon: const Icon(Icons.edit),
                  onPressed: () => {}, 
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}