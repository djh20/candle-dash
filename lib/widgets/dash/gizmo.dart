import 'package:flutter/material.dart';

abstract class Gizmo extends StatelessWidget {
  const Gizmo({
    super.key,
    required this.name, 
    this.description,
    required this.height,
    this.padding = const EdgeInsets.only(top: 8, left: 10, right: 10),
  });

  final String name;
  final String? description;
  final double height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: height,
        child: buildContent(context),
      ),
    );
  }

  Widget get incompatible {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        border: Border.all(
          color: Colors.red,
        ),
      ),
      child: (height >= 30) ? 
        const Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 24,
          ),
        )
        : null,
    );
  }

  Widget get spinner {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  Widget buildContent(BuildContext context);
}