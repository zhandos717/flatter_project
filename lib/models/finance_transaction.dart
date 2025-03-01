import 'package:finance_app/models/category.dart';

class FinanceTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final int? walletId;
  final Category category;
  final TransactionType type;
  final String? note;

  FinanceTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.walletId,
    required this.date,
    required this.category,
    required this.type,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type == TransactionType.income ? '1' : '2',
      'note': note,
    };
  }

  factory FinanceTransaction.fromMap(Map<String, dynamic> map) {
    return FinanceTransaction(
        id: map['id'].toString(),
        title: map['title'] ?? map['name'] ?? '',
        amount: map['amount'] is int
            ? map['amount'].toDouble()
            : double.parse(map['amount'].toString()),
        date: DateTime.parse(map['date']),
        category: map['category'] is Map
            ? map['category']['name'] ?? 'Без категории'
            : map['category'] ?? 'Без категории',
        type: map['type'] == '1' ||
                map['type'] == 1 ||
                map['type_def'] == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        note: map['note'] ?? map['comment'],
        walletId: map['wallet_id']);
  }
}

enum TransactionType { income, expense }
