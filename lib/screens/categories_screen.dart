import 'package:flutter/material.dart';
import '../constants/category_icons.dart';
import '../models/finance_transaction.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(TransactionType.expense),
          _buildCategoryList(TransactionType.income),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddCategoryDialog();
        },
      ),
    );
  }
  
  Widget _buildCategoryList(TransactionType type) {
    final categories = type == TransactionType.expense 
        ? CategoryIcons.expenseIcons.keys.toList() 
        : CategoryIcons.incomeIcons.keys.toList();
    
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (ctx, index) {
        final category = categories[index];
        final icon = type == TransactionType.expense 
            ? CategoryIcons.expenseIcons[category] 
            : CategoryIcons.incomeIcons[category];
        final color = CategoryIcons.categoryColors[category] ?? Colors.grey;
        
        return Card(
          margin: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            title: Text(category),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Edit category functionality
              },
            ),
          ),
        );
      },
    );
  }
  
  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    IconData selectedIcon = Icons.category;
    Color selectedColor = Colors.blue;
    TransactionType type = _tabController.index == 0 
        ? TransactionType.expense 
        : TransactionType.income;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                ),
              ),
              SizedBox(height: 20),
              Text('Select Icon'),
              // Icon selection would go here
              SizedBox(height: 20),
              Text('Select Color'),
              // Color selection would go here
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              // Add category functionality
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
