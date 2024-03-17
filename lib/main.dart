import 'package:flutter/material.dart';
import 'package:yt_downloader/home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red, brightness: Brightness.dark),
        ),
        home: const HomeScreen());
  }
}
