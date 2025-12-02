import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:abseen_kuliah/providers/admin_provider.dart';
import 'package:abseen_kuliah/theme/app_theme.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final List<String> _roles = ['admin', 'dosen', 'mahasiswa'];
  String _selectedRole = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    await Provider.of<AdminProvider>(context, listen: false).fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari user...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedRole,
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('Semua Role'),
                    ),
                    ..._roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(
                          role == 'admin' ? 'Admin' : 
                          role == 'dosen' ? 'Dosen' : 'Mahasiswa',
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = provider.users ?? [];

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 60,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada user',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userRole = user['role'].toString();

                    // Apply filters
                    if (_selectedRole != 'all' && userRole != _selectedRole) {
                      return const SizedBox.shrink();
                    }

                    if (_searchController.text.isNotEmpty &&
                        !user['name'].toString().toLowerCase().contains(
                              _searchController.text.toLowerCase(),
                            ) &&
                        !user['email'].toString().toLowerCase().contains(
                              _searchController.text.toLowerCase(),
                            ) &&
                        !user['nim'].toString().toLowerCase().contains(
                              _searchController.text.toLowerCase(),
                            ) &&
                        !user['nidn'].toString().toLowerCase().contains(
                              _searchController.text.toLowerCase(),
                            )) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(userRole)
                              .withOpacity(0.1),
                          child: Icon(
                            _getRoleIcon(userRole),
                            color: _getRoleColor(userRole),
                          ),
                        ),
                        title: Text(
                          user['name'] ?? 'Unknown',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['email'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (user['nim'] != null)
                              Text(
                                'NIM: ${user['nim']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            if (user['nidn'] != null)
                              Text(
                                'NIDN: ${user['nidn']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(userRole).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getRoleText(userRole),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: _getRoleColor(userRole),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        onTap: () {
                          _showUserDetail(context, user);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showUserDetail(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['name'] ?? 'User Detail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Email', user['email']),
            _buildDetailItem('Role', _getRoleText(user['role'])),
            if (user['nim'] != null) _buildDetailItem('NIM', user['nim']),
            if (user['nidn'] != null) _buildDetailItem('NIDN', user['nidn']),
            if (user['phone'] != null) _buildDetailItem('Phone', user['phone']),
            _buildDetailItem(
                'Created', user['created_at']?.toString().substring(0, 10) ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Edit user logic
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nimController = TextEditingController();
    final nidnController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRole = 'mahasiswa';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah User Baru'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email harus diisi';
                        }
                        if (!value.contains('@')) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password harus diisi';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      items: _roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(
                            role == 'admin' ? 'Admin' : 
                            role == 'dosen' ? 'Dosen' : 'Mahasiswa',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (selectedRole == 'mahasiswa')
                      TextFormField(
                        controller: nimController,
                        decoration: const InputDecoration(
                          labelText: 'NIM',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (selectedRole == 'mahasiswa' &&
                              (value == null || value.isEmpty)) {
                            return 'NIM harus diisi';
                          }
                          return null;
                        },
                      ),
                    if (selectedRole == 'dosen')
                      TextFormField(
                        controller: nidnController,
                        decoration: const InputDecoration(
                          labelText: 'NIDN',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (selectedRole == 'dosen' &&
                              (value == null || value.isEmpty)) {
                            return 'NIDN harus diisi';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final adminProvider = Provider.of<AdminProvider>(
                      context,
                      listen: false,
                    );

                    final userData = {
                      'name': nameController.text,
                      'email': emailController.text,
                      'password': passwordController.text,
                      'password_confirmation': passwordController.text,
                      'role': selectedRole,
                      'nim': nimController.text,
                      'nidn': nidnController.text,
                      'phone': phoneController.text,
                    };

                    try {
                      await adminProvider.createUser(userData);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User berhasil ditambahkan'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppTheme.primaryColor;
      case 'dosen':
        return AppTheme.accentColor;
      case 'mahasiswa':
        return AppTheme.successColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      case 'dosen':
        return Icons.school_rounded;
      case 'mahasiswa':
        return Icons.person_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'dosen':
        return 'Dosen';
      case 'mahasiswa':
        return 'Mahasiswa';
      default:
        return role;
    }
  }
}