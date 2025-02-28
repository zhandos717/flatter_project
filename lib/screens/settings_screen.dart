import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/providers/auth_provider.dart';
import 'package:finance_app/screens/profile_edit_screen.dart';

import '../providers/settings_provider.dart';
import '../utils/formatters.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      body: ListView(
        children: [
          // Профиль пользователя
          if (authProvider.isAuthenticated && authProvider.user != null)
            _buildProfileCard(context, authProvider),

          SizedBox(height: 16),

          // Настройки приложения
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Настройки приложения',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Divider(height: 1),

                // Тёмная тема
                SwitchListTile(
                  title: Text('Тёмная тема'),
                  subtitle: Text('Переключение между светлой и тёмной темой'),
                  secondary: Icon(Icons.dark_mode),
                  value: settingsProvider.isDarkMode,
                  // Заглушка, добавьте интеграцию с настоящим провайдером темы
                  onChanged: (value) {
                    settingsProvider.toggleDarkMode(value);
                  },
                ),

                // Уведомления
                SwitchListTile(
                  title: Text('Уведомления'),
                  subtitle: Text('Включить push-уведомления'),
                  secondary: Icon(Icons.notifications),
                  value: settingsProvider.areNotificationsEnabled,
                  // Заглушка
                  onChanged: (value) {
                    settingsProvider.toggleNotifications(value);
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Информация о приложении
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'О приложении',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Версия'),
                  subtitle: Text('1.0.0'),
                  leading: Icon(Icons.info_outline),
                ),
                ListTile(
                  title: Text('Политика конфиденциальности'),
                  leading: Icon(Icons.privacy_tip_outlined),
                  onTap: () {
                    // Открыть политику конфиденциальности
                  },
                ),
                ListTile(
                  title: Text('Условия использования'),
                  leading: Icon(Icons.description_outlined),
                  onTap: () {
                    // Открыть условия использования
                  },
                ),
                ListTile(
                  title: Text('Обратная связь'),
                  leading: Icon(Icons.feedback_outlined),
                  onTap: () {
                    // Отправить обратную связь
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Кнопка выхода
          if (authProvider.isAuthenticated)
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  bool confirm = await _showLogoutConfirmationDialog(context);
                  if (confirm) {
                    await authProvider.logout();
                    // Перенаправление на экран входа может быть здесь
                  }
                },
                icon: Icon(Icons.exit_to_app),
                label: Text('Выйти из аккаунта'),
              ),
            ),

          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user!;

    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Профиль',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: user['avatar_url'] != null
                      ? NetworkImage(user['avatar_url'])
                      : null,
                  child: user['avatar_url'] == null
                      ? Icon(Icons.person, size: 36, color: Colors.grey)
                      : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? 'Пользователь',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (user['middle_name'] != null &&
                          user['middle_name'].isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          user['middle_name'],
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                      SizedBox(height: 4),
                      Text(
                        user['email'] ?? 'Нет email',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (user['phone'] != null) ...[
                        SizedBox(height: 4),
                        Text(
                          user['phone'],
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          ListTile(
            title: Text('Редактировать профиль'),
            leading: Icon(Icons.edit),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileEditScreen(),
                ),
              );
            },
          ),
          if (user['month_limit'] != null || user['day_limit'] != null) ...[
            Divider(height: 1),
            ListTile(
              title: Text('Месячный лимит'),
              subtitle: Text(user['month_limit'] != null
                  ? CurrencyFormatter.format(user['month_limit'])
                  : 'Не установлен'),
              leading: Icon(Icons.calendar_month),
            ),
            ListTile(
              title: Text('Дневной лимит'),
              subtitle: Text(user['day_limit'] != null
                  ? CurrencyFormatter.format(user['day_limit'])
                  : 'Не установлен'),
              leading: Icon(Icons.today),
            ),
          ],
        ],
      ),
    );
  }

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Выход из аккаунта'),
            content: Text('Вы действительно хотите выйти из аккаунта?'),
            actions: [
              TextButton(
                child: Text('Отмена'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Выйти'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }
}
