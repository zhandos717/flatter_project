import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/finance_transaction.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final FinanceTransaction? transaction;
  
  const AddTransactionScreen({this.transaction});
  
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  late DateTime _selectedDate;
  late String _selectedCategory;
  late TransactionType _transactionType;
  
  final List<String> _expenseCategories = [
    'Food', 'Transport', 'Entertainment', 'Bills', 'Shopping', 'Health', 'Other'
  ];
  
  final List<String> _incomeCategories = [
    'Salary', 'Freelance', 'Investment', 'Gift', 'Other'
  ];
  
  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      // Edit mode
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedDate = widget.transaction!.date;
      _selectedCategory = widget.transaction!.category;
      _transactionType = widget.transaction!.type;
      _noteController.text = widget.transaction!.note ?? '';
    } else {
      // Add mode
      _selectedDate = DateTime.now();
      _transactionType = TransactionType.expense;
      _selectedCategory = _expenseCategories[0];
    }
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
      // Add new transaction
      Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(transaction);
    } else {
      // Update existing transaction
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
            ? 'Add Transaction' 
            : 'Edit Transaction'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Transaction type selector
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<TransactionType>(
                      title: Text('Expense'),
                      value: TransactionType.expense,
                      groupValue: _transactionType,
                      onChanged: (value) {
                        setState(() {
                          _transactionType = value!;
                          _selectedCategory = _expenseCategories[0];
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<TransactionType>(
                      title: Text('Income'),
                      value: TransactionType.income,
                      groupValue: _transactionType,
                      onChanged: (value) {
                        setState(() {
                          _transactionType = value!;
                          _selectedCategory = _incomeCategories[0];
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than zero';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Date picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    child: Text('Choose Date'),
                    onPressed: _showDatePicker,
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              
              // Note
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              
              // Submit button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submitForm,
                child: Text(widget.transaction == null
                    ? 'Add Transaction'
                    : 'Update Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
