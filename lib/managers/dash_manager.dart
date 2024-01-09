import 'package:flutter/material.dart';

class DashManager with ChangeNotifier {
  bool editing = false;

  void startEditing() {
    editing = true;
    notifyListeners();
  }

  void stopEditing() {
    editing = false;
    notifyListeners();
  }

  void toggleEditing() => editing ? stopEditing() : startEditing();
}