import 'package:flutter/foundation.dart';

import '../models/finance_transaction.dart';
import '../services/api_service.dart';

class TransactionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<FinanceTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<FinanceTransaction> get transactions => [..._transactions];

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<FinanceTransaction> get expenses =>
      _transactions.where((tx) => tx.type == TransactionType.expense).toList();

  List<FinanceTransaction> get incomes =>
      _transactions.where((tx) => tx.type == TransactionType.income).toList();

  double get totalExpenses {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalIncomes {
    return incomes.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get balance {
    return totalIncomes - totalExpenses;
  }

  Future<void> fetchTransactions({
    int? walletId,
    int? categoryId,
    String? type,
    String? walletType,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? amountFrom,
    int? amountTo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final transactions = await _apiService.getTransactions(
        walletId: walletId,
        categoryId: categoryId,
        type: type,
        walletType: walletType,
        dateFrom: dateFrom,
        dateTo: dateTo,
        amountFrom: amountFrom,
        amountTo: amountTo,
      );

      _transactions = transactions;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction({
    required int walletId,
    required double amount,
    required String type,
    required DateTime date,
    String? name,
    int? categoryId,
    String? comment,
    bool? templateTransaction,
    bool? regularTransaction,
    int? days,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.createTransaction(
        walletId: walletId,
        amount: amount.toInt(),
        type: type,
        date: date.toIso8601String().split('T')[0],
        // Format: YYYY-MM-DD
        name: name,
        categoryId: categoryId,
        comment: comment,
        templateTransaction: templateTransaction,
        regularTransaction: regularTransaction,
        days: days,
      );

      _isLoading = false;
      if (result['success']) {
        await fetchTransactions();
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.deleteTransaction(int.parse(id));
      _isLoading = false;

      if (success) {
        // Remove from local list to avoid unnecessary API call
        _transactions.removeWhere((tx) => tx.id == id);
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete transaction';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction({
    required int id,
    String? name,
    double? amount,
    String? comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.updateTransaction(
        id,
        name: name,
        amount: amount,
        comment: comment,
      );

      _isLoading = false;
      if (result['success']) {
        await fetchTransactions();
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
