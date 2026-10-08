import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const MusikkuApp());

class MusikkuApp extends StatelessWidget {
  const MusikkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'musikku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
