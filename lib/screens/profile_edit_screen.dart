import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finance_app/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _middleNameController;
  late TextEditingController _emailController;
  late TextEditingController _birthdateController;
  late TextEditingController _monthLimitController;
  late TextEditingController _dayLimitController;

  File? _profileImage;
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    // Инициализация контроллеров
    _nameController = TextEditingController();
    _middleNameController = TextEditingController();
    _emailController = TextEditingController();
    _birthdateController = TextEditingController();
    _monthLimitController = TextEditingController();
    _dayLimitController = TextEditingController();

    // Загрузка данных пользователя
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _monthLimitController.dispose();
    _dayLimitController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    if (user != null) {
      _nameController.text = user['name'] ?? '';
      _middleNameController.text = user['middle_name'] ?? '';
      _emailController.text = user['email'] ?? '';

      if (user['birthdate'] != null && user['birthdate'].isNotEmpty) {
        _birthdateController.text = user['birthdate'];
        try {
          _selectedDate = DateFormat('yyyy-MM-dd').parse(user['birthdate']);
        } catch (e) {
          print('Error parsing date: $e');
        }
      }

      _monthLimitController.text = user['month_limit']?.toString() ?? '';
      _dayLimitController.text = user['day_limit']?.toString() ?? '';
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка выбора изображения: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Преобразуем строки с лимитами в целые числа, если они не пустые
      int? monthLimit;
      int? dayLimit;

      if (_monthLimitController.text.isNotEmpty) {
        monthLimit = int.tryParse(_monthLimitController.text);
      }

      if (_dayLimitController.text.isNotEmpty) {
        dayLimit = int.tryParse(_dayLimitController.text);
      }

      bool success = await authProvider.updateUserProfile(
        name: _nameController.text.trim(),
        middleName: _middleNameController.text.trim(),
        email: _emailController.text.trim(),
        birthdate: _birthdateController.text,
        monthLimit: monthLimit,
        dayLimit: dayLimit,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Профиль успешно обновлен')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Ошибка обновления профиля'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Произошла ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Редактирование профиля')),
        body: Center(child: Text('Пользователь не авторизован')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Редактирование профиля'),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Фото профиля
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      // backgroundImage: _profileImage != null
                      //     ? FileImage(_profileImage!)
                      //     : (user['avatar_url'] != null
                      //     ? NetworkImage(user['avatar_url'])
                      //     : null),
                      child: user['avatar_url'] == null && _profileImage == null
                          ? Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Основная информация
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Личная информация',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Имя
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Имя',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите имя';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Отчество
                      TextFormField(
                        controller: _middleNameController,
                        decoration: InputDecoration(
                          labelText: 'Отчество (необязательно)',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Пожалуйста, введите корректный email';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Дата рождения
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _birthdateController,
                            decoration: InputDecoration(
                              labelText: 'Дата рождения',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Лимиты расходов
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Лимиты расходов',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Месячный лимит
                      TextFormField(
                        controller: _monthLimitController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Месячный лимит расходов',
                          prefixIcon: Icon(Icons.calendar_month),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (int.tryParse(value) == null) {
                              return 'Пожалуйста, введите число';
                            }
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Дневной лимит
                      TextFormField(
                        controller: _dayLimitController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Дневной лимит расходов',
                          prefixIcon: Icon(Icons.today),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (int.tryParse(value) == null) {
                              return 'Пожалуйста, введите число';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Кнопка сохранения
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _isLoading ? null : _saveProfile,
                child: Text(
                  'Сохранить изменения',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              SizedBox(height: 24),

              // Кнопка изменения пароля
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  // Показать диалог изменения пароля
                  _showChangePasswordDialog(context);
                },
                child: Text(
                  'Изменить пароль',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final TextEditingController _oldPasswordController =
        TextEditingController();
    final TextEditingController _newPasswordController =
        TextEditingController();
    final TextEditingController _confirmPasswordController =
        TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Изменение пароля'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Текущий пароль
                  TextField(
                    controller: _oldPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Текущий пароль',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Новый пароль
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Новый пароль',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Подтверждение пароля
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Подтвердите новый пароль',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, left: 16),
                  child: Text('Сохранить'),
                ),
                onPressed: () async {
                  // Проверка корректности ввода
                  if (_oldPasswordController.text.isEmpty ||
                      _newPasswordController.text.isEmpty ||
                      _confirmPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Все поля должны быть заполнены')),
                    );
                    return;
                  }

                  if (_newPasswordController.text !=
                      _confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Пароли не совпадают')),
                    );
                    return;
                  }

                  // Отправка запроса на изменение пароля
                  final success =
                      await Provider.of<AuthProvider>(context, listen: false)
                          .changePassword(_oldPasswordController.text,
                              _newPasswordController.text);

                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Пароль успешно изменен')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            Provider.of<AuthProvider>(context, listen: false)
                                    .error ??
                                'Ошибка изменения пароля'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }
}
