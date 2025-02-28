import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../models/finance_transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<FinanceTransaction> _transactions = [];

  List<FinanceTransaction> get transactions => [..._transactions];

  List<FinanceTransaction> get expenses => _transactions
      .where((tx) => tx.type == TransactionType.expense)
      .toList();

  List<FinanceTransaction> get incomes => _transactions
      .where((tx) => tx.type == TransactionType.income)
      .toList();

  double get totalExpenses {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalIncomes {
    return incomes.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get balance {
    return totalIncomes - totalExpenses;
  }

  Future<void> fetchTransactions() async {
    final dbService = DatabaseService();
    final data = await dbService.getTransactions();
    _transactions = data;
    notifyListeners();
  }

  Future<void> addTransaction(FinanceTransaction transaction) async {
    final dbService = DatabaseService();
    await dbService.insertTransaction(transaction);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    final dbService = DatabaseService();
    await dbService.deleteTransaction(id);
    await fetchTransactions();
  }

  Future<void> updateTransaction(FinanceTransaction transaction) async {
    final dbService = DatabaseService();
    await dbService.updateTransaction(transaction);
    await fetchTransactions();
  }
}