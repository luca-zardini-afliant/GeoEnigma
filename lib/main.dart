import 'package:flutter/material.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(const GlobalEnigmaApp());
}

class GlobalEnigmaApp extends StatelessWidget {
  const GlobalEnigmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Enigma',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}
