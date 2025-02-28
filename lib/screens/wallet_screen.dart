import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/finance_transaction.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'add_wallet_screen.dart';
import 'transactions_list_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedWalletIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Загружаем кошельки при инициализации, если не загружены
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);

      if (walletProvider.wallets.isEmpty) {
        walletProvider.fetchWallets(1); // 1 - обычные кошельки
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text('Кошельки'),
              floating: true,
              snap: true,
              forceElevated: innerBoxIsScrolled,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.primaryColor,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(
                        icon: Icon(Icons.account_balance_wallet, size: 16),
                        text: 'Мои кошельки',
                        iconMargin: EdgeInsets.only(bottom: 2),
                      ),
                      Tab(
                        icon: Icon(Icons.bar_chart, size: 16),
                        text: 'Динамика',
                        iconMargin: EdgeInsets.only(bottom: 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildWalletsTab(),
            _buildWalletAnalyticsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddWalletDialog();
        },
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showAddWalletDialog() {
    // Это заглушка, замените на реальный переход к экрану добавления кошелька
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Новый кошелек'),
        content: Text('Здесь будет форма добавления нового кошелька'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Закрыть'),
          ),
        ],
      ),
    );

    // Раскомментируйте этот код, когда создадите экран добавления кошелька
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (ctx) => AddWalletScreen(),
    //   ),
    // );
  }

  Widget _buildWalletsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        final walletProvider = Provider.of<WalletProvider>(context, listen: false);
        await walletProvider.fetchWallets(1);
      },
      child: Consumer<WalletProvider>(
        builder: (ctx, walletProvider, _) {
          if (walletProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (walletProvider.wallets.isEmpty) {
            return _buildEmptyWalletsState();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppTheme.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Общий баланс всех кошельков
                _buildTotalBalanceCard(walletProvider),
                SizedBox(height: AppTheme.paddingL),

                // Список кошельков
                Text(
                  'Мои кошельки',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: AppTheme.paddingM),

                // Карусель кошельков
                Container(
                  height: 180,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.9),
                    itemCount: walletProvider.wallets.length,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedWalletIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final wallet = walletProvider.wallets[index];
                      return _buildWalletCard(wallet, index == _selectedWalletIndex);
                    },
                  ),
                ),

                // Индикатор страниц
                if (walletProvider.wallets.length > 1)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.paddingM),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        walletProvider.wallets.length,
                            (index) => _buildPageIndicator(index == _selectedWalletIndex),
                      ),
                    ),
                  ),

                SizedBox(height: AppTheme.paddingM),

                // Последние транзакции по кошельку
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

                // Транзакции по выбранному кошельку
                _buildWalletTransactions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildEmptyWalletsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            SizedBox(height: AppTheme.paddingM),
            Text(
              'У вас пока нет кошельков',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: AppTheme.paddingS),
            Text(
              'Добавьте свой первый кошелек, чтобы начать отслеживать финансы',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: AppTheme.paddingL),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Добавить кошелек'),
              onPressed: _showAddWalletDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(WalletProvider walletProvider) {
    final totalBalance = walletProvider.getTotalBalance();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppTheme.paddingM),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              totalBalance >= 0
                  ? AppTheme.primaryColor
                  : AppTheme.expenseColor,
              totalBalance >= 0
                  ? AppTheme.primaryColor.withOpacity(0.7)
                  : AppTheme.expenseColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Общий баланс',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            SizedBox(height: AppTheme.paddingS),
            Text(
              CurrencyFormatter.format(totalBalance),
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.paddingS),
            Text(
              'Всего кошельков: ${walletProvider.wallets.length}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(Map<String, dynamic> wallet, bool isActive) {
    final name = wallet['name'] ?? 'Кошелек';
    final balance = double.parse(wallet['balance'].toString());
    final type = wallet['type'].toString();
    // Определите цвет из ваших цветов категорий или используйте по умолчанию
    final colorStr = wallet['color'] ?? '#4CAF50';
    Color color;

    try {
      // Попытка преобразовать строку цвета в Color
      color = Color(int.parse(colorStr.replaceAll('#', '0xFF')));
    } catch (e) {
      // Используйте цвет по умолчанию в случае ошибки
      color = AppTheme.primaryColor;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        elevation: isActive ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        child: Container(
          padding: EdgeInsets.all(AppTheme.paddingM),
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
              // Название и тип кошелька
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      type == '1' ? 'Обычный' : 'Цель',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              Spacer(),

              // Баланс
              Text(
                'Баланс',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(balance),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Кнопки действий
              SizedBox(height: AppTheme.paddingS),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      // Действие для редактирования кошелька
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                  SizedBox(width: AppTheme.paddingS),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      // Действие для добавления транзакции к кошельку
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletTransactions() {
    return Consumer<TransactionProvider>(
      builder: (ctx, transactionProvider, _) {
        final transactions = transactionProvider.transactions;

        if (transactions.isEmpty) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Padding(
              padding: EdgeInsets.all(AppTheme.paddingM),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: AppTheme.paddingM),
                    Text(
                      'Нет транзакций',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: AppTheme.paddingS),
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

        // Отображаем только 5 последних транзакций
        final recentTransactions = transactions.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: recentTransactions.length,
          itemBuilder: (ctx, index) {
            final tx = recentTransactions[index];
            final isIncome = tx.type == TransactionType.income;
            final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;

            return Card(
              margin: EdgeInsets.only(bottom: AppTheme.paddingS),
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
                  style: TextStyle(
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
          },
        );
      },
    );
  }

  Widget _buildWalletAnalyticsTab() {
    return Consumer2<WalletProvider, TransactionProvider>(
      builder: (ctx, walletProvider, transactionProvider, _) {
        if (walletProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (walletProvider.wallets.isEmpty) {
          return _buildEmptyWalletsState();
        }

        final transactions = transactionProvider.transactions;

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppTheme.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Карточка с графиком баланса
              _buildBalanceChartCard(transactions),
              SizedBox(height: AppTheme.paddingL),

              // Распределение средств по кошелькам
              Text(
                'Распределение средств',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: AppTheme.paddingM),
              _buildWalletsDistributionCard(walletProvider),
              SizedBox(height: AppTheme.paddingL),

              // Статистика по транзакциям
              Text(
                'Статистика транзакций',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: AppTheme.paddingM),
              _buildTransactionsStatsCard(transactions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceChartCard(List<FinanceTransaction> transactions) {
    // Группируем транзакции по дням за последний месяц
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(Duration(days: 30));

    // Фильтруем транзакции за последний месяц
    final filteredTransactions = transactions.where(
            (tx) => tx.date.isAfter(oneMonthAgo) && tx.date.isBefore(now.add(Duration(days: 1)))
    ).toList();

    // Создаем карту для отслеживания баланса по дням
    Map<DateTime, double> dailyBalance = {};
    double runningBalance = 0; // Начальный баланс

    // Инициализируем карту нулями для каждого дня
    for (int i = 0; i <= 30; i++) {
      final date = DateTime(
          oneMonthAgo.year,
          oneMonthAgo.month,
          oneMonthAgo.day
      ).add(Duration(days: i));

      dailyBalance[date] = 0;
    }

    // Заполняем карту балансами на основе транзакций
    for (var tx in filteredTransactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final amount = tx.type == TransactionType.income ? tx.amount : -tx.amount;

      // Обновляем текущий день
      dailyBalance[date] = (dailyBalance[date] ?? 0) + amount;
    }

    // Подсчитываем совокупный баланс
    List<FlSpot> spots = [];
    List<DateTime> dates = dailyBalance.keys.toList()..sort();

    for (int i = 0; i < dates.length; i++) {
      runningBalance += dailyBalance[dates[i]] ?? 0;
      spots.add(FlSpot(i.toDouble(), runningBalance));
    }

    final minY = spots.isEmpty ? 0 : spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.isEmpty ? 0 : spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Динамика баланса',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'За последние 30 дней',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: AppTheme.paddingM),

            if (spots.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.paddingL),
                  child: Column(
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: AppTheme.paddingS),
                      Text(
                        'Недостаточно данных',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[300],
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value % 5 != 0) return Text('');

                            final index = value.toInt();
                            if (index >= 0 && index < dates.length) {
                              final date = dates[index];
                              return Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat.MMMd('ru').format(date),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            }
                            return Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Text(
                                CurrencyFormatter.formatCompact(value),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: spots.length.toDouble() - 1,
                    minY: minY < 0 ? minY * 1.1 : minY * 0.9,
                    maxY: maxY * 1.1,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppTheme.primaryColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: false,
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primaryColor.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletsDistributionCard(WalletProvider walletProvider) {
    final wallets = walletProvider.wallets;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            wallets.map((wallet) {
              final name = wallet['name'] ?? 'Кошелек';
              final balance = double.parse(wallet['balance'].toString());
              final colorStr = wallet['color'] ?? '#4CAF50';
              Color color;

              try {
                color = Color(int.parse(colorStr.replaceAll('#', '0xFF')));
              } catch (e) {
                color = AppTheme.primaryColor;
              }

              // Рассчитываем процент от общей суммы
              final totalBalance = walletProvider.getTotalBalance();
              final percent = totalBalance != 0 ? (balance / totalBalance * 100) : 0;

              return Padding(
                padding: EdgeInsets.only(bottom: AppTheme.paddingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(balance),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
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
                        SizedBox(width: 8),
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
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsStatsCard(List<FinanceTransaction> transactions) {
    // Рассчитываем статистику за последний месяц
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(Duration(days: 30));

    final monthTransactions = transactions.where(
            (tx) => tx.date.isAfter(oneMonthAgo) && tx.date.isBefore(now.add(Duration(days: 1)))
    ).toList();

    // Общие суммы
    double totalIncome = 0;
    double totalExpense = 0;

    // Количество транзакций
    int incomeCount = 0;
    int expenseCount = 0;

    // Средние суммы транзакций
    double avgIncome = 0;
    double avgExpense = 0;

    // Максимальные суммы
    double maxIncome = 0;
    double maxExpense = 0;

    // Самый активный день недели
    Map<int, int> dayOfWeekCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    for (var tx in monthTransactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
        incomeCount++;
        maxIncome = tx.amount > maxIncome ? tx.amount : maxIncome;
      } else {
        totalExpense += tx.amount;
        expenseCount++;
        maxExpense = tx.amount > maxExpense ? tx.amount : maxExpense;
      }

      // Обновляем счетчик дней недели (1 - понедельник, ... 7 - воскресенье)
      final dayOfWeek = tx.date.weekday;
      dayOfWeekCount[dayOfWeek] = (dayOfWeekCount[dayOfWeek] ?? 0) + 1;
    }

    // Вычисляем средние суммы
    avgIncome = incomeCount > 0 ? totalIncome / incomeCount : 0;
    avgExpense = expenseCount > 0 ? totalExpense / expenseCount : 0;

    // Определяем самый активный день недели
    String mostActiveDay = 'Н/Д';
    int maxCount = 0;

    dayOfWeekCount.forEach((day, count) {
      if (count > maxCount) {
        maxCount = count;
        switch (day) {
          case 1: mostActiveDay = 'Понедельник'; break;
          case 2: mostActiveDay = 'Вторник'; break;
          case 3: mostActiveDay = 'Среда'; break;
          case 4: mostActiveDay = 'Четверг'; break;
          case 5: mostActiveDay = 'Пятница'; break;
          case 6: mostActiveDay = 'Суббота'; break;
          case 7: mostActiveDay = 'Воскресенье'; break;
        }
      }
    });

    // Построение статистических блоков
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'За последние 30 дней',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: AppTheme.paddingM),

            if (monthTransactions.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.paddingM),
                  child: Column(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: AppTheme.paddingS),
                      Text(
                        'Недостаточно данных',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Суммы доходов и расходов
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Доходы',
                          value: CurrencyFormatter.format(totalIncome),
                          icon: Icons.arrow_upward,
                          color: AppTheme.incomeColor,
                        ),
                      ),
                      SizedBox(width: AppTheme.paddingM),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Расходы',
                          value: CurrencyFormatter.format(totalExpense),
                          icon: Icons.arrow_downward,
                          color: AppTheme.expenseColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.paddingM),

                  // Количество транзакций
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Транзакций',
                          value: (incomeCount + expenseCount).toString(),
                          icon: Icons.receipt_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: AppTheme.paddingM),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Активный день',
                          value: mostActiveDay,
                          icon: Icons.calendar_today,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.paddingM),

                  // Средние суммы
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Средний доход',
                          value: CurrencyFormatter.format(avgIncome),
                          icon: Icons.trending_up,
                          color: AppTheme.incomeColor,
                        ),
                      ),
                      SizedBox(width: AppTheme.paddingM),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Средний расход',
                          value: CurrencyFormatter.format(avgExpense),
                          icon: Icons.trending_down,
                          color: AppTheme.expenseColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTheme.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}