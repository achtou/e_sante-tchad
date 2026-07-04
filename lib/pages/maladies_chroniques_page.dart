import 'package:flutter/material.dart';

class MaladiesChroniquesPage extends StatelessWidget {
  const MaladiesChroniquesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des Maladies Chroniques'),
        backgroundColor: const Color(0xFF00A86B),
      ),
      body: const Center(
        child: Text(
          'Suivi des Maladies Chroniques - Page en construction',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
