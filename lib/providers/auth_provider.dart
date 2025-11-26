import 'package:flutter/foundation.dart';
import 'package:abseen_kuliah/services/api_service.dart';
import 'package:abseen_kuliah/services/auth_service.dart';
import 'package:abseen_kuliah/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('login', {
        'email': email,
        'password': password,
      });

      if (response['success']) {
        final userData = response['data']['user'];
        final token = response['data']['access_token'];

        _user = User.fromJson(userData);
        
        await AuthService.saveToken(token);
        await AuthService.saveUser(userData);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.post('logout', {});
    } catch (e) {
      // Ignore logout errors
    } finally {
      _user = null;
      await AuthService.logout();
      notifyListeners();
    }
  }

  Future<bool> checkAuthStatus() async {
    final token = await AuthService.getToken();
    final userData = await AuthService.getUser();

    if (token != null && userData != null) {
      _user = User.fromJson(userData);
      notifyListeners();
      return true;
    }

    return false;
  }
}