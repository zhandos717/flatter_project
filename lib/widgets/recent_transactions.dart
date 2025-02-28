import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:finance_app/models/finance_transaction.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/constants/category_icons.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:finance_app/utils/formatters.dart';
import 'package:finance_app/screens/add_transaction_screen.dart';

class RecentTransactions extends StatelessWidget {
  final int limit;

  const RecentTransactions({
    Key? key,
    this.limit = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (ctx, txProvider, _) {
        if (txProvider.transactions.isEmpty) {
          return _buildEmptyState(context);
        }

        // Берем только последние транзакции согласно лимиту
        final transactions = txProvider.transactions
            .take(limit)
            .toList();

        return Column(
          children: transactions.map((tx) => _buildTransactionItem(context, tx)).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppTheme.paddingL),
        child: Column(
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: AppTheme.paddingM),
            Text(
              'Пока нет транзакций',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: AppTheme.paddingS),
            Text(
              'Добавьте свою первую транзакцию',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, FinanceTransaction tx) {
    final isIncome = tx.type == TransactionType.income;
    final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
    final icon = isIncome
        ? CategoryIcons.incomeIcons[tx.category] ?? Icons.arrow_upward
        : CategoryIcons.expenseIcons[tx.category] ?? Icons.arrow_downward;

    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.paddingS),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => AddTransactionScreen(
                transaction: tx,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(AppTheme.paddingM),
          child: Row(
            children: [
              // Иконка категории
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              SizedBox(width: AppTheme.paddingM),

              // Информация о транзакции
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          tx.category,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          DateFormat.yMMMd().format(tx.date),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Сумма
              Text(
                (isIncome ? '+ ' : '- ') + CurrencyFormatter.format(tx.amount),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}