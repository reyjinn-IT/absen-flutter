import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abseen_kuliah/providers/auth_provider.dart';
import 'package:abseen_kuliah/providers/dosen_provider.dart';
import 'package:abseen_kuliah/theme/app_theme.dart';
import 'package:abseen_kuliah/widgets/stat_card.dart';
import 'package:abseen_kuliah/widgets/kelas_card.dart';

class DosenDashboardScreen extends StatefulWidget {
  const DosenDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DosenDashboardScreen> createState() => _DosenDashboardScreenState();
}

class _DosenDashboardScreenState extends State<DosenDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dosenProvider = Provider.of<DosenProvider>(context, listen: false);
    await dosenProvider.fetchDashboardData();
    await dosenProvider.fetchKelasDosen();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dosenProvider = Provider.of<DosenProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Dosen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_rounded),
            onSelected: (value) {
              if (value == 'logout') {
                _confirmLogout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: dosenProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang,',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          user?.name ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${user?.nidn ?? ''} - Dosen',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats Section
                  Text(
                    'Ringkasan Mengajar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildStatsSection(dosenProvider),

                  const SizedBox(height: 24),

                  // Kelas Hari Ini
                  _buildKelasSection(dosenProvider),

                  // Quick Actions
                  const SizedBox(height: 24),
                  Text(
                    'Aksi Cepat',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showGenerateQRDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsSection(DosenProvider provider) {
    final stats = provider.dashboardData?['stats'] ?? {};
    final kelasAktif = provider.dashboardData?['kelas_aktif'] ?? [];

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      children: [
        StatCard(
          title: 'Total Kelas',
          value: stats['total_kelas']?.toString() ?? '0',
          icon: Icons.class_rounded,
          color: AppTheme.primaryColor,
        ),
        StatCard(
          title: 'Mata Kuliah',
          value: stats['total_matakuliah']?.toString() ?? '0',
          icon: Icons.menu_book_rounded,
          color: AppTheme.successColor,
        ),
        StatCard(
          title: 'Mahasiswa',
          value: _calculateTotalMahasiswa(kelasAktif),
          icon: Icons.people_rounded,
          color: AppTheme.accentColor,
        ),
        StatCard(
          title: 'Pertemuan',
          value: '0', // Sesuaikan dengan API
          icon: Icons.event_rounded,
          color: AppTheme.warningColor,
        ),
      ],
    );
  }

  String _calculateTotalMahasiswa(List<dynamic> kelasAktif) {
    int total = 0;
    for (var kelas in kelasAktif) {
      total += int.tryParse(kelas['mahasiswa_count']?.toString() ?? '0') ?? 0;
    }
    return total.toString();
  }

  Widget _buildKelasSection(DosenProvider provider) {
    final kelasList = provider.kelasList ?? [];
    final today = DateTime.now();

    if (kelasList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kelas Saya',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/dosen/kelas');
                },
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.class_outlined,
                    size: 48,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada kelas',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kelas Hari Ini',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/dosen/kelas');
              },
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: kelasList.length,
          itemBuilder: (context, index) {
            final kelas = kelasList[index];
            return InkWell(
              onTap: () {
                _showKelasOptions(context, kelas);
              },
              child: KelasCard(
                kode: kelas['kode_kelas'] ?? 'N/A',
                nama: kelas['matakuliah']?['nama_mk'] ?? 'N/A',
                waktu: 'Jam kuliah',
                ruang: 'Ruang kuliah',
                mahasiswa: '${kelas['mahasiswa_count'] ?? 0} Mahasiswa',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      children: [
        _buildActionCard(
          context,
          'Generate QR',
          Icons.qr_code_2_rounded,
          AppTheme.primaryColor,
          () => _showGenerateQRDialog(context),
        ),
        _buildActionCard(
          context,
          'Lihat Absensi',
          Icons.checklist_rounded,
          AppTheme.successColor,
          () => Navigator.pushNamed(context, '/dosen/absensi'),
        ),
        _buildActionCard(
          context,
          'Rekap Nilai',
          Icons.assessment_rounded,
          AppTheme.accentColor,
          () => Navigator.pushNamed(context, '/dosen/nilai'),
        ),
        _buildActionCard(
          context,
          'Pengaturan',
          Icons.settings_rounded,
          AppTheme.warningColor,
          () => Navigator.pushNamed(context, '/dosen/settings'),
        ),
      ],
    );
  }

  void _showKelasOptions(BuildContext context, Map<String, dynamic> kelas) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  kelas['nama_kelas'] ?? 'Kelas',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_rounded),
                title: const Text('Generate QR Code'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/dosen/generate-qr',
                    arguments: {
                      'kelasId': kelas['id'],
                      'kodeKelas': kelas['kode_kelas'],
                      'namaKelas': kelas['nama_kelas'],
                      'matakuliah': kelas['matakuliah']?['nama_mk'],
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.checklist_rounded),
                title: const Text('Lihat Absensi'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/dosen/absensi-kelas',
                    arguments: {'kelasId': kelas['id']},
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.assessment_rounded),
                title: const Text('Rekap Absensi'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/dosen/rekap-absensi',
                    arguments: {'kelasId': kelas['id']},
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.people_rounded),
                title: const Text('Daftar Mahasiswa'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/dosen/mahasiswa-kelas',
                    arguments: {'kelasId': kelas['id']},
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGenerateQRDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Generate QR Code'),
          content: const Text('Pilih opsi generate QR Code:'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dosen/generate-qr');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('QR Umum'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    Future.delayed(const Duration(milliseconds: 500), () {
      authProvider.logout();
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/login');
    });
  }
}