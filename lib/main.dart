import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const MusikkuApp());

class MusikkuApp extends StatelessWidget {
  const MusikkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Musikku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: scheme,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: scheme.onSurface,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
