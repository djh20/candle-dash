import 'package:candle_dash/settings/app_settings.dart';
import 'package:candle_dash/theme.dart';
import 'package:candle_dash/widgets/pages/app_settings_page.dart';
import 'package:candle_dash/widgets/pages/bluetooth_page.dart';
import 'package:candle_dash/widgets/pages/dash_page.dart';
import 'package:candle_dash/widgets/pages/home_page.dart';
import 'package:candle_dash/widgets/pages/terminal_page.dart';
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
        '/': (context) => const HomePage(),
        '/bluetooth': (context) => const BluetoothPage(),
        '/dash': (context) => const DashPage(),
        '/app_settings': (context) => const AppSettingsPage(),
        '/terminal': (context) => const TerminalPage(),
        '/device_settings': (context) => const SizedBox(),
      },
    );
  }
}