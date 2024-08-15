import 'package:candle_dash/widgets/dash/dash_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockDashItem extends StatelessWidget {
  const ClockDashItem({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return DashItem(
          child: Row(
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
          ),
        );
      },
    );
  }
}