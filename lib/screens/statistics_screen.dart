import 'package:finance_app/constants/category_icons.dart';
import 'package:finance_app/models/finance_transaction.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:finance_app/utils/formatters.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _timeRange = 'month'; // 'week', 'month', 'year'
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Установка начальных дат в зависимости от выбранного диапазона
    _updateDateRange(_timeRange);

    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateDateRange(String timeRange) {
    final now = DateTime.now();

    setState(() {
      _timeRange = timeRange;

      switch (timeRange) {
        case 'week':
          _startDate = now.subtract(Duration(days: 7));
          _endDate = now;
          break;
        case 'month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = now;
          break;
        case 'custom':
          // Дата уже установлена через диалог выбора даты
          break;
      }
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _timeRange = 'custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          NestedScrollView(headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            floating: true,
            snap: true,
            forceElevated: innerBoxIsScrolled,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(18),
              child: Container(
                color: Theme.of(context).cardColor,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: _tabController.index == 0
                      ? AppTheme.expenseColor
                      : AppTheme.incomeColor,
                  labelColor: _tabController.index == 0
                      ? AppTheme.expenseColor
                      : AppTheme.incomeColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.arrow_downward, size: 16),
                      text: 'Расходы',
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                    Tab(
                      icon: Icon(Icons.arrow_upward, size: 16),
                      text: 'Доходы',
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      }, body: SingleChildScrollView(
        child: Consumer<TransactionProvider>(
          builder: (ctx, txProvider, _) {
            bool showExpenses = _tabController.index == 0;
            List<FinanceTransaction> transactions =
                showExpenses ? txProvider.expenses : txProvider.incomes;

            // Фильтруем транзакции по выбранному временному диапазону
            transactions = transactions
                .where((tx) =>
                    tx.date.isAfter(_startDate.subtract(Duration(days: 1))) &&
                    tx.date.isBefore(_endDate.add(Duration(days: 1))))
                .toList();

            // Группируем транзакции по категориям
            Map<String, double> categoryAmounts = {};
            for (var tx in transactions) {
              categoryAmounts.update(
                  tx.category.name, (value) => value + tx.amount,
                  ifAbsent: () => tx.amount);
            }

            // Сортируем категории по сумме
            var sortedCategories = categoryAmounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            // Рассчитываем общую сумму
            double totalAmount =
                transactions.fold(0, (sum, tx) => sum + tx.amount);

            return Padding(
              padding: const EdgeInsets.all(AppTheme.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Временной диапазон и информация о периоде
                  _buildTimeRangeSelector(),
                  SizedBox(height: AppTheme.paddingM),

                  // Карточка с суммой
                  _buildTotalAmountCard(totalAmount, showExpenses),
                  SizedBox(height: AppTheme.paddingL),

                  // Диаграмма распределения, если есть данные
                  if (transactions.isNotEmpty) ...[
                    Text(
                      'Распределение по категориям',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: AppTheme.paddingM),
                    _buildCategoryChart(
                        sortedCategories, totalAmount, showExpenses),
                    SizedBox(height: AppTheme.paddingL),
                  ],

                  // Список категорий
                  Text(
                    'Детализация',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppTheme.paddingM),

                  // Если данных нет, показываем пустое состояние
                  if (transactions.isEmpty)
                    _buildEmptyState(showExpenses)
                  else
                    Expanded(
                      child: _buildCategoryList(
                          sortedCategories, totalAmount, showExpenses),
                    ),
                ],
              ),
            );
          },
        ),
      )),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingS),
        child: Column(
          children: [
            // Кнопки быстрого выбора диапазона
            Row(
              children: [
                _buildTimeRangeButton('Неделя', 'week'),
                SizedBox(width: AppTheme.paddingS),
                _buildTimeRangeButton('Месяц', 'month'),
                SizedBox(width: AppTheme.paddingS),
                _buildTimeRangeButton('Год', 'year'),
                SizedBox(width: AppTheme.paddingS),
                // Кнопка выбора произвольного диапазона
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectDateRange,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(
                        color: _timeRange == 'custom'
                            ? AppTheme.primaryColor
                            : Colors.grey[300]!,
                      ),
                      backgroundColor: _timeRange == 'custom'
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Text(
                      'Свой',
                      style: TextStyle(
                        color: _timeRange == 'custom'
                            ? AppTheme.primaryColor
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Отображение выбранного диапазона дат
            Padding(
              padding: EdgeInsets.only(top: AppTheme.paddingS),
              child: Text(
                _timeRange == 'custom'
                    ? '${DateFormat('dd MMM yyyy', 'ru').format(_startDate)} - ${DateFormat('dd MMM yyyy', 'ru').format(_endDate)}'
                    : _getTimeRangeText(),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeRangeText() {
    switch (_timeRange) {
      case 'week':
        return 'Последние 7 дней';
      case 'month':
        return 'Текущий месяц';
      case 'year':
        return 'Текущий год';
      default:
        return '';
    }
  }

  Widget _buildTimeRangeButton(String title, String range) {
    final isSelected = _timeRange == range;

    return Expanded(
      child: ElevatedButton(
        onPressed: () => _updateDateRange(range),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 8),
          backgroundColor:
              isSelected ? AppTheme.primaryColor : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.grey[800],
          elevation: 0,
        ),
        child: Text(title),
      ),
    );
  }

  Widget _buildTotalAmountCard(double totalAmount, bool isExpense) {
    final color = isExpense ? AppTheme.expenseColor : AppTheme.incomeColor;
    final icon = isExpense ? Icons.arrow_downward : Icons.arrow_upward;
    final title = isExpense ? 'Общие расходы' : 'Общие доходы';

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
              color,
              color.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: AppTheme.paddingS),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.paddingS),
            Text(
              CurrencyFormatter.format(totalAmount),
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(List<MapEntry<String, double>> categories,
      double totalAmount, bool isExpense) {
    // Если категорий слишком много, показываем только топ-5 и группируем остальные
    List<MapEntry<String, double>> displayCategories = [];
    double otherAmount = 0;

    if (categories.length > 5) {
      displayCategories = categories.take(5).toList();
      otherAmount = categories.skip(5).fold(0, (sum, item) => sum + item.value);

      if (otherAmount > 0) {
        displayCategories.add(MapEntry('Другое', otherAmount));
      }
    } else {
      displayCategories = categories;
    }

    // Генерируем секции для пирога
    List<PieChartSectionData> sections = [];

    for (var entry in displayCategories) {
      final category = entry.key;
      final amount = entry.value;
      final percent = totalAmount > 0 ? (amount / totalAmount * 100) : 0;

      Color color;
      if (category == 'Другое') {
        color = Colors.grey;
      } else {
        final categoryColor = CategoryIcons.categoryColors[category];
        color = categoryColor ?? Colors.grey;
      }

      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: '${percent.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.6,
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          children: [
            // График
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  // Пирог занимает 70% ширины
                  Expanded(
                    flex: 7,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        startDegreeOffset: -90,
                      ),
                    ),
                  ),
                  // Легенда занимает 30% ширины
                  Expanded(
                    flex: 3,
                    child: _buildLegend(displayCategories, totalAmount),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(
    List<MapEntry<String, double>> categories,
    double totalAmount,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: categories.map((entry) {
          final category = entry.key;
          final amount = entry.value;
          final percent = totalAmount > 0 ? (amount / totalAmount * 100) : 0;

          Color color;
          if (category == 'Другое') {
            color = Colors.grey;
          } else {
            final categoryColor = CategoryIcons.categoryColors[category];
            color = categoryColor ?? Colors.grey;
          }

          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryList(List<MapEntry<String, double>> categories,
      double totalAmount, bool isExpense) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index].key;
        final amount = categories[index].value;
        final percent = totalAmount > 0 ? (amount / totalAmount * 100) : 0;

        final icon = isExpense
            ? CategoryIcons.expenseIcons[category]
            : CategoryIcons.incomeIcons[category];
        final color = CategoryIcons.categoryColors[category] ?? Colors.grey;

        return Card(
          margin: EdgeInsets.only(bottom: AppTheme.paddingS),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.paddingM),
            child: Row(
              children: [
                // Иконка категории
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(
                    icon ?? Icons.category,
                    color: color,
                    size: 18,
                  ),
                ),
                SizedBox(width: AppTheme.paddingM),

                // Название категории и процент
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      // Индикатор прогресса
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          backgroundColor: Colors.grey[200],
                          color: color,
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppTheme.paddingM),

                // Сумма и процент
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isExpense) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppTheme.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpense ? Icons.show_chart : Icons.bar_chart,
              size: 64,
              color: Colors.grey[300],
            ),
            SizedBox(height: AppTheme.paddingM),
            Text(
              isExpense ? 'Нет данных о расходах' : 'Нет данных о доходах',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: AppTheme.paddingS),
            Text(
              isExpense
                  ? 'Добавьте свои первые расходы, чтобы увидеть статистику'
                  : 'Добавьте свои первые доходы, чтобы увидеть статистику',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: AppTheme.paddingL),
          ],
        ),
      ),
    );
  }
}
