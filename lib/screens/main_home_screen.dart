import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/providers/wallet_provider.dart';
import 'package:finance_app/widgets/chart.dart';
import 'package:finance_app/widgets/transaction_list.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFinancialSummaryCard(transactionProvider),
            Chart(),
            TransactionList(),
          ],
        ),
      ),
    );
  }

  // Build Financial Summary Card with Income, Expense, and Balance
  Widget _buildFinancialSummaryCard(TransactionProvider transactionProvider) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              'Доходы',
              transactionProvider.totalIncomes,
              Colors.green,
            ),
            _buildSummaryItem(
              'Расходы',
              transactionProvider.totalExpenses,
              Colors.red,
            ),
            _buildSummaryItem(
              'Баланс',
              transactionProvider.balance,
              transactionProvider.balance >= 0 ? Colors.blue : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
