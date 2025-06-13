import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';

void main() {
  runApp(const HabitatApp());
}

class HabitatApp extends StatefulWidget {
  const HabitatApp({super.key});

  @override
  State<HabitatApp> createState() => _HabitatAppState();
}

class _HabitatAppState extends State<HabitatApp> {
  final ThemeService _themeService = ThemeService();
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeMode = await _themeService.getThemeMode();
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habitat',
      themeMode: _themeMode,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark().copyWith(
          surface: const Color(0xFF1E1E1E),
        ),
      ),
      home: HomeScreen(
        onThemeChanged: () {
          _loadTheme();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
