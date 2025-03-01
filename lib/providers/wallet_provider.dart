import 'package:finance_app/models/wallet.dart';
import 'package:finance_app/services/api_service.dart';
import 'package:flutter/foundation.dart';

class WalletProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Wallet> _wallets = [];
  bool _isLoading = false;
  String? _error;

  List<Wallet> get wallets => [..._wallets];

  bool get isLoading => _isLoading;

  String? get error => _error;

// Получение кошельков с гибкими фильтрами
  Future<void> fetchWallets({
    int? type,
    String? name,
    bool? isActive,
    // Добавьте другие возможные параметры
    Map<String, dynamic>? additionalFilters,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Создаем словарь со всеми фильтрами
      Map<String, dynamic> filters = {};

      // Добавляем основные фильтры, если они не null
      if (type != null) filters['type'] = type;
      if (name != null) filters['name'] = name;
      if (isActive != null) filters['isActive'] = isActive;

      // Добавляем дополнительные фильтры, если они предоставлены
      if (additionalFilters != null) {
        filters.addAll(additionalFilters);
      }

      // Передаем фильтры в API-метод
      final data = await _apiService.getWallets(filters: filters);

      // Преобразуем Map<String, dynamic> в объекты модели Wallet
      _wallets = data.map((item) => Wallet.fromJson(item)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Не удалось загрузить кошельки: ${e.toString()}';
      notifyListeners();
    }
  }

  // Создание нового кошелька
  Future<bool> addWallet(
    String name,
    int type, {
    int? desiredBalance,
    String? color,
    int? icon,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.createWallet(
        name,
        type,
        desiredBalance: desiredBalance,
        color: color,
        icon: icon,
      );

      _isLoading = false;

      if (result['success']) {
        await fetchWallets(type: type);
        return true;
      } else {
        _error = result['message'] ?? 'Не удалось создать кошелек';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Ошибка при создании кошелька: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Получение информации о балансе всех кошельков
  double getTotalBalance() {
    double total = 0;
    for (var wallet in _wallets) {
      total += wallet.balanceAsDouble;
    }
    return total;
  }

  // Получение кошелька по ID
  Wallet? getWalletById(String walletId) {
    try {
      return _wallets.firstWhere((wallet) => wallet.id == walletId);
    } catch (e) {
      return null;
    }
  }

  // Фильтрация кошельков по типу
  List<Wallet> getWalletsByType(int type) {
    final typeStr = type.toString();
    return _wallets.where((wallet) => wallet.type == typeStr).toList();
  }

  // Очистка сообщений об ошибках
  void clearError() {
    _error = null;
    notifyListeners();
  }

  int _selectedWalletIndex = 0; // Default to first wallet

  // Getter for selected wallet index
  int get selectedWalletIndex => _selectedWalletIndex;

  // Method to set selected wallet index
  void setSelectedWalletIndex(int index) {
    if (index >= 0 && index < _wallets.length) {
      _selectedWalletIndex = index;
      notifyListeners(); // Notify listeners of the change
    }
  }

  // Обновление существующего кошелька
  Future<bool> updateWallet(
    Wallet wallet, {
    String? name,
    String? desiredBalance,
    String? color,
    String? icon,
    String? filePath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.updateWallet(
        wallet.id,
        name: name,
        desiredBalance: desiredBalance,
        color: color,
        icon: icon,
        filePath: filePath,
      );

      _isLoading = false;

      if (result['success']) {
        // Перезагружаем кошельки, чтобы отобразить изменения
        await fetchWallets();
        return true;
      } else {
        _error = result['message'] ?? 'Не удалось обновить кошелек';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Ошибка при обновлении кошелька: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
