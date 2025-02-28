import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/providers/auth_provider.dart';
import 'package:finance_app/screens/add_transaction_screen.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:finance_app/widgets/balance_card_simple.dart';
import 'package:finance_app/widgets/recent_transactions.dart';
import 'package:finance_app/widgets/quick_action_button.dart';
import 'package:finance_app/models/finance_transaction.dart';
import 'package:finance_app/screens/bank_statement_screen.dart';
import 'package:finance_app/screens/transactions_list_screen.dart';


class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?['name'] ?? 'Пользователь';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => transactionProvider.fetchTransactions(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppTheme.paddingM),

                  // Карточка баланса
                  BalanceCardSimple(
                    balance: transactionProvider.balance,
                    income: transactionProvider.totalIncomes,
                    expense: transactionProvider.totalExpenses,
                  ),

                  SizedBox(height: AppTheme.paddingL),

                  // Быстрые действия
                  Text(
                    'Быстрые действия',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppTheme.paddingS),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        QuickActionButton(
                          icon: Icons.add_circle_outline,
                          label: 'Доход',
                          color: AppTheme.incomeColor,
                          onTap: () => _addTransaction(context, TransactionType.income),
                        ),
                        SizedBox(width: AppTheme.paddingM),
                        QuickActionButton(
                          icon: Icons.remove_circle_outline,
                          label: 'Расход',
                          color: AppTheme.expenseColor,
                          onTap: () => _addTransaction(context, TransactionType.expense),
                        ),
                        SizedBox(width: AppTheme.paddingM),
                        QuickActionButton(
                          icon: Icons.account_balance_wallet,
                          label: 'Кошельки',
                          color: AppTheme.secondaryColor,
                          onTap: () {
                            // Навигация на экран кошельков
                          },
                        ),
                        SizedBox(width: AppTheme.paddingM),
                        QuickActionButton(
                          icon: Icons.description,
                          label: 'Выписки',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => BankStatementScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppTheme.paddingL),

                  // Последние транзакции
                  Row(
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
                              builder: (ctx) => TransactionsListScreen(),
                            ),
                          );
                        },
                        child: Text('Все'),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.paddingS),

                  // Список последних транзакций
                  RecentTransactions(limit: 5),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.add),
        onPressed: () => _addTransaction(context, null),
      ),
    );
  }

  void _addTransaction(BuildContext context, TransactionType? type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddTransactionScreen(
          initialType: type,
        ),
      ),
    );
  }
}