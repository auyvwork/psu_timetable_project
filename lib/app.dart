import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nav/home_page.dart';
import 'screens/login_screen.dart';

class App extends StatefulWidget {
  const App({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const List<LocalizationsDelegate<dynamic>> _localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> _supportedLocales = <Locale>[
    Locale('ru', ''),
  ];

  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4264EB),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF9F9F9),
  );

  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4264EB),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
  );

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  late bool _isLoggedIn;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      _isLoggedIn = false;
    });

    App.navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _handleLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: App.navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      localizationsDelegates: App._localizationsDelegates,
      supportedLocales: App._supportedLocales,
      theme: App._lightTheme,
      darkTheme: App._darkTheme,
      initialRoute: _isLoggedIn ? '/home' : '/login',
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) =>
            LoginScreen(onLoginSuccess: _handleLoginSuccess),
        '/home': (BuildContext context) => HomePage(
              onThemeChanged: _toggleTheme,
              onLogout: _logout,
            ),
      },
    );
  }
}