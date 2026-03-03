import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'nav/navigation.dart'; позже верну
import 'screens/login_screen.dart';

class App extends StatefulWidget {
  final bool isLoggedIn;
  const App({super.key, required this.isLoggedIn});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final ThemeMode _themeMode = ThemeMode.system;

  // void _toggleTheme(bool isDark) {
  //   setState(() {
  //     _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    const seedColor = Colors.blueAccent;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final bool isCurrentlyDark = _themeMode == ThemeMode.system
            ? MediaQuery.of(context).platformBrightness == Brightness.dark
            : _themeMode == ThemeMode.dark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarContrastEnforced: false,
            systemNavigationBarIconBrightness: isCurrentlyDark ? Brightness.light : Brightness.dark,
            statusBarIconBrightness: isCurrentlyDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isCurrentlyDark ? Brightness.dark : Brightness.light,
          ),
          child: child!,
        );
      },
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),  // верну как было как тоько авторизация станет идеальна
      // home: widget.isLoggedIn
      //     ? MyHomePage(onThemeChanged: _toggleTheme)
      //     : const LoginScreen(),
      // routes: {
      //   '/home': (context) => MyHomePage(onThemeChanged: _toggleTheme),
      // },
    );
  }
}