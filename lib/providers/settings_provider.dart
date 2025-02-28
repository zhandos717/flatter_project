import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _areNotificationsEnabled = true;
  String _languageCode = 'en';

  bool get isDarkMode => _isDarkMode;
  bool get areNotificationsEnabled => _areNotificationsEnabled;
  String get languageCode => _languageCode;

  SettingsProvider() {
    _loadSettings();
  }

  // Загрузка настроек из SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _areNotificationsEnabled = prefs.getBool('areNotificationsEnabled') ?? true;
    _languageCode = prefs.getString('languageCode') ?? 'en';
    notifyListeners();
  }

  // Переключение темной темы
  Future<void> toggleDarkMode(bool value) async {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', value);
      notifyListeners();
    }
  }

  // Переключение уведомлений
  Future<void> toggleNotifications(bool value) async {
    if (_areNotificationsEnabled != value) {
      _areNotificationsEnabled = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('areNotificationsEnabled', value);
      notifyListeners();
    }
  }

  // Изменение языка
  Future<void> changeLanguage(String languageCode) async {
    if (_languageCode != languageCode) {
      _languageCode = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', languageCode);
      notifyListeners();
    }
  }
}
