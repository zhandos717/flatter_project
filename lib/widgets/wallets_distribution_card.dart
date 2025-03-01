import 'package:finance_app/models/wallet.dart';
import 'package:finance_app/providers/wallet_provider.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:finance_app/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletsDistributionCard extends StatelessWidget {
  const WalletsDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, _) {
        final wallets = walletProvider.wallets;
        final totalBalance = walletProvider.getTotalBalance();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: wallets
                  .map((wallet) =>
                      _buildWalletDistributionItem(wallet, totalBalance))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWalletDistributionItem(Wallet wallet, double totalBalance) {
    final name = wallet.name;
    final balance = double.parse(wallet.balance.toString());
    final colorStr = wallet.color;
    final color = _parseColor(colorStr);

    // Рассчитываем процент от общей суммы
    final percent = totalBalance != 0 ? (balance / totalBalance * 100) : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                CurrencyFormatter.format(balance),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    backgroundColor: Colors.grey[200],
                    color: color,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Utility method to parse color
  Color _parseColor(String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.green; // Default color
    }
  }
}
