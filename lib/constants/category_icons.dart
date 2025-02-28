import 'package:flutter/material.dart';

// Обновите константы в файле lib/constants/category_icons.dart

class CategoryIcons {
  static const Map<String, IconData> expenseIcons = {
    'Еда': Icons.fastfood,
    'Транспорт': Icons.directions_car,
    'Развлечения': Icons.movie,
    'Счета': Icons.receipt,
    'Покупки': Icons.shopping_bag,
    'Здоровье': Icons.medical_services,
    'Другое': Icons.more_horiz,
  };

  static const Map<String, IconData> incomeIcons = {
    'Зарплата': Icons.work,
    'Фриланс': Icons.computer,
    'Инвестиции': Icons.trending_up,
    'Подарки': Icons.card_giftcard,
    'Другое': Icons.more_horiz,
  };

  static const Map<String, Color> categoryColors = {
    'Еда': Colors.orange,
    'Транспорт': Colors.blue,
    'Развлечения': Colors.purple,
    'Счета': Colors.yellow,
    'Покупки': Colors.pink,
    'Здоровье': Colors.green,
    'Другое': Colors.grey,
    'Зарплата': Colors.green,
    'Фриланс': Colors.cyan,
    'Инвестиции': Colors.indigo,
    'Подарки': Colors.amber,
  };
}