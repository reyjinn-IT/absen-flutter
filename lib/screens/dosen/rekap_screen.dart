import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
import 'package:abseen_kuliah/providers/dosen_provider.dart';
import 'package:abseen_kuliah/theme/app_theme.dart';

class DosenRekapScreen extends StatefulWidget {
  final String? kelasId;

  const DosenRekapScreen({Key? key, this.kelasId}) : super(key: key);

  @override
  State<DosenRekapScreen> createState() => _DosenRekapScreenState();
}

class _DosenRekapScreenState extends State<DosenRekapScreen> {
  List<dynamic> _rekapList = [];
  bool _isLoading = false;
  int _totalPertemuan = 16; // Default, bisa dari API

  @override
  void initState() {
    super.initState();
    if (widget.kelasId != null) {
      _loadRekap();
    }
  }

  Future<void> _loadRekap() async {
    if (widget.kelasId == null) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<DosenProvider>(context, listen: false);
      final response = await provider.getRekapAbsensi(widget.kelasId!);

      if (response.isNotEmpty && response.containsKey('rekap_absensi')) {
        setState(() {
          _rekapList = response['rekap_absensi'] ?? [];
          _totalPertemuan = response['kelas']?['total_pertemuan'] ?? 16;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _exportToExcel() {
    // Logic untuk export ke Excel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur export akan segera tersedia'),
        backgroundColor: AppTheme.warningColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Absensi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadRekap,
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _exportToExcel,
            tooltip: 'Export Excel',
          ),
        ],
      ),
      body: widget.kelasId == null
          ? const Center(child: Text('Pilih kelas terlebih dahulu'))
          : Column(
              children: [
                // Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Ringkasan Kelas',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem('Total', _rekapList.length.toString(), Icons.people_rounded),
                          _buildSummaryItem('Pertemuan', _totalPertemuan.toString(), Icons.event_rounded),
                          _buildSummaryItem('Kehadiran', '${_calculatePersentaseKehadiran()}%', Icons.check_circle_rounded),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rekap Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppTheme.backgroundColor,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Nama Mahasiswa',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'H',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'I',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'S',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'A',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '%',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Rekap List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _rekapList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assessment_outlined,
                                    size: 60,
                                    color: AppTheme.textSecondary.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada data rekap',
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 20),
                              itemCount: _rekapList.length,
                              itemBuilder: (context, index) {
                                final rekap = _rekapList[index];
                                final hadir = rekap['hadir'] ?? 0;
                                final izin = rekap['izin'] ?? 0;
                                final sakit = rekap['sakit'] ?? 0;
                                final alpha = rekap['alpha'] ?? 0;
                                final totalPertemuan = rekap['total_pertemuan'] ?? _totalPertemuan;
                                final persentase = totalPertemuan > 0
                                    ? ((hadir * 100) / totalPertemuan).round()
                                    : 0;

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                rekap['mahasiswa']?['name'] ?? 'Unknown',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                rekap['mahasiswa']?['nim'] ?? 'N/A',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            hadir.toString(),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.successColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            izin.toString(),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.warningColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            sakit.toString(),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.accentColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            alpha.toString(),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.errorColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getPersentaseColor(persentase)
                                                  .withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '$persentase%',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _getPersentaseColor(persentase),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  int _calculatePersentaseKehadiran() {
  if (_rekapList.isEmpty || _totalPertemuan == 0) return 0;
  
  int totalHadir = 0;
  for (var rekap in _rekapList) {
      if (rekap is Map<String, dynamic>) {
        totalHadir += (rekap['hadir'] as int? ?? 0);
      } else if (rekap is Map) {
        totalHadir += (rekap['hadir'] as int? ?? 0);
      }
    }
    
    double avgHadir = totalHadir / _rekapList.length;
    return ((avgHadir * 100) / _totalPertemuan).round();
  }

  Color _getPersentaseColor(int persentase) {
    if (persentase >= 80) return AppTheme.successColor;
    if (persentase >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}