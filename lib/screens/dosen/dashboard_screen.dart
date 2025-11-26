import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'dart:convert'; 
import 'dart:async'; 
import 'package:abseen_kuliah/widgets/stat_card.dart';
import 'package:abseen_kuliah/widgets/kelas_card.dart';

import 'package:abseen_kuliah/theme/app_theme.dart';
class DosenDashboardScreen extends StatelessWidget {
  const DosenDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Dosen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              // Logout logic
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang,',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Dr. Najwa, M.Kom',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '87654321 - Dosen',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats Section
            Text(
              'Ringkasan Mengajar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              children: [
                StatCard(
                  title: 'Total Kelas',
                  value: '8',
                  icon: Icons.class_rounded,
                  color: AppTheme.primaryColor,
                ),
                StatCard(
                  title: 'Mata Kuliah',
                  value: '4',
                  icon: Icons.menu_book_rounded,
                  color: AppTheme.successColor,
                ),
                StatCard(
                  title: 'Mahasiswa',
                  value: '120',
                  icon: Icons.people_rounded,
                  color: AppTheme.accentColor,
                ),
                StatCard(
                  title: 'Pertemuan',
                  value: '32',
                  icon: Icons.event_rounded,
                  color: AppTheme.warningColor,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Kelas Hari Ini
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kelas Hari Ini',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                KelasCard(
                  kode: 'MK001-A',
                  nama: 'Pemrograman Web',
                  waktu: '08:00 - 10:00',
                  ruang: 'Lab. Komputer A',
                  mahasiswa: '30 Mahasiswa',
                ),
                KelasCard(
                  kode: 'MK003-B',
                  nama: 'Algoritma Lanjut',
                  waktu: '13:00 - 15:00',
                  ruang: 'R. 302',
                  mahasiswa: '25 Mahasiswa',
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/dosen/generate-qr');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
      ),
    );
  }
}