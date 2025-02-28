import 'package:flutter/material.dart';
import 'package:finance_app/models/category.dart';
import 'package:finance_app/services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category>? _categories;
  bool _isLoading = false;
  String? _error;

  // Геттеры
  List<Category>? get categories => _categories;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // Геттер для категорий расходов
  List<Map<String, dynamic>> get expenseCategories {
    if (_categories == null) return [];
    return _categories!
        .where((cat) => cat.type == Category.Expense)
        .map((cat) => cat.toMap())
        .toList();
  }

  // Геттер для категорий доходов
  List<Map<String, dynamic>> get incomeCategories {
    if (_categories == null) return [];
    return _categories!
        .where((cat) => cat.type == Category.Income)
        .map((cat) => cat.toMap())
        .toList();
  }

  // API сервис для работы с бэкендом
  final ApiService _apiService;

  // Конструктор
  CategoryProvider({required ApiService apiService})
      : _apiService = apiService {
    fetchCategories();
  }

  // Загрузка категорий
  Future<void> fetchCategories({int? type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getCategories(type);

      _categories = result.map((item) => Category.fromMap(item)).toList();

      print(_categories);
    } catch (e) {
      _error = 'Ошибка при загрузке категорий: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Добавление новой категории
  Future<bool> addCategory(
      String name, int type, int icon, String color) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.createCategory(name, type, icon, color);
      _isLoading = false;

      if (result['success']) {
        // Если успешно добавлено на сервере, обновляем локальный список
        await fetchCategories();
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

  // Обновление существующей категории
  Future<bool> updateCategory(Category category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.updateCategory(category);
      _isLoading = false;

      if (result['success']) {
        // Если успешно обновлено на сервере, обновляем локальный список
        await fetchCategories();
        return true;
      } else {
        _error = result['message'] ?? 'Не удалось обновить категорию';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Ошибка при обновлении категории: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Удаление категории
  Future<bool> deleteCategory(int? id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.deleteCategory(id);
      _isLoading = false;

      if (result['success']) {
        // Если успешно удалено на сервере, обновляем локальный список
        await fetchCategories();
        return true;
      } else {
        _error = result['message'] ?? 'Не удалось удалить категорию';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Ошибка при удалении категории: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Сброс ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
