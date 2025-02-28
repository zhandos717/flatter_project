import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/wallet_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';

class WalletCarousel extends StatelessWidget {
  const WalletCarousel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, _) {
        return SizedBox(
          height: 180,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: walletProvider.wallets.length,
            onPageChanged: (index) {
              walletProvider.setSelectedWalletIndex(index);
            },
            itemBuilder: (context, index) {
              final wallet = walletProvider.wallets[index];
              return _buildWalletCard(
                  context,
                  wallet,
                  index == walletProvider.selectedWalletIndex
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWalletCard(
      BuildContext context,
      Map<String, dynamic> wallet,
      bool isActive
      ) {
    final name = wallet['name'] ?? 'Кошелек';
    final balance = double.parse(wallet['balance'].toString());
    final type = wallet['type'].toString();
    final colorStr = wallet['color'] ?? '#4CAF50';
    final color = _parseColor(colorStr);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        elevation: isActive ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.paddingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWalletCardHeader(name, type),
              const Spacer(),
              _buildWalletCardBalance(balance),
              const SizedBox(height: AppTheme.paddingS),
              _buildWalletCardActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCardHeader(String name, String type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingS,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            type == '1' ? 'Обычный' : 'Цель',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCardBalance(double balance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Баланс',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(balance),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCardActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(
            Icons.edit_outlined,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            // TODO: Implement wallet edit functionality
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: AppTheme.paddingS),
        IconButton(
          icon: const Icon(
            Icons.add_circle_outline,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            // TODO: Implement add transaction functionality
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
        ),
      ],
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