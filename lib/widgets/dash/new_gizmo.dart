import 'package:flutter/material.dart';

abstract class NewGizmo extends StatefulWidget {
  const NewGizmo({
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
  State<NewGizmo> createState();
}

abstract class NewGizmoState extends State<NewGizmo> {
  bool isOverlayVisible = false;

  @override
  Widget build(BuildContext context) {
    final content = buildContent(context);

    return Padding(
      padding: widget.padding,
      child: widget.overlay ? 
      AnimatedOpacity(
        opacity: isOverlayVisible ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background.withOpacity(0.95),
          ),
          child: content,
        ),
      )
      : content,
    );

    // return Padding(
    //   padding: widget.padding,
    //   child: SizedBox(
    //     height: widget.overlay ? double.infinity : widget.height,
    //     width: double.infinity,
    //     child: widget.overlay ? 
    //       AnimatedOpacity(
    //         opacity: isOverlayVisible ? 1 : 0,
    //         duration: const Duration(milliseconds: 250),
    //         child: Container(
    //           decoration: BoxDecoration(
    //             color: Theme.of(context).colorScheme.background.withOpacity(0.95),
    //           ),
    //           child: content,
    //         ),
    //       )
    //       : content,
    //   ),
    // );
  }

  Widget get incompatible {
    return Expanded(
      child: Container(
        height: 50,
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
      ),
    );
  }

  Widget get spinner {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void showOverlay() => setState(() => isOverlayVisible = true);
  void hideOverlay() => setState(() => isOverlayVisible = false);

  Widget buildContent(BuildContext context);
}