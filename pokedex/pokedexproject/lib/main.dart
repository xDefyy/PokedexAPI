import 'package:flutter/material.dart';
import 'package:pokedexproject/screens/pokewidget.dart';
import 'package:pokedexproject/services/notification_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotiService().init();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color.fromARGB(255, 255, 255, 255),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
        ),
        scrollbarTheme: const ScrollbarThemeData(
          thickness: WidgetStatePropertyAll(6.0),
          thumbColor: WidgetStatePropertyAll(Colors.grey),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromARGB(255, 0, 0, 0),
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
        ),
        scrollbarTheme: const ScrollbarThemeData(
          thickness: WidgetStatePropertyAll(6.0),
          thumbColor: WidgetStatePropertyAll(Colors.grey),
        ),
      ),
      home: PokeWidget(onThemeToggle: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}
