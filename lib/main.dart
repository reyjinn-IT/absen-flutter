import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // TAMBAH INI
import 'dart:convert'; // TAMBAH INI

import 'package:abseen_kuliah/providers/auth_provider.dart';
import 'package:abseen_kuliah/screens/auth/login_screen.dart';
import 'package:abseen_kuliah/screens/mahasiswa/main_screen.dart';
import 'package:abseen_kuliah/screens/mahasiswa/qr_scanner_screen.dart';
import 'package:abseen_kuliah/screens/dosen/dashboard_screen.dart';
import 'package:abseen_kuliah/screens/dosen/qr_generator_screen.dart';
import 'package:abseen_kuliah/screens/admin/dashboard_screen.dart';
import 'package:abseen_kuliah/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Abseen Kuliah',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/mahasiswa': (context) => const MahasiswaMainScreen(),
          '/dosen': (context) => const DosenDashboardScreen(),
          '/admin': (context) => const AdminDashboardScreen(),
          '/mahasiswa/scan-qr': (context) => const QRScannerScreen(),
          '/dosen/generate-qr': (context) => const QRGeneratorScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.checkAuthStatus();
    
    if (isLoggedIn && mounted) {
      final user = authProvider.user;
      if (user!.isMahasiswa) {
        Navigator.pushReplacementNamed(context, '/mahasiswa');
      } else if (user.isDosen) {
        Navigator.pushReplacementNamed(context, '/dosen');
      } else {
        Navigator.pushReplacementNamed(context, '/admin');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 20),
            Text(
              'Abseen Kuliah',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sistem Absensi Digital',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}