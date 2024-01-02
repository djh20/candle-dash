import 'package:candle_dash/vehicle/metric.dart';
import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:flutter/material.dart';

class TurnSignalsDashItem extends StatefulWidget {
  const TurnSignalsDashItem({super.key});

  @override
  State<TurnSignalsDashItem> createState() => _TurnSignalsDashItemState();
}

class _TurnSignalsDashItemState extends State<TurnSignalsDashItem> with TickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    upperBound: 1,
    lowerBound: 0,
    vsync: this,
  )..repeat(reverse: true);

  late final curveAnim = CurvedAnimation(
    parent: controller,
    curve: Curves.easeInOutSine,
  );

  late final leftAnim = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.25, 0.0),
  ).animate(curveAnim);

  late final rightAnim = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-0.25, 0.0),
  ).animate(curveAnim);
  
  @override
  Widget build(BuildContext context) {
    final turnSignal = Metric.watch<MetricInt>(context, StandardMetric.turnSignal.id)?.value;

    final bool leftTurnSignal = (turnSignal == 1 || turnSignal == 3);
    final bool rightTurnSignal = (turnSignal == 2 || turnSignal == 3);

    return DashItem(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TurnSignalIcon(
            animation: leftAnim,
            icon: Icons.arrow_circle_left,
            visible: leftTurnSignal,
          ),
          TurnSignalIcon(
            animation: rightAnim,
            icon: Icons.arrow_circle_right,
            visible: rightTurnSignal,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class TurnSignalIcon extends StatelessWidget {
  const TurnSignalIcon({
    super.key,
    //required this.controller,
    required this.animation,
    required this.icon,
    this.visible = true,
  });

  //final AnimationController controller;
  final Animation<Offset> animation;
  final IconData icon;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: SlideTransition(//FadeTransition(
        //opacity: controller,
        position: animation,
        child: Icon(
          icon,
          color: Colors.green,
          size: 32,
        ),
      ),
    );
  }
}
