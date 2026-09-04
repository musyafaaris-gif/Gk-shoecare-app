import 'package:flutter/material.dart';

void main() {
  runApp(const GKShoecareApp());
}

class GKShoecareApp extends StatelessWidget {
  const GKShoecareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GK Shoecare',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('GK. SHOECARE'),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'Selamat datang di GK Shoecare!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
