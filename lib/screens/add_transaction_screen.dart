import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:finance_app/models/finance_transaction.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  final FinanceTransaction? transaction;
  final TransactionType? initialType;

  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.initialType,
  });

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

enum AmountInputMode { keyboard, presets }

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late DateTime _selectedDate;
  late String _selectedCategory;
  late TransactionType _transactionType;

  final List<String> _expenseCategories = [
    'Еда', 'Транспорт', 'Развлечения', 'Счета', 'Покупки', 'Здоровье', 'Другое'
  ];

  final List<String> _incomeCategories = [
    'Зарплата', 'Фриланс', 'Инвестиции', 'Подарки', 'Другое'
  ];

  // Предустановленные суммы для быстрого выбора
  final List<double> _quickAmounts = [50, 100, 200, 500, 1000];
  AmountInputMode _amountInputMode = AmountInputMode.keyboard;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      // Режим редактирования
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedDate = widget.transaction!.date;
      _selectedCategory = widget.transaction!.category;
      _transactionType = widget.transaction!.type;
      _noteController.text = widget.transaction!.note ?? '';
    } else {
      // Режим добавления
      _selectedDate = DateTime.now();
      _transactionType = widget.initialType ?? TransactionType.expense;
      _selectedCategory = _transactionType == TransactionType.expense
          ? _expenseCategories[0]
          : _incomeCategories[0];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text;
    final amount = double.parse(_amountController.text);
    final note = _noteController.text.isEmpty ? null : _noteController.text;

    final transaction = FinanceTransaction(
      id: widget.transaction?.id ?? Uuid().v4(),
      title: title,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      type: _transactionType,
      note: note,
    );

    if (widget.transaction == null) {
      // Добавить новую транзакцию
      Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(transaction);
    } else {
      // Обновить существующую транзакцию
      Provider.of<TransactionProvider>(context, listen: false)
          .updateTransaction(transaction);
    }

    Navigator.of(context).pop();
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _setAmount(double amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = _transactionType == TransactionType.expense
        ? _expenseCategories
        : _incomeCategories;

    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories[0];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null
            ? 'Добавить транзакцию'
            : 'Редактировать транзакцию'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppTheme.paddingM),
          children: [
            // Переключатель типа транзакции
            Card(
              margin: EdgeInsets.only(bottom: AppTheme.paddingM),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.paddingS),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton(
                        title: 'Расход',
                        icon: Icons.remove_circle_outline,
                        type: TransactionType.expense,
                        isSelected: _transactionType == TransactionType.expense,
                      ),
                    ),
                    Expanded(
                      child: _buildTypeButton(
                        title: 'Доход',
                        icon: Icons.add_circle_outline,
                        type: TransactionType.income,
                        isSelected: _transactionType == TransactionType.income,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Сумма
            Card(
              margin: EdgeInsets.only(bottom: AppTheme.paddingM),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Сумма',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: AppTheme.paddingS),

                    // Переключатели режима ввода суммы
                    Row(
                      children: [
                        _buildInputModeToggle(
                          title: 'Клавиатура',
                          mode: AmountInputMode.keyboard,
                        ),
                        SizedBox(width: AppTheme.paddingS),
                        _buildInputModeToggle(
                          title: 'Быстрый выбор',
                          mode: AmountInputMode.presets,
                        ),
                      ],
                    ),

                    SizedBox(height: AppTheme.paddingM),

                    // Поле ввода суммы или кнопки быстрого выбора
                    if (_amountInputMode == AmountInputMode.keyboard)
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          hintText: '0.00',
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите сумму';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Пожалуйста, введите корректное число';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Сумма должна быть больше нуля';
                          }
                          return null;
                        },
                      )
                    else
                      Wrap(
                        spacing: AppTheme.paddingS,
                        runSpacing: AppTheme.paddingS,
                        children: _quickAmounts
                            .map((amount) => ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _amountController.text ==
                                            amount.toString()
                                        ? _transactionType ==
                                                TransactionType.income
                                            ? AppTheme.incomeColor
                                            : AppTheme.expenseColor
                                        : Colors.grey[200],
                                    foregroundColor: _amountController.text ==
                                            amount.toString()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  onPressed: () => _setAmount(amount),
                                  child: Text('\$${amount.toStringAsFixed(0)}'),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),

            // Категория
            Card(
              margin: EdgeInsets.only(bottom: AppTheme.paddingM),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Категория',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: AppTheme.paddingM),
                    Wrap(
                      spacing: AppTheme.paddingS,
                      runSpacing: AppTheme.paddingS,
                      children: categories
                          .map(
                            (category) => ChoiceChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                }
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor:
                                  _transactionType == TransactionType.income
                                      ? AppTheme.incomeColor
                                      : AppTheme.expenseColor,
                              labelStyle: TextStyle(
                                color: _selectedCategory == category
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Название и дата
            Card(
              margin: EdgeInsets.only(bottom: AppTheme.paddingM),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Детали',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: AppTheme.paddingM),

                    // Название
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Название',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите название';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: AppTheme.paddingM),

                    // Дата
                    InkWell(
                      onTap: _showDatePicker,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Дата',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat.yMMMd().format(_selectedDate),
                        ),
                      ),
                    ),

                    SizedBox(height: AppTheme.paddingM),

                    // Заметка
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Заметка (необязательно)',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppTheme.paddingL),

            // Кнопка сохранения
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _transactionType == TransactionType.income
                    ? AppTheme.incomeColor
                    : AppTheme.expenseColor,
              ),
              onPressed: _submitForm,
              icon: Icon(widget.transaction == null ? Icons.add : Icons.save),
              label: Text(
                widget.transaction == null
                    ? 'Добавить транзакцию'
                    : 'Сохранить изменения',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String title,
    required IconData icon,
    required TransactionType type,
    required bool isSelected,
  }) {
    final color = type == TransactionType.income
        ? AppTheme.incomeColor
        : AppTheme.expenseColor;

    return InkWell(
      onTap: () {
        setState(() {
          _transactionType = type;
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusS),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppTheme.paddingM,
          horizontal: AppTheme.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
            ),
            SizedBox(height: AppTheme.paddingXS),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputModeToggle({
    required String title,
    required AmountInputMode mode,
  }) {
    final isSelected = _amountInputMode == mode;
    final color = _transactionType == TransactionType.income
        ? AppTheme.incomeColor
        : AppTheme.expenseColor;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _amountInputMode = mode;
          });
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppTheme.paddingS,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey[200],
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
