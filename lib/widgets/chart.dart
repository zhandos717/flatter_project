import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_app/models/finance_transaction.dart';
import 'package:finance_app/providers/transaction_provider.dart';

class Chart extends StatelessWidget {
  List<Map<String, dynamic>> _groupTransactionsByDay(
      List<FinanceTransaction> recentTransactions) {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(
        Duration(days: index),
      );

      double totalExpense = 0.0;
      double totalIncome = 0.0;

      for (var tx in recentTransactions) {
        if (tx.date.day == weekDay.day &&
            tx.date.month == weekDay.month &&
            tx.date.year == weekDay.year) {
          if (tx.type == TransactionType.expense) {
            totalExpense += tx.amount;
          } else {
            totalIncome += tx.amount;
          }
        }
      }

      return {
        'day': DateFormat.E().format(weekDay).substring(0, 1),
        'expense': totalExpense,
        'income': totalIncome,
      };
    }).reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (ctx, txProvider, _) {
        final recentTransactions = txProvider.transactions
            .where((tx) => tx.date.isAfter(
                  DateTime.now().subtract(
                    Duration(days: 7),
                  ),
                ))
            .toList();

        final groupedTransactions = _groupTransactionsByDay(recentTransactions);

        return Card(
          elevation: 6,
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  'Weekly Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 10),
                Container(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _findMaxY(groupedTransactions) * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final data = groupedTransactions[groupIndex];
                            final amount = rodIndex == 0
                                ? data['income']
                                : data['expense'];
                            return BarTooltipItem(
                              '\$${amount.toStringAsFixed(2)}',
                              TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  groupedTransactions[value.toInt()]['day'],
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Container();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups:
                          groupedTransactions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data['income'],
                              color: Colors.green,
                              width: 12,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                            BarChartRodData(
                              toY: data['expense'],
                              color: Colors.red,
                              width: 12,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Income', Colors.green),
                    SizedBox(width: 20),
                    _buildLegendItem('Expense', Colors.red),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 5),
        Text(title),
      ],
    );
  }

  double _findMaxY(List<Map<String, dynamic>> groupedData) {
    double maxIncome = 0.0;
    double maxExpense = 0.0;

    for (final data in groupedData) {
      if (data['income'] > maxIncome) {
        maxIncome = data['income'];
      }
      if (data['expense'] > maxExpense) {
        maxExpense = data['expense'];
      }
    }

    return maxIncome > maxExpense ? maxIncome : maxExpense;
  }
}
