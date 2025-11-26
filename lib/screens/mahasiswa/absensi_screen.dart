import 'package:flutter/material.dart';
import 'package:abseen_kuliah/theme/app_theme.dart';
import 'package:abseen_kuliah/models/absensi_model.dart';
import 'package:google_fonts/google_fonts.dart';

class AbsensiHistoryScreen extends StatelessWidget {
  const AbsensiHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data - replace with API call
    final absensiList = [
      Absensi(
        id: 1,
        tanggal: '2024-01-15',
        status: 'hadir',
        waktuMasuk: '08:05',
        kelas: 'Pemrograman Web',
      ),
      Absensi(
        id: 2,
        tanggal: '2024-01-14',
        status: 'izin',
        keterangan: 'Sakit',
        kelas: 'Basis Data',
      ),
      Absensi(
        id: 3,
        tanggal: '2024-01-13',
        status: 'hadir',
        waktuMasuk: '07:55',
        kelas: 'Algoritma',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: absensiList.length,
        itemBuilder: (context, index) {
          final absensi = absensiList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: absensi.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(absensi.status),
                      color: absensi.statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          absensi.kelas,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${absensi.tanggal} • ${absensi.waktuMasuk ?? '-'}',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (absensi.keterangan != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Keterangan: ${absensi.keterangan}',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: absensi.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      absensi.statusText,
                      style: GoogleFonts.poppins(
                        color: absensi.statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'hadir': return Icons.check_circle_rounded;
      case 'izin': return Icons.pending_rounded;
      case 'sakit': return Icons.medical_services_rounded;
      case 'alpha': return Icons.cancel_rounded;
      default: return Icons.help_rounded;
    }
  }
}