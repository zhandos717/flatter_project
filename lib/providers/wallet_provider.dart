import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class WalletProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _wallets = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get wallets => [..._wallets];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Получение кошельков определенного типа
  Future<void> fetchWallets(int type) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getWallets(type);
      _wallets = data;
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
        await fetchWallets(type);
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
      total += double.parse(wallet['balance'].toString());
    }
    return total;
  }

  // Получение кошелька по ID
  Map<String, dynamic>? getWalletById(int walletId) {
    try {
      return _wallets.firstWhere((wallet) => wallet['id'].toString() == walletId.toString());
    } catch (e) {
      return null;
    }
  }

  // Фильтрация кошельков по типу
  List<Map<String, dynamic>> getWalletsByType(int type) {
    return _wallets.where((wallet) => wallet['type'].toString() == type.toString()).toList();
  }

  // Очистка сообщений об ошибках
  void clearError() {
    _error = null;
    notifyListeners();
  }
}