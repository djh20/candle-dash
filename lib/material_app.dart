import 'package:candle_dash/settings/app_settings.dart';
import 'package:candle_dash/theme.dart';
import 'package:candle_dash/widgets/bluetooth/bluetooth_screen.dart';
import 'package:candle_dash/widgets/dash/dash_screen.dart';
import 'package:candle_dash/widgets/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({
    super.key,
    required this.suggestedThemeMode,
  });

  final ThemeMode suggestedThemeMode;

  @override
  Widget build(BuildContext context) {
    final themeSetting = context.select((AppSettings s) => s.theme);

    ThemeMode themeMode = ThemeMode.light;

    if (themeSetting == ThemeSetting.auto) {
      themeMode = suggestedThemeMode;
    } else if (themeSetting == ThemeSetting.dark) {
      themeMode = ThemeMode.dark;
    }

    final ColorScheme colorScheme = (themeMode == ThemeMode.light ? lightColorScheme : darkColorScheme);

    return MaterialApp(
      title: 'Candle Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        textTheme: const TextTheme(
          displaySmall: TextStyle(fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontWeight: FontWeight.bold),
          displayLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/bluetooth': (context) => const BluetoothScreen(),
        '/dash': (context) => const DashScreen(),
      },
    );
  }
}