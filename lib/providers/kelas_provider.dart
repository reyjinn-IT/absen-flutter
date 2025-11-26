import 'package:flutter/foundation.dart';
import 'package:abseen_kuliah/services/api_service.dart';
import 'package:abseen_kuliah/models/kelas_model.dart';

class KelasProvider with ChangeNotifier {
  List<Kelas> _kelasList = [];
  bool _isLoading = false;

  List<Kelas> get kelasList => _kelasList;
  bool get isLoading => _isLoading;

  Future<void> fetchKelasMahasiswa() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('mahasiswa/kelas');
      if (response['success']) {
        _kelasList = (response['data'] as List)
            .map((item) => Kelas.fromJson(item))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching kelas: $e');
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
        _kelasList = (response['data'] as List)
            .map((item) => Kelas.fromJson(item))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching kelas dosen: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}