import 'package:flutter/material.dart';
import 'screens/quran_search_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Amiri',
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
      ),
      home: QuranSearchScreen(),
    );
  }
}