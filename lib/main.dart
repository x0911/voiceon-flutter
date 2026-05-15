import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: VoiceonApp()));
}

class VoiceonApp extends StatelessWidget {
  const VoiceonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voiceon',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text(
            'Voiceon placeholder home',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
