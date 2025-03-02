import 'package:finance_app/models/wallet.dart';
import 'package:finance_app/providers/wallet_provider.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:finance_app/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletCarousel extends StatelessWidget {
  const WalletCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, _) {
        if (walletProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (walletProvider.wallets.isEmpty) {
          return _buildEmptyWalletState();
        }

        return SizedBox(
          height: 180,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: walletProvider.wallets.length,
            onPageChanged: walletProvider.setSelectedWalletIndex,
            itemBuilder: (context, index) {
              final wallet = walletProvider.wallets[index];
              return WalletCard(
                wallet: wallet,
                isActive: index == walletProvider.selectedWalletIndex,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyWalletState() {
    return const SizedBox(
      height: 180,
      child: Card(
        child: Center(
          child: Text('У вас пока нет кошельков'),
        ),
      ),
    );
  }
}

class WalletCard extends StatelessWidget {
  final Wallet wallet;
  final bool isActive;

  const WalletCard({
    Key? key,
    required this.wallet,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(wallet.color ?? '#4CAF50');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
              _buildHeader(),
              const Spacer(),
              _buildBalance(),
              const SizedBox(height: AppTheme.paddingS),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final name = wallet.name.isNotEmpty ? wallet.name : 'Кошелек';
    final type = wallet.type;

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
            type == Wallet.OrdinaryType ? 'Обычный' : 'Цель',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalance() {
    final balance = wallet.balanceAsDouble;

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
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildActionButton(
          icon: Icons.edit_outlined,
          onPressed: () => _onEditWallet(context),
        ),
        const SizedBox(width: AppTheme.paddingS),
        _buildActionButton(
          icon: Icons.add_circle_outline,
          onPressed: () => _onAddTransaction(context),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
    );
  }

  void _onEditWallet(BuildContext context) {
    // TODO: Implement wallet edit functionality
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => EditWalletScreen(wallet: wallet),
    //   ),
    // );
  }

  void _onAddTransaction(BuildContext context) {
    // TODO: Implement add transaction functionality
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => AddTransactionScreen(initialWalletId: wallet.id),
    //   ),
    // );
  }

  // Utility method to parse color
  Color _parseColor(String colorStr) {
    try {
      if (colorStr.startsWith('#')) {
        return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
      } else if (colorStr.startsWith('0x')) {
        return Color(int.parse(colorStr));
      }
      return Color(int.parse('0xFF$colorStr'));
    } catch (e) {
      return Colors.green; // Default color
    }
  }
}
