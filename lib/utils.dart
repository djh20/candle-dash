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

String intListToString(List<int> list) {
  // Only process up to null character.
  if (list.contains(0)) {
    return String.fromCharCodes(list, 0, list.indexOf(0));
  }

  return String.fromCharCodes(list);
}

int intListToInt32(List<int> list, {Endian endian = Endian.big}) {
  final intList = Int8List.fromList(list);
  return intList.buffer.asByteData().getInt32(0, endian);
}

int intListToInt16(List<int> list, {Endian endian = Endian.big}) {
  final intList = Int8List.fromList(list);
  return intList.buffer.asByteData().getInt16(0, endian);
}

int intListToUint16(List<int> list, {Endian endian = Endian.big}) {
  final intList = Uint8List.fromList(list);
  return intList.buffer.asByteData().getUint16(0, endian);
}

List<int> int32ToIntList(int? int32, {Endian endian = Endian.big}) {
  if (int32 == null) return const [];
  ByteData byteData = ByteData(4);
  byteData.setInt32(0, int32, endian);
  return byteData.buffer.asUint8List().toList();
}

List<int> uint32ToIntList(int? uint32, {Endian endian = Endian.big}) {
  if (uint32 == null) return const [];
  ByteData byteData = ByteData(4);
  byteData.setUint32(0, uint32, endian);
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