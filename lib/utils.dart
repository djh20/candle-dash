import 'dart:typed_data';

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
