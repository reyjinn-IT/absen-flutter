import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:async';

import 'package:abseen_kuliah/theme/app_theme.dart';
import 'package:abseen_kuliah/utils/permission_utils.dart';
import 'package:abseen_kuliah/services/api_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isLoading = false;
  bool _isScanned = false;

  void _onBarcodeDetected(BarcodeCapture barcodes) {
    if (_isScanned || _isLoading) return;

    final barcode = barcodes.barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() {
      _isScanned = true;
      _isLoading = true;
    });

    // Process QR Data
    _processQRData(barcode.rawValue!);
  }

  Future<void> _processQRData(String qrData) async {
  try {
    // Parse QR data
    final data = json.decode(qrData);
    final kelasId = data['kelas_id'] as String; // ✅ TAMBAH 'as String'
    final dosenId = data['dosen_id'] as String; // ✅ TAMBAH 'as String'
    final timestamp = data['timestamp'] as String;

    // Validate expiration
    final qrTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(qrTime).inSeconds;

    if (difference > 900) { // 15 minutes
      _showErrorDialog('QR Code sudah kadaluarsa');
      return;
    }

    // Simulate API call for attendance
    await Future.delayed(const Duration(seconds: 1));
    
    // Call API to submit attendance - ✅ GUNAKAN VARIABEL
    await _submitAttendance(kelasId, dosenId);

  } catch (e) {
    _showErrorDialog('QR Code tidak valid atau sudah digunakan');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

Future<void> _submitAttendance(String kelasId, String dosenId) async {
  try {
    final response = await ApiService.post('mahasiswa/absen/masuk', {
      'kelas_id': kelasId, // ✅ GUNAKAN kelasId
      'dosen_id': dosenId, // ✅ GUNAKAN dosenId (jika diperlukan)
      'latitude': '-6.200000',
      'longitude': '106.816666',
    });

    if (response['success']) {
      _showSuccessDialog(kelasId);
    } else {
      _showErrorDialog(response['message'] ?? 'Gagal melakukan absensi');
    }
  } catch (e) {
    _showErrorDialog('Terjadi kesalahan: $e');
  }
}

  void _showSuccessDialog(String kelasId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppTheme.successColor,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Absensi Berhasil!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Anda berhasil melakukan absensi untuk kelas $kelasId',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Kembali ke Dashboard',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Icon(
              Icons.error_rounded,
              color: AppTheme.errorColor,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Absensi',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanned = false;
              });
            },
            child: Text(
              'Coba Lagi',
              style: GoogleFonts.poppins(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            controller: cameraController,
            onDetect: _onBarcodeDetected,
          ),

          // Scanner Overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                const Expanded(flex: 2, child: SizedBox()),
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 60),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomPaint(
                      foregroundPainter: ScannerOverlayPainter(),
                    ),
                  ),
                ),
                const Expanded(flex: 2, child: SizedBox()),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Memproses absensi...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Arahkan kamera ke QR Code yang ditampilkan dosen',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(20, 0)
      ..lineTo(0, 0)
      ..lineTo(0, 20)
      ..moveTo(0, size.height - 20)
      ..lineTo(0, size.height)
      ..lineTo(20, size.height)
      ..moveTo(size.width - 20, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - 20)
      ..moveTo(size.width, 20)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - 20, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}