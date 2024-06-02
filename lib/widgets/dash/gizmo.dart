import 'package:flutter/material.dart';

abstract class Gizmo extends StatelessWidget {
  const Gizmo({
    super.key,
    required this.name, 
    this.description,
    this.padding = const EdgeInsets.only(top: 8, left: 10, right: 10),
    this.overlay = false,
  });

  final String name;
  final String? description;
  final EdgeInsets padding;
  final bool overlay;

  @override
  Widget build(BuildContext context) {
    final content = buildContent(context);

    return Padding(
      padding: padding,
      child: overlay ?
        Card(
          margin: EdgeInsets.zero,
          child: content,
        )
        : content,
    );
  }

  Widget get incompatible {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        border: Border.all(
          color: Colors.red,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 24,
        ),
      ),
    );
  }

  Widget get spinner {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  Widget buildContent(BuildContext context);
}