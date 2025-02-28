import 'package:finance_app/models/category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/providers/category_provider.dart';
import 'package:finance_app/widgets/color_picker_widget.dart';

import '../utils/icon_dropdown_items.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);

    // Fetch categories when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
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
      appBar: AppBar(
        title: const Text('Категории'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Доходы'),
            Tab(text: 'Расходы'),
          ],
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categoryProvider.error != null) {
            return Center(
              child: Text(
                'Ошибка: ${categoryProvider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Сначала расходы (0), потом доходы (1)
              _buildCategoryList(0, categoryProvider),
              _buildCategoryList(1, categoryProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddCategoryDialog();
        },
      ),
    );
  }

  Widget _buildCategoryList(int type, CategoryProvider categoryProvider) {
    // Получаем категории по типу
    List<Map<String, dynamic>> categoriesMap = type == 0
        ? categoryProvider.incomeCategories
        : categoryProvider.expenseCategories;

    if (categoriesMap.isEmpty) {
      return Center(
        child: Text(
          type == 0 ? 'Нет категорий расходов' : 'Нет категорий доходов',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    // Преобразуем Map в объекты Category для удобства работы
    List<Category> categories =
        categoriesMap.map((map) => Category.fromMap(map)).toList();

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (ctx, index) {
        final category = categories[index];

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: category.colorValue.withOpacity(0.2),
              child: Icon(
                category.iconData,
                color: category.colorValue,
              ),
            ),
            title: Text(category.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditCategoryDialog(category);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteCategoryConfirmation(category);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final colorController = TextEditingController(text: '#4CAF50');
    int selectedIcon = 0;
    int selectedType =
        _tabController.index + 1; // 0 для расходов, 1 для доходов
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Запретить закрытие при клике вне диалога
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
                    readOnly: true, // Make it read-only
                    decoration: InputDecoration(
                      labelText: 'Цвет',
                      suffixIcon: IconButton(
                        icon: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Category(
                              id: null,
                              name: '',
                              type: 1,
                              icon: 0,
                              color: colorController.text,
                            ).colorValue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () async {
                          final selectedColor = await showDialog<Color>(
                            context: context,
                            builder: (context) => ColorPickerDialog(
                              initialColor: Category(
                                id: null,
                                name: '',
                                type: 1,
                                icon: 0,
                                color: colorController.text,
                              ).colorValue,
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
                  // Индикатор загрузки, если идёт обработка запроса
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
                        // Устанавливаем локальный индикатор загрузки
                        setState(() {
                          isLoading = true;
                        });

                        // Проверяем заполнение полей
                        if (nameController.text.trim().isEmpty) {
                          setState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Пожалуйста, введите название категории'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Сбрасываем предыдущую ошибку
                        Provider.of<CategoryProvider>(context, listen: false)
                            .clearError();

                        // Создаем объект категории
                        final newCategory = Category(
                          id: null,
                          name: nameController.text.trim(),
                          type: selectedType,
                          icon: selectedIcon,
                          color: colorController.text.trim(),
                        );

                        // Пытаемся добавить категорию
                        final success = await Provider.of<CategoryProvider>(
                                context,
                                listen: false)
                            .addCategory(
                          newCategory.name,
                          newCategory.type,
                          newCategory.icon,
                          newCategory.color,
                        );

                        // Обновляем локальное состояние загрузки
                        setState(() {
                          isLoading = false;
                        });

                        // Если успешно, закрываем диалог
                        if (success) {
                          Navigator.of(ctx).pop();
                        }
                        // Если неуспешно, диалог останется открытым и покажет ошибку из провайдера
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    final nameController = TextEditingController(text: category.name);
    final colorController = TextEditingController(text: category.color);
    int selectedIcon = category.icon;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Запретить закрытие при клике вне диалога
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          // Получаем доступ к CategoryProvider
          final categoryProvider = Provider.of<CategoryProvider>(context);

          return AlertDialog(
            title: const Text('Редактировать категорию'),
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
                    readOnly: true, // Make it read-only
                    decoration: InputDecoration(
                      labelText: 'Цвет',
                      suffixIcon: IconButton(
                        icon: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Category(
                              id: 0,
                              name: '',
                              type: 0,
                              icon: 0,
                              color: colorController.text,
                            ).colorValue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () async {
                          final selectedColor = await showDialog<Color>(
                            context: context,
                            builder: (context) => ColorPickerDialog(
                              initialColor: Category(
                                id: 0,
                                name: '',
                                type: 0,
                                icon: 0,
                                color: colorController.text,
                              ).colorValue,
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
                  // Индикатор загрузки, если идёт обработка запроса
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
                child: Text("Сохранить"),
                onPressed: isLoading || categoryProvider.isLoading
                    ? null
                    : () async {
                        // Устанавливаем локальный индикатор загрузки
                        setState(() {
                          isLoading = true;
                        });

                        // Проверяем заполнение полей
                        if (nameController.text.trim().isEmpty) {
                          setState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Пожалуйста, введите название категории'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Сбрасываем предыдущую ошибку
                        Provider.of<CategoryProvider>(context, listen: false)
                            .clearError();

                        // Пытаемся обновить категорию
                        final success = await Provider.of<CategoryProvider>(
                                context,
                                listen: false)
                            .updateCategory(category.copyWith(
                          name: nameController.text.trim(),
                          icon: selectedIcon,
                          color: colorController.text.trim(),
                        ));

                        // Обновляем локальное состояние загрузки
                        setState(() {
                          isLoading = false;
                        });

                        // Если успешно, закрываем диалог
                        if (success) {
                          Navigator.of(ctx).pop();
                        }
                        // Если неуспешно, диалог останется открытым и покажет ошибку из провайдера
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteCategoryConfirmation(Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить категорию'),
        content: Text(
          'Вы уверены, что хотите удалить категорию "${category.name}"?',
        ),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
            onPressed: () async {
              final success =
                  await Provider.of<CategoryProvider>(context, listen: false)
                      .deleteCategory(category.id);

              Navigator.of(ctx).pop();

              if (!success) {
                // Показываем сообщение об ошибке, если удаление не удалось
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        Provider.of<CategoryProvider>(context, listen: false)
                                .error ??
                            'Не удалось удалить категорию'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
