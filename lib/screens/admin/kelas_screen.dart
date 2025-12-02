import 'package:flutter/material.dart';

class KelasScreen extends StatelessWidget {
  const KelasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Kelas')),
      body: const Center(child: Text('Kelas Screen')),
    );
  }
}