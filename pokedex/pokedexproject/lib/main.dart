import 'package:flutter/material.dart';
import 'package:pokedexproject/screens/pokewidget.dart';
import 'package:pokedexproject/services/notification_services.dart';
import 'package:google_fonts/google_fonts.dart';

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
        textTheme: GoogleFonts.notoSansJpTextTheme(
          ThemeData.light().textTheme.copyWith(
                displayLarge: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.notoSansJp().fontFamily,
                  fontSize: 24,
                  letterSpacing: 1.2,
                ),
                displayMedium: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.notoSansJp().fontFamily,
                  fontSize: 20,
                ),
                bodyLarge: TextStyle(
                  fontFamily: GoogleFonts.notoSansJp().fontFamily,
                  fontSize: 16,
                ),
                bodyMedium: TextStyle(
                  fontFamily: GoogleFonts.notoSansJp().fontFamily,
                  fontSize: 14,
                ),
              ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.black),
          actionsIconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            fontFamily: 'Pokemon',
            fontSize: 24,
            color: Colors.black,
          ),
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
        textTheme: GoogleFonts.notoSansJpTextTheme(
          ThemeData.dark().textTheme.copyWith(
                displayLarge: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.notoSansJp().fontFamily,
                  fontSize: 24,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
                displayMedium: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.notoSansJp().fontFamily,
                  fontSize: 20,
                  color: Colors.white,
                ),
                bodyLarge: TextStyle(
                  fontFamily: GoogleFonts.notoSansJp().fontFamily,
                  fontSize: 16,
                  color: Colors.white,
                ),
                bodyMedium: TextStyle(
                  fontFamily: GoogleFonts.notoSansJp().fontFamily,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontFamily: 'Pokemon',
            fontSize: 24,
            color: Colors.white,
          ),
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
