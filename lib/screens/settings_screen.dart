import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/providers/settings_provider.dart'; // Предположим, что у вас есть такой провайдер

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Темная тема'),
            trailing: Switch(
              value: settingsProvider.isDarkMode,
              onChanged: (value) {
                settingsProvider.toggleDarkMode(value);
              },
            ),
          ),
          ListTile(
            title: const Text('Уведомления'),
            trailing: Switch(
              value: settingsProvider.areNotificationsEnabled,
              onChanged: (value) {
                settingsProvider.toggleNotifications(value);
              },
            ),
          ),
          ListTile(
            title: const Text('Язык'),
            subtitle: const Text('Выберите предпочитаемый язык'),
            onTap: () {
              // Открыть диалог выбора языка
              _showLanguageDialog(context, settingsProvider);
            },
          ),
          // Добавьте другие настройки по мере необходимости
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Выберите язык'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Русский'),
                onTap: () {
                  settingsProvider.changeLanguage('ru');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () {
                  settingsProvider.changeLanguage('en');
                  Navigator.of(context).pop();
                },
              ),
              // Добавьте другие языки по мере необходимости
            ],
          ),
        );
      },
    );
  }
}
