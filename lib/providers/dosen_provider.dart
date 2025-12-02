import 'package:flutter/foundation.dart';
import 'package:abseen_kuliah/services/api_service.dart';

class DosenProvider with ChangeNotifier {
  Map<String, dynamic>? _dashboardData;
  List<dynamic>? _kelasList;
  bool _isLoading = false;

  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<dynamic>? get kelasList => _kelasList;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('dosen/dashboard');
      if (response['success']) {
        _dashboardData = response['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching dosen dashboard: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchKelasDosen() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('dosen/kelas');
      if (response['success']) {
        _kelasList = response['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching dosen kelas: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getAbsensiKelas(String kelasId, String tanggal) async {
    try {
      final response = await ApiService.get('dosen/kelas/$kelasId/absensi?tanggal=$tanggal');
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRekapAbsensi(String kelasId) async {
    try {
      final response = await ApiService.get('dosen/kelas/$kelasId/rekap');
      return response['data'] ?? {};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> inputAbsensiManual(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('dosen/absensi/manual', data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}