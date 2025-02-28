import 'package:finance_app/models/category.dart';
import 'package:finance_app/utils/icon_dropdown_items.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:finance_app/models/finance_transaction.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/providers/category_provider.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:finance_app/widgets/color_picker_widget.dart';

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
  int? _selectedCategoryId; // Теперь храним только ID категории
  late TransactionType _transactionType;

  // Предустановленные суммы для быстрого выбора
  final List<double> _quickAmounts = [1000, 2000, 5000, 10000, 20000];
  AmountInputMode _amountInputMode = AmountInputMode.keyboard;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      // Режим редактирования
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedDate = widget.transaction!.date;
      _selectedCategoryId = widget
          .transaction!.category.id; // Предполагаем, что category - это ID
      _transactionType = widget.transaction!.type;
      _noteController.text = widget.transaction!.note ?? '';
    } else {
      // Режим добавления
      _selectedDate = DateTime.now();
      _transactionType = widget.initialType ?? TransactionType.expense;
      // Категорию будем устанавливать в didChangeDependencies
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Установим категорию здесь, чтобы иметь доступ к контексту
    if (_selectedCategoryId == null) {
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      final categories = _transactionType == TransactionType.expense
          ? categoryProvider.expenseCategories
          : categoryProvider.incomeCategories;

      // Если есть категории, выбираем первую
      if (categories.isNotEmpty) {
        _selectedCategoryId = categories[0]['id'];
      }
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
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, выберите категорию')),
      );
      return;
    }

    final title = _titleController.text;
    final amount = double.parse(_amountController.text);
    final note = _noteController.text.isEmpty ? null : _noteController.text;

    final transaction = FinanceTransaction(
      id: widget.transaction?.id ?? Uuid().v4(),
      title: title,
      amount: amount,
      date: _selectedDate,
      category: Category(
          id: _selectedCategoryId,
          name: 'name',
          type: 0,
          icon: 1,
          color: 'color'),
      //_selectedCategoryId!, // Используем ID категории
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

  void _showAddCategoryDialog() {
    // Открываем диалог для добавления новой категории
    final nameController = TextEditingController();
    final colorController = TextEditingController(text: '#4CAF50');
    int selectedIcon = 0;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          // Получаем доступ к CategoryProvider
          final categoryProvider = Provider.of<CategoryProvider>(context);

          return AlertDialog(
            title: const Text('Добавить категорию'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название категории',
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    value: selectedIcon,
                    decoration: const InputDecoration(
                      labelText: 'Выберите иконку',
                    ),
                    items: IconDropdownItems.buildIconDropdownItems(context),
                    onChanged: (value) {
                      setState(() {
                        selectedIcon = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: colorController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Цвет',
                      suffixIcon: IconButton(
                        icon: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _parseColor(colorController.text),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () async {
                          final selectedColor = await showDialog<Color>(
                            context: context,
                            builder: (context) => ColorPickerDialog(
                              initialColor: _parseColor(colorController.text),
                            ),
                          );

                          if (selectedColor != null) {
                            setState(() {
                              colorController.text =
                                  '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  // Отображение ошибки из провайдера, если она есть
                  if (categoryProvider.error != null &&
                      categoryProvider.error!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        categoryProvider.error!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                  ],
                  // Индикатор загрузки
                  if (isLoading || categoryProvider.isLoading) ...[
                    const SizedBox(height: 20),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () {
                  // Сбрасываем ошибку при закрытии диалога
                  Provider.of<CategoryProvider>(context, listen: false)
                      .clearError();
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: const Text('Добавить'),
                onPressed: isLoading || categoryProvider.isLoading
                    ? null
                    : () async {
                        // Проверка на пустое имя
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Пожалуйста, введите название категории')),
                          );
                          return;
                        }

                        // Устанавливаем локальный индикатор загрузки
                        setState(() {
                          isLoading = true;
                        });

                        // Сбрасываем предыдущую ошибку
                        Provider.of<CategoryProvider>(context, listen: false)
                            .clearError();

                        // Пытаемся добавить категорию
                        final success = await Provider.of<CategoryProvider>(
                                context,
                                listen: false)
                            .addCategory(
                          nameController.text.trim(),
                          _transactionType == TransactionType.expense ? 0 : 1,
                          selectedIcon,
                          colorController.text.trim(),
                        );

                        // Обновляем локальное состояние загрузки
                        setState(() {
                          isLoading = false;
                        });

                        // Если успешно, закрываем диалог
                        if (success) {
                          Navigator.of(ctx).pop();
                          // Обновляем UI
                          this.setState(() {});
                        }
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Получаем категории из провайдера
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = _transactionType == TransactionType.expense
        ? categoryProvider.expenseCategories
        : categoryProvider.incomeCategories;

    // Проверяем, существует ли выбранная категория в текущем списке категорий
    bool categoryExists = false;
    if (_selectedCategoryId != null) {
      categoryExists =
          categories.any((cat) => cat['id'] == _selectedCategoryId);
    }

    // Если выбранной категории нет в списке, выбираем первую категорию
    if (!categoryExists && categories.isNotEmpty) {
      _selectedCategoryId = categories[0]['id'];
    } else if (categories.isEmpty) {
      _selectedCategoryId = null;
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
                          prefixText: '\₸ ',
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
                        spacing: AppTheme.paddingXS,
                        runSpacing: AppTheme.paddingXS,
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
                                  child: Text(amount.toStringAsFixed(0)),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Категория',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // Кнопка добавления новой категории
                        TextButton.icon(
                          onPressed: _showAddCategoryDialog,
                          icon: Icon(Icons.add),
                          label: Text('Добавить'),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                _transactionType == TransactionType.income
                                    ? AppTheme.incomeColor
                                    : AppTheme.expenseColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.paddingXS),
                    if (categories.isEmpty)
                      Center(
                        child: Text(
                          'Нет доступных категорий. Добавьте новую категорию.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      Wrap(
                        spacing: AppTheme.paddingS,
                        runSpacing: AppTheme.paddingS,
                        children: categories.map(
                          (categoryMap) {
                            // Создаем временный объект Category для удобства работы
                            final category = Category.fromMap(categoryMap);

                            return ChoiceChip(
                              label: Text(category.name),
                              selected: _selectedCategoryId == category.id,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategoryId = category.id;
                                  });
                                }
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: category.colorValue,
                              labelStyle: TextStyle(
                                color: _selectedCategoryId == category.id
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              avatar: Icon(
                                category.iconData,
                                size: 18,
                                color: _selectedCategoryId == category.id
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            );
                          },
                        ).toList(),
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
              onPressed: categories.isEmpty ? null : _submitForm,
              // Блокируем кнопку, если нет категорий
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
          // При смене типа транзакции нужно обновить категорию
          final categoryProvider =
              Provider.of<CategoryProvider>(context, listen: false);
          final categories = type == TransactionType.expense
              ? categoryProvider.expenseCategories
              : categoryProvider.incomeCategories;

          if (categories.isNotEmpty) {
            _selectedCategoryId = categories[0]['id'];
          } else {
            _selectedCategoryId = null;
          }
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

  // Преобразование цвета из HEX-строки
  Color _parseColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');

    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }

    return Color(int.parse(hexColor, radix: 16));
  }
}
