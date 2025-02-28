import 'package:flutter/material.dart';

class IconDropdownItems {
  /// Создает список элементов выпадающего списка с иконками
  ///
  /// [context] текущий контекст для доступа к теме
  /// Возвращает список [DropdownMenuItem] с иконками и их названиями
  static List<DropdownMenuItem<int>> buildIconDropdownItems(BuildContext context) {
    // Создаем пары иконка-название
    final iconOptions = [
      {'icon': Icons.home, 'name': 'Дом', 'value': 0},
      {'icon': Icons.fastfood, 'name': 'Еда', 'value': 1},
      {'icon': Icons.shopping_cart, 'name': 'Покупки', 'value': 2},
      {'icon': Icons.directions_car, 'name': 'Транспорт', 'value': 3},
      {'icon': Icons.local_hospital, 'name': 'Здоровье', 'value': 4},
      {'icon': Icons.school, 'name': 'Образование', 'value': 5},
      {'icon': Icons.attach_money, 'name': 'Финансы', 'value': 6},
      {'icon': Icons.work, 'name': 'Работа', 'value': 7},
    ];

    return iconOptions.map((option) {
      return DropdownMenuItem<int>(
        value: option['value'] as int,
        child: Row(
          children: [
            Icon(option['icon'] as IconData),
            SizedBox(width: 10),
            Text(option['name'] as String,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }).toList();
  }

  /// Получает иконку по ее числовому идентификатору
  ///
  /// [iconId] числовой идентификатор иконки
  /// Возвращает соответствующую [IconData]
  static IconData getIconData(int iconId) {
    switch (iconId) {
      case 0: return Icons.home;
      case 1: return Icons.fastfood;
      case 2: return Icons.shopping_cart;
      case 3: return Icons.directions_car;
      case 4: return Icons.local_hospital;
      case 5: return Icons.school;
      case 6: return Icons.attach_money;
      case 7: return Icons.work;
      default: return Icons.category;
    }
  }

  /// Получает название иконки по ее числовому идентификатору
  ///
  /// [iconId] числовой идентификатор иконки
  /// Возвращает название иконки
  static String getIconName(int iconId) {
    switch (iconId) {
      case 0: return 'Дом';
      case 1: return 'Еда';
      case 2: return 'Покупки';
      case 3: return 'Транспорт';
      case 4: return 'Здоровье';
      case 5: return 'Образование';
      case 6: return 'Финансы';
      case 7: return 'Работа';
      default: return 'Категория';
    }
  }
}