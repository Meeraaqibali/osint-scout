import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkTheme') ?? true;
  runApp(OsintScoutApp(isDark: isDark));
}

class OsintScoutApp extends StatefulWidget {
  final bool isDark;
  const OsintScoutApp({super.key, required this.isDark});

  @override
  State<OsintScoutApp> createState() => _OsintScoutAppState();
}

class _OsintScoutAppState extends State<OsintScoutApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  void toggleTheme(bool value) async {
    setState(() => _isDark = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OSINT Scout',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(isDark: _isDark),
      home: HomeScreen(isDark: _isDark, onThemeChanged: toggleTheme),
    );
  }
}
