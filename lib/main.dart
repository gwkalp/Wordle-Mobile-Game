import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Sadece splash ekranını çağırıyoruz

void main() {
  runApp(const WordCrushApp());
}

class WordCrushApp extends StatelessWidget {
  const WordCrushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Word Crush',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(), // Uygulama Splash ekranından başlar
    );
  }
}
