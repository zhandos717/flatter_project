import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final int type; // 0 - расход, 1 - доход
  final int icon;
  final String color;

  static const Income = 1;
  static const Expense = 2;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  // Преобразование объекта Category в Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
    };
  }

  // Создание объекта Category из Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
      color: map['color'],
    );
  }

  // Создание копии объекта с возможностью изменения отдельных полей
  Category copyWith({
    int? id,
    String? name,
    int? type,
    int? icon,
    String? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  // Преобразование цвета из строки HEX в объект Color
  Color get colorValue {
    String hexColor = color.toUpperCase().replaceAll('#', '');

    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }

    return Color(int.parse(hexColor, radix: 16));
  }

  // Получение IconData по числовому идентификатору
  IconData get iconData {
    switch (icon) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.fastfood;
      case 2:
        return Icons.shopping_cart;
      case 3:
        return Icons.directions_car;
      case 4:
        return Icons.local_hospital;
      case 5:
        return Icons.school;
      case 6:
        return Icons.attach_money;
      case 7:
        return Icons.work;
      default:
        return Icons.category;
    }
  }
}
