import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class App extends StatefulWidget {
  final bool isLoggedIn;
  const App({super.key, required this.isLoggedIn});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

    App.navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void refreshAuthState() {
    setState(() => _isLoggedIn = true);
  }

  void _toggleTheme(bool isDark) {
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: App.navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4264EB),
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4264EB),
        brightness: Brightness.dark,
      ),
      initialRoute: _isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginScreen(onLoginSuccess: refreshAuthState),
        '/home': (context) => MyHomePage(onThemeChanged: _toggleTheme, onLogout: _logout),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final Function() onLogout;
  const MyHomePage({super.key, required this.onThemeChanged, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: onLogout
          )
        ],
      ),
      body: const Center(child: Text('Вы успешно вошли!')),
    );
  }
}