import 'package:flutter/material.dart';
import 'package:quiz_app/pages/home_page.dart';
import 'package:quiz_app/pages/start_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Colors
              .black, // Mengatur semua CircularProgressIndicator menjadi putih
        ),
      ),
      home: HomePage(),
    );
  }
}
