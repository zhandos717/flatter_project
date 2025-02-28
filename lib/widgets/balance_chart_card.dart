import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/finance_transaction.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class BalanceChartCard extends StatelessWidget {
  final List<FinanceTransaction> transactions;

  const BalanceChartCard({
    Key? key,
    required this.transactions
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
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
            const SizedBox(height: AppTheme.paddingM),
            _buildChartContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent() {
    final chartData = _prepareBalanceChartData(transactions);

    return chartData.spots.isEmpty
        ? _buildEmptyChartState()
        : _buildBalanceChart(chartData);
  }

  Widget _buildEmptyChartState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingL),
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: AppTheme.paddingS),
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
    );
  }

  Widget _buildBalanceChart(ChartData chartData) {
    return SizedBox(
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
          titlesData: _buildChartTitles(chartData),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: chartData.spots.length.toDouble() - 1,
          minY: chartData.minY,
          maxY: chartData.maxY,
          lineBarsData: [
            LineChartBarData(
              spots: chartData.spots,
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(
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
    );
  }

  FlTitlesData _buildChartTitles(ChartData chartData) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            if (value % 5 != 0) return const Text('');

            final index = value.toInt();
            if (index >= 0 && index < chartData.dates.length) {
              final date = chartData.dates[index];
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat.MMMd('ru').format(date),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
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
    );
  }

  ChartData _prepareBalanceChartData(List<FinanceTransaction> transactions) {
    // Определяем период времени
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(const Duration(days: 30));

    // Фильтруем транзакции за последний месяц
    final filteredTransactions = transactions.where(
            (tx) =>
        tx.date.isAfter(oneMonthAgo) &&
            tx.date.isBefore(now.add(const Duration(days: 1)))
    ).toList();

    // Создаем карту для отслеживания баланса по дням
    Map<DateTime, double> dailyBalance = {};
    double runningBalance = 0;

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
    List<DateTime> dates = dailyBalance.keys.toList()
      ..sort();

    for (int i = 0; i < dates.length; i++) {
      runningBalance += dailyBalance[dates[i]] ?? 0;
      spots.add(FlSpot(i.toDouble(), runningBalance));
    }

    final minY = spots.isEmpty ? 0 : spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.isEmpty ? 0 : spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    return ChartData(
      spots: spots,
      dates: dates,
      minY: minY < 0 ? minY * 1.1 : minY * 0.9,
      maxY: maxY * 1.1,
    );
  }
}

// Utility class for chart data
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