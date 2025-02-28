import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get categories => [..._categories];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Получение категорий определенного типа
  Future<void> fetchCategories({int? type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getCategories(type: type);
      _categories = data;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Не удалось загрузить категории: ${e.toString()}';
      notifyListeners();
    }
  }

  // Создание новой категории
  Future<bool> addCategory(String name, int type, int icon, String color) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.createCategory(name, type, icon, color);
      _isLoading = false;

      if (result['success']) {
        await fetchCategories(type: type);
        return true;
      } else {
        _error = result['message'] ?? 'Не удалось создать категорию';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Ошибка при создании категории: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Получение категории по ID
  Map<String, dynamic>? getCategoryById(int categoryId) {
    try {
      return _categories.firstWhere((category) => category['id'].toString() == categoryId.toString());
    } catch (e) {
      return null;
    }
  }

  // Фильтрация категорий по типу
  List<Map<String, dynamic>> getCategoriesByType(int type) {
    return _categories.where((category) => category['type'].toString() == type.toString()).toList();
  }

  // Очистка сообщений об ошибках
  void clearError() {
    _error = null;
    notifyListeners();
  }
}