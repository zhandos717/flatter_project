import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallet_provider.dart';
import '../theme/app_theme.dart';

import '../screens/transactions_list_screen.dart';
import 'total_balance_card.dart';
import 'wallet_carousel.dart';
import 'recent_transactions_list.dart';

class WalletTab extends StatelessWidget {
  const WalletTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (ctx, walletProvider, _) {
        if (walletProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (walletProvider.wallets.isEmpty) {
          return _buildEmptyWalletsState(context);
        }

        return _buildWalletsContent(context, walletProvider);
      },
    );
  }

  Widget _buildWalletsContent(
      BuildContext context, WalletProvider walletProvider) {
    return RefreshIndicator(
      onRefresh: () => walletProvider.fetchWallets(1),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TotalBalanceCard(),
            const SizedBox(height: AppTheme.paddingL),
            _buildWalletsSection(context, walletProvider),
            const SizedBox(height: AppTheme.paddingM),
            _buildRecentTransactionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletsSection(
      BuildContext context, WalletProvider walletProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Мои кошельки',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.paddingM),
        const WalletCarousel(),
        if (walletProvider.wallets.length > 1)
          _buildPageIndicators(context, walletProvider.wallets.length),
      ],
    );
  }

  Widget _buildPageIndicators(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (index) => _buildPageIndicator(
              context,
              Provider.of<WalletProvider>(context).selectedWalletIndex == index),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildRecentTransactionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecentTransactionsHeader(context),
        const SizedBox(height: AppTheme.paddingS),
        const RecentTransactionsList(),
      ],
    );
  }

  Widget _buildRecentTransactionsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Последние транзакции',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const TransactionsListScreen(),
              ),
            );
          },
          child: const Text('Все'),
        ),
      ],
    );
  }

  Widget _buildEmptyWalletsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: AppTheme.paddingM),
            Text(
              'У вас пока нет кошельков',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppTheme.paddingS),
            Text(
              'Добавьте свой первый кошелек, чтобы начать отслеживать финансы',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: AppTheme.paddingL),
          ],
        ),
      ),
    );
  }
}
