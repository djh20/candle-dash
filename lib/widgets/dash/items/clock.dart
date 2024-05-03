import 'package:candle_dash/widgets/dash/gizmo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockGizmo extends Gizmo {
  const ClockGizmo({super.key}) : super(
    name: 'Clock',
    height: 35,
  );

  @override
  Widget buildContent(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Row(
          children: [
            const Icon(
              Icons.access_time,
              size: 25,
            ),
            const SizedBox(width: 5),
            Text(
              DateFormat.jm().format(DateTime.now()),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}