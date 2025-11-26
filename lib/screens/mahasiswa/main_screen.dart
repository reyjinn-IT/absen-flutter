import 'package:flutter/material.dart';
import 'package:abseen_kuliah/screens/mahasiswa/dashboard_screen.dart';
import 'package:abseen_kuliah/screens/mahasiswa/absensi_screen.dart';
import 'package:abseen_kuliah/screens/mahasiswa/profile_screen.dart';
import 'package:abseen_kuliah/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class MahasiswaMainScreen extends StatefulWidget {
  const MahasiswaMainScreen({Key? key}) : super(key: key);

  @override
  State<MahasiswaMainScreen> createState() => _MahasiswaMainScreenState();
}

class _MahasiswaMainScreenState extends State<MahasiswaMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MahasiswaDashboardScreen(),
    const AbsensiHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}