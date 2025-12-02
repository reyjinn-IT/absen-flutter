import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abseen_kuliah/theme/app_theme.dart';
import 'package:abseen_kuliah/widgets/stat_card.dart';
import 'package:abseen_kuliah/providers/admin_provider.dart';
import 'package:abseen_kuliah/providers/auth_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late AdminProvider _adminProvider;

  @override
  void initState() {
    super.initState();
    _adminProvider = Provider.of<AdminProvider>(context, listen: false);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await _adminProvider.fetchDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDashboardData,
          ),
          // Profile menu - SAMA DENGAN MAHASISWA (TAPI TIDAK ADA LOGOUT)
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name?.substring(0, 1) ?? 'A',
                style: const TextStyle(color: AppTheme.primaryColor),
              ),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.pushNamed(context, '/admin/profile');
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
              ];
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.dashboardStats;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section - SAMA DENGAN MAHASISWA
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
                        user?.name ?? 'Administrator',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${user?.email ?? 'admin@poltek-gt.ac.id'}',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats Section - SAMA DENGAN MAHASISWA (2x2 grid)
                Text(
                  'Statistik Sistem',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                GridView(
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
                      title: 'Total Mahasiswa',
                      value: stats?['total_mahasiswa']?.toString() ?? '0',
                      icon: Icons.people_alt_rounded,
                      color: AppTheme.primaryColor,
                    ),
                    StatCard(
                      title: 'Total Dosen',
                      value: stats?['total_dosen']?.toString() ?? '0',
                      icon: Icons.school_rounded,
                      color: AppTheme.successColor,
                    ),
                    StatCard(
                      title: 'Mata Kuliah',
                      value: stats?['total_matakuliah']?.toString() ?? '0',
                      icon: Icons.menu_book_rounded,
                      color: AppTheme.accentColor,
                    ),
                    StatCard(
                      title: 'Kelas Aktif',
                      value: stats?['total_kelas']?.toString() ?? '0',
                      icon: Icons.class_rounded,
                      color: AppTheme.warningColor,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Actions Section - TAPI DENGAN STYLE YANG SAMA
                Text(
                  'Aksi Cepat',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2, // SAMA DENGAN STATS
                  ),
                  children: [
                    _buildActionCard(
                      'Manajemen User',
                      Icons.people_outline_rounded,
                      AppTheme.primaryColor,
                    ),
                    _buildActionCard(
                      'Data Kelas',
                      Icons.class_rounded,
                      AppTheme.successColor,
                    ),
                    _buildActionCard(
                      'Mata Kuliah',
                      Icons.menu_book_rounded,
                      AppTheme.accentColor,
                    ),
                    _buildActionCard(
                      'Laporan',
                      Icons.analytics_rounded,
                      AppTheme.warningColor,
                    ),
                  ],
                ),

                // Recent Absensi - JIKA ADA DATA
                if (stats?['recent_absensi'] != null &&
                    (stats!['recent_absensi'] as List).isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Absensi Terbaru',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ..._buildRecentAbsensi(stats['recent_absensi']),
                ],
              ],
            ),
          );
        },
      ),
      // FLOATING ACTION BUTTON - TAMBAHKAN UNTUK ADMIN
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin/users');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigasi berdasarkan title
          switch (title) {
            case 'Manajemen User':
              Navigator.pushNamed(context, '/admin/users');
              break;
            case 'Data Kelas':
              Navigator.pushNamed(context, '/admin/kelas');
              break;
            case 'Mata Kuliah':
              Navigator.pushNamed(context, '/admin/matakuliah');
              break;
            case 'Laporan':
              Navigator.pushNamed(context, '/admin/laporan');
              break;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                title,
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

  List<Widget> _buildRecentAbsensi(List<dynamic> absensiList) {
    return absensiList.take(5).map((absensi) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(absensi['status'])
                .withOpacity(0.1),
            child: Icon(
              _getStatusIcon(absensi['status']),
              color: _getStatusColor(absensi['status']),
              size: 20,
            ),
          ),
          title: Text(
            absensi['mahasiswa']?['name'] ?? 'Unknown',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${absensi['kelas']?['nama_kelas'] ?? ''} • ${absensi['tanggal']}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(absensi['status']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _getStatusText(absensi['status']),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: _getStatusColor(absensi['status']),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }).toList();
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