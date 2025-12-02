import 'package:flutter/material.dart';

class MatakuliahScreen extends StatelessWidget {
  const MatakuliahScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Mata Kuliah')),
      body: const Center(child: Text('Mata Kuliah Screen')),
    );
  }
}