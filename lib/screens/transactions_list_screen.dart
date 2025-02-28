import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/finance_transaction.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../constants/category_icons.dart';
import 'add_transaction_screen.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({Key? key}) : super(key: key);

  @override
  _TransactionsListScreenState createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  String _searchQuery = '';
  TransactionType? _selectedType;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _selectedType = null;
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _showFilterDialog() async {
    TransactionType? tempType = _selectedType;
    String? tempCategory = _selectedCategory;
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(AppTheme.paddingM),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Фильтры',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempType = null;
                            tempCategory = null;
                            tempStartDate = null;
                            tempEndDate = null;
                          });
                        },
                        child: Text('Сбросить'),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.paddingM),

                  // Тип транзакции
                  Text(
                    'Тип транзакции',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppTheme.paddingS),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterChip(
                          label: 'Доходы',
                          icon: Icons.arrow_upward,
                          color: AppTheme.incomeColor,
                          selected: tempType == TransactionType.income,
                          onSelected: (selected) {
                            setModalState(() {
                              tempType =
                                  selected ? TransactionType.income : null;
                              // При смене типа сбрасываем категорию
                              if (selected) tempCategory = null;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: AppTheme.paddingS),
                      Expanded(
                        child: _buildFilterChip(
                          label: 'Расходы',
                          icon: Icons.arrow_downward,
                          color: AppTheme.expenseColor,
                          selected: tempType == TransactionType.expense,
                          onSelected: (selected) {
                            setModalState(() {
                              tempType =
                                  selected ? TransactionType.expense : null;
                              // При смене типа сбрасываем категорию
                              if (selected) tempCategory = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.paddingM),

                  // Категория
                  Text(
                    'Категория',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppTheme.paddingS),

                  _buildCategorySelector(tempType, tempCategory, (category) {
                    setModalState(() {
                      tempCategory = category;
                    });
                  }),

                  SizedBox(height: AppTheme.paddingM),

                  // Диапазон дат
                  Text(
                    'Период времени',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppTheme.paddingS),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: tempStartDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() {
                                tempStartDate = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'С',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: AppTheme.paddingS,
                                vertical: AppTheme.paddingS,
                              ),
                            ),
                            child: Text(
                              tempStartDate != null
                                  ? DateFormat.yMMMd('ru')
                                      .format(tempStartDate!)
                                  : 'Выберите дату',
                              style: TextStyle(
                                color: tempStartDate != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppTheme.paddingS),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: tempEndDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() {
                                tempEndDate = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'По',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: AppTheme.paddingS,
                                vertical: AppTheme.paddingS,
                              ),
                            ),
                            child: Text(
                              tempEndDate != null
                                  ? DateFormat.yMMMd('ru').format(tempEndDate!)
                                  : 'Выберите дату',
                              style: TextStyle(
                                color: tempEndDate != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.paddingL),

                  // Кнопки
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Отмена'),
                        ),
                      ),
                      SizedBox(width: AppTheme.paddingM),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedType = tempType;
                              _selectedCategory = tempCategory;
                              _startDate = tempStartDate;
                              _endDate = tempEndDate;
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text('Применить'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategorySelector(TransactionType? type, String? selectedCategory,
      Function(String?) onSelected) {
    List<String> categories = [];

    if (type == TransactionType.expense) {
      categories = CategoryIcons.expenseIcons.keys.toList();
    } else if (type == TransactionType.income) {
      categories = CategoryIcons.incomeIcons.keys.toList();
    } else {
      // Если тип не выбран, объединяем все категории
      categories = [
        ...CategoryIcons.expenseIcons.keys,
        ...CategoryIcons.incomeIcons.keys,
      ].toSet().toList(); // Удаляем дубликаты
    }

    return Wrap(
      spacing: AppTheme.paddingS,
      runSpacing: AppTheme.paddingS,
      children: categories.map((category) {
        final icon = type == TransactionType.income
            ? CategoryIcons.incomeIcons[category]
            : (type == TransactionType.expense
                ? CategoryIcons.expenseIcons[category]
                : (CategoryIcons.incomeIcons[category] ??
                    CategoryIcons.expenseIcons[category]));

        final color = CategoryIcons.categoryColors[category] ?? Colors.grey;

        return ChoiceChip(
          label: Text(category),
          selected: selectedCategory == category,
          onSelected: (selected) {
            onSelected(selected ? category : null);
          },
          avatar: icon != null
              ? Icon(icon,
                  size: 16,
                  color: selectedCategory == category ? Colors.white : color)
              : null,
          backgroundColor: Colors.grey[200],
          selectedColor: color,
          labelStyle: TextStyle(
            color: selectedCategory == category ? Colors.white : Colors.black,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 16, color: selected ? Colors.white : color),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: color,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
      ),
    );
  }

  List<FinanceTransaction> _filterTransactions(
      List<FinanceTransaction> transactions) {
    return transactions.where((tx) {
      // Фильтр по поиску
      if (_searchQuery.isNotEmpty &&
          !tx.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !(tx.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false)) {
        return false;
      }

      // Фильтр по типу
      if (_selectedType != null && tx.type != _selectedType) {
        return false;
      }

      // Фильтр по категории
      if (_selectedCategory != null && tx.category != _selectedCategory) {
        return false;
      }

      // Фильтр по начальной дате
      if (_startDate != null &&
          tx.date.isBefore(_startDate!.subtract(Duration(days: 1)))) {
        return false;
      }

      // Фильтр по конечной дате
      if (_endDate != null &&
          tx.date.isAfter(_endDate!.add(Duration(days: 1)))) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Все транзакции'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Строка поиска
          Padding(
            padding: EdgeInsets.all(AppTheme.paddingM),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Поиск по названию или заметке',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty ||
                        _selectedType != null ||
                        _selectedCategory != null ||
                        _startDate != null ||
                        _endDate != null
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: _resetFilters,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
            ),
          ),

          // Отображение активных фильтров
          if (_selectedType != null ||
              _selectedCategory != null ||
              _startDate != null ||
              _endDate != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingM),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_selectedType != null)
                      Padding(
                        padding: EdgeInsets.only(right: AppTheme.paddingS),
                        child: Chip(
                          label: Text(_selectedType == TransactionType.income
                              ? 'Доходы'
                              : 'Расходы'),
                          deleteIcon: Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedType = null;
                            });
                          },
                          backgroundColor:
                              _selectedType == TransactionType.income
                                  ? AppTheme.incomeColor.withOpacity(0.2)
                                  : AppTheme.expenseColor.withOpacity(0.2),
                        ),
                      ),
                    if (_selectedCategory != null)
                      Padding(
                        padding: EdgeInsets.only(right: AppTheme.paddingS),
                        child: Chip(
                          label: Text(_selectedCategory!),
                          deleteIcon: Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                          backgroundColor: (CategoryIcons
                                      .categoryColors[_selectedCategory] ??
                                  Colors.grey)
                              .withOpacity(0.2),
                        ),
                      ),
                    if (_startDate != null && _endDate != null)
                      Padding(
                        padding: EdgeInsets.only(right: AppTheme.paddingS),
                        child: Chip(
                          label: Text(
                              '${DateFormat.MMMd('ru').format(_startDate!)} - ${DateFormat.MMMd('ru').format(_endDate!)}'),
                          deleteIcon: Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                            });
                          },
                        ),
                      )
                    else if (_startDate != null)
                      Padding(
                        padding: EdgeInsets.only(right: AppTheme.paddingS),
                        child: Chip(
                          label: Text(
                              'С ${DateFormat.MMMd('ru').format(_startDate!)}'),
                          deleteIcon: Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _startDate = null;
                            });
                          },
                        ),
                      )
                    else if (_endDate != null)
                      Padding(
                        padding: EdgeInsets.only(right: AppTheme.paddingS),
                        child: Chip(
                          label: Text(
                              'По ${DateFormat.MMMd('ru').format(_endDate!)}'),
                          deleteIcon: Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _endDate = null;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

          SizedBox(height: AppTheme.paddingS),

          // Список транзакций
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (ctx, transactionProvider, _) {
                final filteredTransactions =
                    _filterTransactions(transactionProvider.transactions);

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: AppTheme.paddingM),
                        Text(
                          'Транзакции не найдены',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: AppTheme.paddingS),
                        Text(
                          _selectedType != null ||
                                  _selectedCategory != null ||
                                  _startDate != null ||
                                  _endDate != null ||
                                  _searchQuery.isNotEmpty
                              ? 'Попробуйте изменить параметры фильтрации'
                              : 'Добавьте свою первую транзакцию',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: AppTheme.paddingL),
                        if (_selectedType != null ||
                            _selectedCategory != null ||
                            _startDate != null ||
                            _endDate != null ||
                            _searchQuery.isEmpty)
                          OutlinedButton.icon(
                            icon: Icon(Icons.filter_alt_off),
                            label: Text('Сбросить фильтры'),
                            onPressed: _resetFilters,
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await transactionProvider.fetchTransactions();
                  },
                  child: ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppTheme.paddingM),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = filteredTransactions[index];
                      final isIncome = tx.type == TransactionType.income;
                      final color = isIncome
                          ? AppTheme.incomeColor
                          : AppTheme.expenseColor;
                      final icon = isIncome
                          ? CategoryIcons.incomeIcons[tx.category] ??
                              Icons.arrow_upward
                          : CategoryIcons.expenseIcons[tx.category] ??
                              Icons.arrow_downward;

                      // Проверяем, нужно ли показывать разделитель даты
                      bool showDateDivider = false;
                      if (index == 0) {
                        showDateDivider = true;
                      } else {
                        final prevTx = filteredTransactions[index - 1];
                        if (tx.date.year != prevTx.date.year ||
                            tx.date.month != prevTx.date.month ||
                            tx.date.day != prevTx.date.day) {
                          showDateDivider = true;
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateDivider) ...[
                            SizedBox(height: AppTheme.paddingM),
                            _buildDateDivider(tx.date),
                            SizedBox(height: AppTheme.paddingS),
                          ],
                          Card(
                            margin: EdgeInsets.only(bottom: AppTheme.paddingS),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusM),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              if (tx.note != null &&
                                                  tx.note!.isNotEmpty) ...[
                                                Text(
                                                  ' • ',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    tx.note!,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Сумма
                                    Text(
                                      (isIncome ? '+ ' : '- ') +
                                          CurrencyFormatter.format(tx.amount),
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
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => AddTransactionScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(Duration(days: 1));

    String dateText;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      dateText = 'Сегодня';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      dateText = 'Вчера';
    } else {
      dateText = DateFormat.yMMMd('ru').format(date);
    }

    return Row(
      children: [
        Text(
          dateText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(width: AppTheme.paddingS),
        Expanded(
          child: Divider(thickness: 1),
        ),
      ],
    );
  }
}
