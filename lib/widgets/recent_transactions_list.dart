import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../models/finance_transaction.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (ctx, transactionProvider, _) {
        final transactions = transactionProvider.transactions;

        if (transactions.isEmpty) {
          return _buildEmptyTransactionsState();
        }

        // Отображаем только 5 последних транзакций
        final recentTransactions = transactions.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentTransactions.length,
          itemBuilder: (ctx, index) =>
              _buildTransactionItem(recentTransactions[index]),
        );
      },
    );
  }

  Widget _buildEmptyTransactionsState() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingM),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey[300],
              ),
              const SizedBox(height: AppTheme.paddingM),
              Text(
                'Нет транзакций',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: AppTheme.paddingS),
              Text(
                'Добавьте транзакцию, чтобы отслеживать движение средств',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(FinanceTransaction tx) {
    final isIncome = tx.type == TransactionType.income;
    final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingS),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          tx.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          DateFormat.yMMMd('ru').format(tx.date),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          (isIncome ? '+ ' : '- ') + CurrencyFormatter.format(tx.amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}