import 'dart:typed_data';

import 'package:flutter/material.dart';

num calculateMedian(List<num> values) {
  // Clone list
  final List<num> clonedList = [];
  clonedList.addAll(values);

  // Sort list
  clonedList.sort((a, b) => a.compareTo(b));

  num median;

  int middle = clonedList.length ~/ 2;
  if (clonedList.length % 2 == 1) {
    median = clonedList[middle];
  } else {
    median = ((clonedList[middle - 1] + clonedList[middle]) / 2.0);
  }

  return median;
}

int? intListToInt32(List<int> list, {Endian endian = Endian.little}) {
  if (list.isEmpty) return null;
  final intList = Int8List.fromList(list);
  return intList.buffer.asByteData().getInt32(0, endian);
}

int? intListToInt16(List<int> list, {Endian endian = Endian.little}) {
  if (list.isEmpty) return null;
  final intList = Int8List.fromList(list);
  return intList.buffer.asByteData().getInt16(0, endian);
}

List<int> int32ToIntList(int? int32) {
  if (int32 == null) return const [];
  ByteData byteData = ByteData(4);
  byteData.setInt32(0, int32, Endian.little);
  return byteData.buffer.asUint8List().toList();
}

Color lerpColor(double progress, {
  required Color from,
  required Color to,
}) {
  final HSVColor hsvColor = HSVColor.lerp(
    HSVColor.fromColor(from), 
    HSVColor.fromColor(to), 
    progress,
  ) ?? HSVColor.fromColor(from);

  return hsvColor.toColor();
}