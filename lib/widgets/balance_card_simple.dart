import 'package:flutter/material.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:finance_app/utils/formatters.dart';

class BalanceCardSimple extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;

  const BalanceCardSimple({
    Key? key,
    required this.balance,
    required this.income,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            horizontal: AppTheme.paddingL,
            vertical: AppTheme.paddingM
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              balance >= 0
                  ? AppTheme.primaryColor
                  : AppTheme.expenseColor,
              balance >= 0
                  ? AppTheme.primaryColor.withOpacity(0.7)
                  : AppTheme.expenseColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Текущий баланс',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Icon(
                  balance >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(height: AppTheme.paddingS),
            Text(
              CurrencyFormatter.format(balance),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppTheme.paddingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceInfoItem(
                    context,
                    'Доходы',
                    income,
                    Icons.arrow_upward
                ),
                _buildBalanceInfoItem(
                    context,
                    'Расходы',
                    expense,
                    Icons.arrow_downward
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfoItem(
      BuildContext context,
      String title,
      double amount,
      IconData icon,
      ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Icon(
            icon,
            size: 18,
            color: Colors.white,
          ),
        ),
        SizedBox(width: AppTheme.paddingS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Text(
              CurrencyFormatter.format(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}