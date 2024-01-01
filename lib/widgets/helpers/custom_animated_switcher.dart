import 'package:flutter/material.dart';

class CustomAnimatedSwitcher extends StatelessWidget {
  final Widget? child;

  const CustomAnimatedSwitcher({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      reverseDuration: const Duration(milliseconds: 200),
      switchInCurve: Curves.fastOutSlowIn,
      switchOutCurve: Curves.fastOutSlowIn,
      transitionBuilder: (child, animation) => 
        FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        ),
      child: child,
    );
  }
}