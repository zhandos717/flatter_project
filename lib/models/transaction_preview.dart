// models/transaction_preview.dart

class TransactionPreview {
  final String date;
  final int amount;
  final String name;
  final int type;
  final String source;
  bool selected; // Для выбора транзакций для импорта

  TransactionPreview({
    required this.date,
    required this.amount,
    required this.name,
    required this.type,
    required this.source,
    this.selected = true, // По умолчанию все транзакции выбраны
  });

  // Создание объекта из JSON
  factory TransactionPreview.fromJson(Map<String, dynamic> json) {
    return TransactionPreview(
      date: json['date'] as String,
      amount: double.parse(json['amount'].toString()).toInt(),
      name: json['name'] as String,
      type: json['type'] as int,
      source: json['source'] as String,
    );
  }

  // Преобразование объекта в JSON
  Map<String, dynamic> toJson() {
    String formattedDate = date;
    try {
      final dateTime = DateTime.parse(date);
      formattedDate =
          '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Ошибка преобразования даты: $e');
    }

    return {
      'date': formattedDate, // Вот здесь нужно использовать formattedDate
      'amount': amount,
      'name': name,
      'type': type,
      'source': source,
    };
  }
}

// Класс для хранения предпросмотра выписки
class StatementPreview {
  final List<TransactionPreview> transactions;
  String? filePath;
  String? fileName;

  StatementPreview({
    required this.transactions,
    this.filePath,
    this.fileName,
  });

  // Получение только выбранных транзакций
  List<TransactionPreview> get selectedTransactions {
    return transactions.where((transaction) => transaction.selected).toList();
  }
}
