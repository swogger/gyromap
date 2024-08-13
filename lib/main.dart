import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gyromap',
      theme: ThemeData.light(), // Define the light theme
      darkTheme: ThemeData.dark(), // Define the dark theme
      themeMode: ThemeMode.dark, // Force dark mode
      home: MapScreen(),
    );
  }
}
