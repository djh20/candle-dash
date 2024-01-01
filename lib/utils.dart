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
