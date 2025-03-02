import 'package:finance_app/models/category.dart';

class FinanceTransaction {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final int? walletId;
  final Category category;
  final TransactionType type;
  final String? note;
  final DateTime? createdAt;
  final Map<String, dynamic>? wallet;

  FinanceTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.walletId,
    this.note,
    this.createdAt,
    this.wallet,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.toMap(),
      'type': type == TransactionType.income ? 1 : 2,
      'type_def': type == TransactionType.income ? 'Доход' : 'Расход',
      'comment': note,
      'wallet_id': walletId,
      'created_at': createdAt?.toIso8601String(),
      'wallet': wallet,
    };
  }

  factory FinanceTransaction.fromMap(Map<String, dynamic> map) {
    return FinanceTransaction(
      id: map['id'],
      title: map['name'] ?? '',
      amount: map['amount'] is int
          ? map['amount'].toDouble()
          : double.parse(map['amount'].toString()),
      date: DateTime.parse(map['date']),
      category: map['category'] is Map
          ? Category.fromMap(map['category'])
          : Category.fromMap({'name': 'Без категории'}),
      type: map['type'] == 1 || map['type_def'] == 'Доход'
          ? TransactionType.income
          : TransactionType.expense,
      note: map['comment'],
      walletId: map['wallet_id'] ?? map['wallet']?['id'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      wallet: map['wallet'] is Map
          ? Map<String, dynamic>.from(map['wallet'])
          : null,
    );
  }
}

enum TransactionType { income, expense }
