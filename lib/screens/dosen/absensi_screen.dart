import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:abseen_kuliah/providers/dosen_provider.dart';
import 'package:abseen_kuliah/theme/app_theme.dart';

class DosenAbsensiScreen extends StatefulWidget {
  final String? kelasId;

  const DosenAbsensiScreen({Key? key, this.kelasId}) : super(key: key);

  @override
  State<DosenAbsensiScreen> createState() => _DosenAbsensiScreenState();
}

class _DosenAbsensiScreenState extends State<DosenAbsensiScreen> {
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<dynamic> _absensiList = [];
  bool _isLoading = false;
  Map<String, String> _statusUpdates = {};

  @override
  void initState() {
    super.initState();
    if (widget.kelasId != null) {
      _loadAbsensi();
    }
  }

  Future<void> _loadAbsensi() async {
    if (widget.kelasId == null) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<DosenProvider>(context, listen: false);
      final response = await provider.getAbsensiKelas(
        widget.kelasId!,
        _selectedDate,
      );

      if (response.isNotEmpty && response.containsKey('absensi')) {
        setState(() {
          _absensiList = response['absensi'] ?? [];
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

  Future<void> _updateStatus(String mahasiswaId, String status) async {
    try {
      final provider = Provider.of<DosenProvider>(context, listen: false);
      await provider.inputAbsensiManual({
        'kelas_id': widget.kelasId,
        'mahasiswa_id': mahasiswaId,
        'tanggal': _selectedDate,
        'status': status,
        'keterangan': 'Diupdate oleh dosen',
      });

      setState(() {
        _statusUpdates[mahasiswaId] = status;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status absensi berhasil diupdate'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      await _loadAbsensi();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      await _loadAbsensi();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Absensi'),
      ),
      body: widget.kelasId == null
          ? const Center(child: Text('Pilih kelas terlebih dahulu'))
          : Column(
              children: [
                // Date Picker Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.backgroundColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal Absensi',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.textSecondary.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('dd MMMM yyyy').format(DateTime.parse(_selectedDate)),
                                      style: GoogleFonts.poppins(),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.arrow_drop_down_rounded),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: _loadAbsensi,
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ),

                // Status Legend
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppTheme.backgroundColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem('Hadir', AppTheme.successColor),
                      _buildLegendItem('Izin', AppTheme.warningColor),
                      _buildLegendItem('Sakit', AppTheme.accentColor),
                      _buildLegendItem('Alpha', AppTheme.errorColor),
                    ],
                  ),
                ),

                // Absensi List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _absensiList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.checklist_rounded,
                                    size: 60,
                                    color: AppTheme.textSecondary.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada data absensi',
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Untuk tanggal $_selectedDate',
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _absensiList.length,
                              itemBuilder: (context, index) {
                                final absensi = _absensiList[index];
                                final mahasiswa = absensi['mahasiswa'];
                                final status = absensi['status'];
                                final updatedStatus = _statusUpdates[mahasiswa?['id'].toString()];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getStatusColor(updatedStatus ?? status)
                                          .withOpacity(0.1),
                                      child: Icon(
                                        _getStatusIcon(updatedStatus ?? status),
                                        color: _getStatusColor(updatedStatus ?? status),
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      mahasiswa?['name'] ?? 'Unknown',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      mahasiswa?['nim'] ?? 'N/A',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      icon: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(updatedStatus ?? status)
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getStatusText(updatedStatus ?? status),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: _getStatusColor(updatedStatus ?? status),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      onSelected: (value) async {
                                        await _updateStatus(
                                          mahasiswa?['id']?.toString() ?? '', // ✅ Handle null safety
                                          value,
                                        );
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          PopupMenuItem<String>(
                                            value: 'hadir',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  color: AppTheme.successColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                const Text('Hadir'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'izin',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.pending_rounded,
                                                  color: AppTheme.warningColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                const Text('Izin'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'sakit',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.medical_services_rounded,
                                                  color: AppTheme.accentColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                const Text('Sakit'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'alpha',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.cancel_rounded,
                                                  color: AppTheme.errorColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                const Text('Alpha'),
                                              ],
                                            ),
                                          ),
                                        ];
                                      },
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

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'hadir':
        return AppTheme.successColor;
      case 'izin':
        return AppTheme.warningColor;
      case 'sakit':
        return AppTheme.accentColor;
      case 'alpha':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'hadir':
        return Icons.check_circle_rounded;
      case 'izin':
        return Icons.pending_rounded;
      case 'sakit':
        return Icons.medical_services_rounded;
      case 'alpha':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'hadir':
        return 'Hadir';
      case 'izin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      case 'alpha':
        return 'Alpha';
      default:
        return status;
    }
  }
}