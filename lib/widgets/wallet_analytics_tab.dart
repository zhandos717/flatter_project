import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../models/finance_transaction.dart';

import 'balance_chart_card.dart';
import 'wallets_distribution_card.dart';
import 'transactions_stats_card.dart';

class WalletAnalyticsTab extends StatelessWidget {
  const WalletAnalyticsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<WalletProvider, TransactionProvider>(
      builder: (ctx, walletProvider, transactionProvider, _) {
        if (walletProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (walletProvider.wallets.isEmpty) {
          return _buildEmptyWalletsState(context);
        }

        final transactions = transactionProvider.transactions;

        return _buildAnalyticsContent(context, walletProvider, transactions);
      },
    );
  }

  Widget _buildAnalyticsContent(
      BuildContext context,
      WalletProvider walletProvider,
      List<FinanceTransaction> transactions
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceChartSection(context, transactions),
          const SizedBox(height: AppTheme.paddingL),
          _buildWalletsDistributionSection(context, walletProvider),
          const SizedBox(height: AppTheme.paddingL),
          _buildTransactionsStatsSection(context, transactions),
        ],
      ),
    );
  }

  Widget _buildBalanceChartSection(
      BuildContext context,
      List<FinanceTransaction> transactions
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Динамика баланса',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.paddingM),
        BalanceChartCard(transactions: transactions),
      ],
    );
  }

  Widget _buildWalletsDistributionSection(
      BuildContext context,
      WalletProvider walletProvider
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Распределение средств',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.paddingM),
        const WalletsDistributionCard(),
      ],
    );
  }

  Widget _buildTransactionsStatsSection(
      BuildContext context,
      List<FinanceTransaction> transactions
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Статистика транзакций',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.paddingM),
        //TransactionsStatsCard(transactions: transactions),
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
              Icons.show_chart_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: AppTheme.paddingM),
            Text(
              'Недостаточно данных',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppTheme.paddingS),
            Text(
              'Добавьте кошельки и транзакции для отображения аналитики',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Utility classes for chart and stats calculations
class ChartData {
  final List<FlSpot> spots;
  final List<DateTime> dates;
  final double minY;
  final double maxY;

  ChartData({
    required this.spots,
    required this.dates,
    required this.minY,
    required this.maxY,
  });
}

class TransactionStats {
  final double totalIncome;
  final double totalExpense;
  final int totalTransactions;
  final String mostActiveDay;
  final double avgIncome;
  final double avgExpense;
  final bool isEmpty;

  TransactionStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalTransactions,
    required this.mostActiveDay,
    required this.avgIncome,
    required this.avgExpense,
    this.isEmpty = false,
  });

  factory TransactionStats.empty() {
    return TransactionStats(
      totalIncome: 0,
      totalExpense: 0,
      totalTransactions: 0,
      mostActiveDay: 'Н/Д',
      avgIncome: 0,
      avgExpense: 0,
      isEmpty: true,
    );
  }
}