import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // TAMBAH INI

import 'package:abseen_kuliah/theme/app_theme.dart';
class KelasCard extends StatelessWidget {
  final String kode;
  final String nama;
  final String waktu;
  final String ruang;
  final String? dosen;
  final String? mahasiswa;
  final VoidCallback? onTap;

  const KelasCard({
    Key? key,
    required this.kode,
    required this.nama,
    required this.waktu,
    required this.ruang,
    this.dosen,
    this.mahasiswa,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
                      nama,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kode: $kode • $waktu',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Ruang: $ruang',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (dosen != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Dosen: $dosen',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (mahasiswa != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        mahasiswa!,
                        style: GoogleFonts.poppins(
                          color: AppTheme.accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}