import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Putar di latar belakang cuma ada di HP (Android/iOS), di Windows dilewati
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.musikku.app.channel.audio',
      androidNotificationChannelName: 'Pemutar Musikku',
      androidNotificationOngoing: true,
    );
  }

  runApp(const MusikkuApp());
}

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
