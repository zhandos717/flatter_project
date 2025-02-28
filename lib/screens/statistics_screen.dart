import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/finance_transaction.dart';
import '../constants/category_icons.dart';
import '../utils/formatters.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _showExpenses = true;
  String _timeRange = 'month'; // 'week', 'month', 'year'
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (ctx, txProvider, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tab toggles
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showExpenses ? Theme.of(context).primaryColor : Colors.grey[300],
                        ),
                        child: Text(
                          'Expenses',
                          style: TextStyle(
                            color: _showExpenses ? Colors.white : Colors.black,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showExpenses = true;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_showExpenses ? Theme.of(context).primaryColor : Colors.grey[300],
                        ),
                        child: Text(
                          'Income',
                          style: TextStyle(
                            color: !_showExpenses ? Colors.white : Colors.black,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showExpenses = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                
                // Time range selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimeRangeButton('Week', 'week'),
                    _buildTimeRangeButton('Month', 'month'),
                    _buildTimeRangeButton('Year', 'year'),
                  ],
                ),
                SizedBox(height: 20),
                
                // Pie chart heading
                Text(
                  _showExpenses 
                      ? 'Expense Distribution by Category' 
                      : 'Income Distribution by Category',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 10),
                
                // Pie chart
                _buildPieChart(
                  _showExpenses ? txProvider.expenses : txProvider.incomes,
                ),
                SizedBox(height: 20),
                
                // Category breakdown
                Text(
                  'Category Breakdown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 10),
                _buildCategoryList(
                  _showExpenses ? txProvider.expenses : txProvider.incomes,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTimeRangeButton(String title, String range) {
    final isSelected = _timeRange == range;
    
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[300],
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          onPressed: () {
            setState(() {
              _timeRange = range;
            });
          },
        ),
      ),
    );
  }
  
  Widget _buildPieChart(List<FinanceTransaction> transactions) {
    // Filter transactions by time range
    final filteredTransactions = _filterTransactionsByTimeRange(transactions);
    
    // Group by category
    final Map<String, double> categoryAmounts = {};
    
    for (final tx in filteredTransactions) {
      if (categoryAmounts.containsKey(tx.category)) {
        categoryAmounts[tx.category] = categoryAmounts[tx.category]! + tx.amount;
      } else {
        categoryAmounts[tx.category] = tx.amount;
      }
    }
    
    // No data case
    if (categoryAmounts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No data for selected period'),
        ),
      );
    }
    
    // Prepare pie chart data
    final List<PieChartSectionData> sections = [];
    int i = 0;
    
    categoryAmounts.forEach((category, amount) {
      final color = CategoryIcons.categoryColors[category] ?? Colors.grey;
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: '${(amount / _calculateTotal(categoryAmounts) * 100).toStringAsFixed(0)}%',
          radius: 100,
          titleStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      i++;
    });
    
    return Container(
      height: 300,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildLegend(categoryAmounts),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegend(Map<String, double> categoryAmounts) {
    final total = _calculateTotal(categoryAmounts);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryAmounts.entries.map((entry) {
        final category = entry.key;
        final amount = entry.value;
        final percentage = (amount / total * 100).toStringAsFixed(1);
        final color = CategoryIcons.categoryColors[category] ?? Colors.grey;
        
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                color: color,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('$percentage%'),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildCategoryList(List<FinanceTransaction> transactions) {
    // Filter transactions by time range
    final filteredTransactions = _filterTransactionsByTimeRange(transactions);
    
    // Group by category
    final Map<String, double> categoryAmounts = {};
    
    for (final tx in filteredTransactions) {
      if (categoryAmounts.containsKey(tx.category)) {
        categoryAmounts[tx.category] = categoryAmounts[tx.category]! + tx.amount;
      } else {
        categoryAmounts[tx.category] = tx.amount;
      }
    }
    
    // Sort by amount (descending)
    final sortedEntries = categoryAmounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // No data case
    if (categoryAmounts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No data for selected period'),
        ),
      );
    }
    
    return Column(
      children: sortedEntries.map((entry) {
        final category = entry.key;
        final amount = entry.value;
        final color = CategoryIcons.categoryColors[category] ?? Colors.grey;
        final icon = _showExpenses 
            ? CategoryIcons.expenseIcons[category] 
            : CategoryIcons.incomeIcons[category];
        
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(
                icon ?? Icons.category,
                color: color,
              ),
            ),
            title: Text(category),
            trailing: Text(
              CurrencyFormatter.format(amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  List<FinanceTransaction> _filterTransactionsByTimeRange(List<FinanceTransaction> transactions) {
    final now = DateTime.now();
    
    switch (_timeRange) {
      case 'week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return transactions.where((tx) => tx.date.isAfter(startOfWeek)).toList();
      case 'month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return transactions.where((tx) => tx.date.isAfter(startOfMonth)).toList();
      case 'year':
        final startOfYear = DateTime(now.year, 1, 1);
        return transactions.where((tx) => tx.date.isAfter(startOfYear)).toList();
      default:
        return transactions;
    }
  }
  
  double _calculateTotal(Map<String, double> amounts) {
    return amounts.values.fold(0.0, (sum, amount) => sum + amount);
  }
}
