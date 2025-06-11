import 'package:flutter/material.dart';

void main() {
  runApp(const ActionCamApp());
}

class ActionCamApp extends StatelessWidget {
  const ActionCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4K Action Cam',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
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
      appBar: AppBar(
        title: const Text('4K Action Cam'),
      ),
      body: const Center(
        child: Text('Bienvenido. App base creada.'),
      ),
    );
  }
}
