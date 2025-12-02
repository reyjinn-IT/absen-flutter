import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:abseen_kuliah/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:abseen_kuliah/providers/auth_provider.dart';

class QRGeneratorScreen extends StatefulWidget {
  final String? kelasId;
  final String? matakuliah;

  const QRGeneratorScreen({
    Key? key,
    this.kelasId,
    this.matakuliah,
  }) : super(key: key);

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final String _duration = '15:00';
  int _remainingTime = 900; // 15 minutes in seconds
  late Timer _timer;
  late DateTime _qrGeneratedTime;
  Map<String, dynamic>? _qrDataMap;

  @override
  void initState() {
    super.initState();
    _initializeQRData();
    _startTimer();
  }

  void _initializeQRData() {
    _qrGeneratedTime = DateTime.now();
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    // Gunakan data dari provider atau parameter
    final kelasId = widget.kelasId ?? 'MK001-A';
    final matakuliah = widget.matakuliah ?? 'Pemrograman Web';
    
    _qrDataMap = {
      'kelas_id': kelasId,
      'dosen_id': user?.id?.toString() ?? 'unknown',
      'dosen_name': user?.name ?? 'Unknown Dosen',
      'matakuliah': matakuliah,
      'timestamp': _qrGeneratedTime.toIso8601String(),
      'expires_in': _remainingTime,
      'session_id': _generateSessionId(),
    };
  }

  String _generateSessionId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${widget.kelasId ?? 'default'}';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
          if (_qrDataMap != null) {
            _qrDataMap!['expires_in'] = _remainingTime;
          }
        });
      } else {
        _timer.cancel();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showTimeUpDialog();
        });
      }
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User harus klik OK
      builder: (context) => AlertDialog(
        title: const Text('Waktu QR Code Habis'),
        content: const Text('QR Code sudah tidak berlaku. Kembali ke dashboard?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _extendTime() {
    setState(() {
      _remainingTime = 900; // Reset ke 15 menit
      _qrGeneratedTime = DateTime.now();
      if (_qrDataMap != null) {
        _qrDataMap!['timestamp'] = _qrGeneratedTime.toIso8601String();
        _qrDataMap!['expires_in'] = _remainingTime;
        _qrDataMap!['session_id'] = _generateSessionId(); // Generate session baru
      }
    });
  }

  void _stopQR() {
    _timer.cancel();
    Navigator.pop(context);
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String get _qrDataString {
    return json.encode(_qrDataMap ?? {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    final kelasId = widget.kelasId ?? 'MK001-A';
    final matakuliah = widget.matakuliah ?? 'Pemrograman Web';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Class Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.class_rounded,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                matakuliah,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Kelas: $kelasId',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dosen: ${user?.name ?? 'Unknown'}',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _remainingTime > 60 
                            ? AppTheme.successColor.withOpacity(0.1)
                            : AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            color: _remainingTime > 60 
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Berlaku: ${_formatTime(_remainingTime)}',
                            style: GoogleFonts.poppins(
                              color: _remainingTime > 60 
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dibuat: ${_qrGeneratedTime.toString().substring(0, 16)}',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // QR Code
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: _qrDataString,
                    version: QrVersions.auto,
                    size: 250,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Scan QR Code untuk Absensi',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sesi ID: ${_qrDataMap?['session_id']?.toString().substring(0, 8)}...',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // QR Data Info (Optional)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data QR Code:',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dosen: ${user?.name ?? 'Unknown'}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    Text(
                      'ID Dosen: ${user?.id ?? 'unknown'}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    Text(
                      'Mata Kuliah: $matakuliah',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    Text(
                      'Kelas: $kelasId',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    Text(
                      'Waktu Generate: ${_qrGeneratedTime.toString().substring(11, 16)}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _extendTime,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: AppTheme.warningColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restart_alt_rounded,
                          color: AppTheme.warningColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Perpanjang',
                          style: GoogleFonts.poppins(
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _stopQR,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.stop_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Stop QR',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Share Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Share QR functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fitur share akan datang!'),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share_rounded,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Share QR Code',
                      style: GoogleFonts.poppins(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}