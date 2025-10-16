import 'package:citizenship_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Einbürgerungstest App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.redAccent,
        ),
        textTheme: GoogleFonts.latoTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
  home: const WelcomeScreen(), // Navigation handled in WelcomeScreen
    );
  }
}
