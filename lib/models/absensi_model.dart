import 'package:flutter/material.dart';
import 'package:abseen_kuliah/theme/app_theme.dart';

class Absensi {
  final int id;
  final String tanggal;
  final String status;
  final String? keterangan;
  final String? waktuMasuk;
  final String kelas;

  Absensi({
    required this.id,
    required this.tanggal,
    required this.status,
    this.keterangan,
    this.waktuMasuk,
    required this.kelas,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) {
    return Absensi(
      id: json['id'],
      tanggal: json['tanggal'],
      status: json['status'],
      keterangan: json['keterangan'],
      waktuMasuk: json['waktu_masuk'],
      kelas: json['kelas']?['nama_kelas'] ?? 'Unknown',
    );
  }

  String get statusText {
    switch (status) {
      case 'hadir': return 'Hadir';
      case 'izin': return 'Izin';
      case 'sakit': return 'Sakit';
      case 'alpha': return 'Alpha';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'hadir': return AppTheme.successColor;
      case 'izin': return AppTheme.warningColor;
      case 'sakit': return AppTheme.accentColor;
      case 'alpha': return AppTheme.errorColor;
      default: return AppTheme.textSecondary;
    }
  }
}