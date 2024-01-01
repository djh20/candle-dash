import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeSetting {
  auto('Auto'),
  light('Light'),
  dark('Dark');

  const ThemeSetting(this.name);
  final String name;
}

class AppSettings with ChangeNotifier {
  bool loaded = false;

  late SharedPreferences _prefs;

  ThemeSetting? _theme;
  ThemeSetting? get theme => _theme;
  set theme(ThemeSetting? newTheme) => _update(() => _theme = newTheme);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    _theme = ThemeSetting.values[_prefs.getInt('theme') ?? 0];
    loaded = true;
    notifyListeners();
  }

  Future<void> save() async {
    if (!loaded) return;

    _prefs.setInt('theme', _theme!.index);
  }

  void _update(VoidCallback callback) {
    callback();
    notifyListeners();
  }
}