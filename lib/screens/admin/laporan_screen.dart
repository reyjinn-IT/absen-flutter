import 'package:flutter/material.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: const Center(child: Text('Laporan Screen')),
    );
  }
}