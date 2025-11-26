import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // TAMBAH INI

import 'package:abseen_kuliah/providers/auth_provider.dart';
import 'package:abseen_kuliah/theme/app_theme.dart';
import 'package:abseen_kuliah/widgets/stat_card.dart';
import 'package:abseen_kuliah/widgets/kelas_card.dart';
import 'package:abseen_kuliah/utils/permission_utils.dart';

class MahasiswaDashboardScreen extends StatelessWidget {
  const MahasiswaDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
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
                    user?.name ?? 'Mahasiswa',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${user?.nim ?? ''} - Mahasiswa',
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
              'Ringkasan',
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
                  value: '5',
                  icon: Icons.class_rounded,
                  color: AppTheme.primaryColor,
                ),
                StatCard(
                  title: 'Hadir',
                  value: '45',
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.successColor,
                ),
                StatCard(
                  title: 'Izin',
                  value: '2',
                  icon: Icons.pending_rounded,
                  color: AppTheme.warningColor,
                ),
                StatCard(
                  title: 'Alpha',
                  value: '1',
                  icon: Icons.cancel_rounded,
                  color: AppTheme.errorColor,
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
                  kode: 'MK001',
                  nama: 'Pemrograman Web',
                  waktu: '08:00 - 10:00',
                  ruang: 'Lab. Komputer A',
                  dosen: 'Dr. Najwa, M.Kom',
                ),
                KelasCard(
                  kode: 'MK002',
                  nama: 'Basis Data',
                  waktu: '13:00 - 15:00',
                  ruang: 'R. 301',
                  dosen: 'Prof. Ahmad, M.T',
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final hasPermission = await PermissionUtils.checkCameraPermission();
          if (hasPermission) {
            Navigator.pushNamed(context, '/mahasiswa/scan-qr');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Izin kamera diperlukan untuk scan QR'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
      ),
    );
  }
}