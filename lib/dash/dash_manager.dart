import 'package:flutter/material.dart';

class DashManager with ChangeNotifier {
  bool preview = false;

  void enablePreview() {
    preview = true;
    notifyListeners();
  }

  void disablePreview() {
    preview = false;
    notifyListeners();
  }

  void togglePreview() => preview ? disablePreview() : enablePreview();
}