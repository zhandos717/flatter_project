import 'package:flutter/material.dart';
import 'package:finance_app/widgets/balance_card.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (ctx, txProvider, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BalanceCard(
                  balance: txProvider.balance,
                  income: txProvider.totalIncomes,
                  expense: txProvider.totalExpenses,
                ),
                SizedBox(height: 20),
                Text(
                  'Account Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        context,
                        'Currency',
                        'USD (\$)',
                        Icons.currency_exchange,
                        () {
                          // Currency settings
                        },
                      ),
                      Divider(),
                      _buildSettingsItem(
                        context,
                        'Notifications',
                        'On',
                        Icons.notifications,
                        () {
                          // Notification settings
                        },
                      ),
                      Divider(),
                      _buildSettingsItem(
                        context,
                        'Export Data',
                        '',
                        Icons.file_download,
                        () {
                          // Export data functionality
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        context,
                        'Version',
                        '1.0.0',
                        Icons.info,
                        null,
                      ),
                      Divider(),
                      _buildSettingsItem(
                        context,
                        'Privacy Policy',
                        '',
                        Icons.privacy_tip,
                        () {
                          // Show privacy policy
                        },
                      ),
                      Divider(),
                      _buildSettingsItem(
                        context,
                        'Terms of Service',
                        '',
                        Icons.description,
                        () {
                          // Show terms of service
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Function()? onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: onTap != null ? Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}
