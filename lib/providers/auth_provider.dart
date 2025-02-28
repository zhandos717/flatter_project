import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_app/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String? _token;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Map<String, dynamic>? get user => _user;

  AuthProvider() {
    // Проверяем аутентификацию при создании провайдера
    checkAuth();
  }

  // Проверка состояния аутентификации при загрузке
  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      _token = token;

      // Получаем данные пользователя, если есть токен
      try {
        final userData = await _apiService.getUserInfo();
        if (userData != null) {
          _user = userData;
        }
      } catch (e) {
        print('Error getting user data: $e');
      }
    } else {
      _isAuthenticated = false;
      _token = null;
      _user = null;
    }

    notifyListeners();
  }

  // Вход в систему с номером телефона
  Future<bool> login(String phoneNumber, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.login(phoneNumber, password);
      _isLoading = false;

      if (result['success']) {
        _isAuthenticated = true;
        _user = result['user'];

        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('auth_token');

        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Неверные учетные данные';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Ошибка при входе: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Выход из системы
  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.logout();
      _isLoading = false;

      if (success) {
        _isAuthenticated = false;
        _token = null;
        _user = null;

        // Очищаем токен из SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
      } else {
        _error = 'Ошибка при выходе';
      }

      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = 'Ошибка при выходе: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Обновление данных пользователя
  Future<bool> updateUserProfile(
      {String? name,
      String? middleName,
      String? email,
      String? birthdate,
      int? monthLimit,
      int? dayLimit}) async {
    _isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> userData = {};

      if (name != null) userData['name'] = name;
      if (middleName != null) userData['middle_name'] = middleName;
      if (email != null) userData['email'] = email;
      if (birthdate != null) userData['birthdate'] = birthdate;
      if (monthLimit != null) userData['month_limit'] = monthLimit;
      if (dayLimit != null) userData['day_limit'] = dayLimit;

      final result = await _apiService.updateUserInfo(userData);
      _isLoading = false;

      if (result['success']) {
        _user = result['user'];
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Ошибка обновления профиля';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Ошибка при обновлении профиля: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Изменение пароля
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.changePassword(oldPassword, newPassword);
      _isLoading = false;

      if (result['success']) {
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Ошибка изменения пароля';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Ошибка при изменении пароля: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Обновление информации о пользователе из API
  Future<bool> refreshUserInfo() async {
    if (!_isAuthenticated) return false;

    try {
      final userData = await _apiService.getUserInfo();
      if (userData != null) {
        _user = userData;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error refreshing user data: $e');
      return false;
    }
  }

  // Очистка сообщений об ошибках
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
