import 'package:flutter/foundation.dart';
import 'package:abseen_kuliah/services/api_service.dart';

class AdminProvider with ChangeNotifier {
  Map<String, dynamic>? _dashboardStats;
  List<dynamic>? _users; // ✅ TAMBAH INI
  bool _isLoading = false;

  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  List<dynamic>? get users => _users; // ✅ TAMBAH GETTER
  bool get isLoading => _isLoading;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('admin/dashboard');
      if (response['success']) {
        _dashboardStats = response['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching dashboard stats: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('admin/users');
      if (response['success']) {
        // Handle users data
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching users: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await ApiService.post('admin/users', userData);
      if (response['success']) {
        await fetchUsers();
        return response;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchMatakuliah() async {
    try {
      final response = await ApiService.get('admin/matakuliah');
      if (response['success']) {
        return response['data'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createMatakuliah(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('admin/matakuliah', data);
      if (response['success']) {
        return response;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchKelas() async {
    try {
      final response = await ApiService.get('admin/kelas');
      if (response['success']) {
        return response['data'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createKelas(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('admin/kelas', data);
      if (response['success']) {
        return response;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getLaporanAbsensi({
    required String startDate,
    required String endDate,
    String? kelasId,
  }) async {
    try {
      Map<String, dynamic> params = {
        'start_date': startDate,
        'end_date': endDate,
      };
      
      if (kelasId != null) {
        params['kelas_id'] = kelasId;
      }

      final response = await ApiService.get('admin/laporan-absensi');
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }
}