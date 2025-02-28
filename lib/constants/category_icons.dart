import 'package:flutter/material.dart';

class CategoryIcons {
  static const Map<String, IconData> expenseIcons = {
    'Food': Icons.fastfood,
    'Transport': Icons.directions_car,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt,
    'Shopping': Icons.shopping_bag,
    'Health': Icons.medical_services,
    'Other': Icons.more_horiz,
  };
  
  static const Map<String, IconData> incomeIcons = {
    'Salary': Icons.work,
    'Freelance': Icons.computer,
    'Investment': Icons.trending_up,
    'Gift': Icons.card_giftcard,
    'Other': Icons.more_horiz,
  };
  
  static const Map<String, Color> categoryColors = {
    'Food': Colors.orange,
    'Transport': Colors.blue,
    'Entertainment': Colors.purple,
    'Bills': Colors.yellow,
    'Shopping': Colors.pink,
    'Health': Colors.green,
    'Other': Colors.grey,
    'Salary': Colors.green,
    'Freelance': Colors.cyan,
    'Investment': Colors.indigo,
    'Gift': Colors.amber,
  };
}
