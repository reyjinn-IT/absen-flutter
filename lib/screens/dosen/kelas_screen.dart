import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abseen_kuliah/providers/dosen_provider.dart';
import 'package:abseen_kuliah/theme/app_theme.dart';
import 'package:abseen_kuliah/widgets/kelas_card.dart';

class DosenKelasScreen extends StatefulWidget {
  const DosenKelasScreen({Key? key}) : super(key: key);

  @override
  State<DosenKelasScreen> createState() => _DosenKelasScreenState();
}

class _DosenKelasScreenState extends State<DosenKelasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKelas();
    });
  }

  Future<void> _loadKelas() async {
    await Provider.of<DosenProvider>(context, listen: false).fetchKelasDosen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelas Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadKelas,
          ),
        ],
      ),
      body: Consumer<DosenProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final kelasList = provider.kelasList ?? [];

          if (kelasList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.class_outlined,
                    size: 80,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada kelas',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Anda belum memiliki kelas yang diajar',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: kelasList.length,
            itemBuilder: (context, index) {
              final kelas = kelasList[index];
              return InkWell(
                onTap: () {
                  _showKelasDetail(context, kelas);
                },
                child: KelasCard(
                  kode: kelas['kode_kelas'] ?? 'N/A',
                  nama: kelas['matakuliah']?['nama_mk'] ?? 'N/A',
                  waktu: _getJadwalKelas(kelas),
                  ruang: 'R. ${kelas['ruang'] ?? '-'}',
                  mahasiswa: '${kelas['mahasiswa_count'] ?? 0} Mahasiswa',
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getJadwalKelas(Map<String, dynamic> kelas) {
    // Format jadwal sesuai data yang ada
    return 'Senin 08:00-10:00'; // Ganti dengan data dari API
  }

  void _showKelasDetail(BuildContext context, Map<String, dynamic> kelas) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kelas['nama_kelas'] ?? 'Kelas',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kode: ${kelas['kode_kelas']}',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Informasi Mata Kuliah
                ListTile(
                  leading: const Icon(Icons.menu_book_rounded),
                  title: const Text('Mata Kuliah'),
                  subtitle: Text(kelas['matakuliah']?['nama_mk'] ?? '-'),
                ),
                // Jumlah Mahasiswa
                ListTile(
                  leading: const Icon(Icons.people_rounded),
                  title: const Text('Jumlah Mahasiswa'),
                  subtitle: Text('${kelas['mahasiswa_count'] ?? 0} orang'),
                ),
                // Jadwal
                ListTile(
                  leading: const Icon(Icons.schedule_rounded),
                  title: const Text('Jadwal'),
                  subtitle: Text(_getJadwalKelas(kelas)),
                ),
                // Ruang
                ListTile(
                  leading: const Icon(Icons.location_on_rounded),
                  title: const Text('Ruang'),
                  subtitle: Text(kelas['ruang'] ?? '-'),
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/dosen/generate-qr',
                              arguments: {
                                'kelasId': kelas['id'],
                                'kodeKelas': kelas['kode_kelas'],
                                'namaKelas': kelas['nama_kelas'],
                              },
                            );
                          },
                          icon: const Icon(Icons.qr_code_rounded, size: 20),
                          label: const Text('Generate QR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/dosen/absensi-kelas',
                              arguments: {'kelasId': kelas['id']},
                            );
                          },
                          icon: const Icon(Icons.checklist_rounded, size: 20),
                          label: const Text('Absensi'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}