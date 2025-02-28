import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart'; // Создайте этот файл, если нужна регистрация
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text;

    await auth.login(phoneNumber, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (ctx, auth, _) {
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Лого и название
                      Icon(
                        Icons.account_balance_wallet,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'MyFin',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ваш персональный финансовый помощник',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 40),

                      // Поле ввода номера телефона
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Номер телефона',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: '77XXXXXXXXX',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите номер телефона';
                          }
                          if (!RegExp(r'^77[0-9]{9}$').hasMatch(value)) {
                            return 'Введите номер в формате 77XXXXXXXXX';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Поле ввода пароля
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите пароль';
                          }
                          if (value.length < 6) {
                            return 'Пароль должен быть не менее 6 символов';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),

                      // Кнопка "Забыли пароль?"
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Реализуйте восстановление пароля при наличии такого API
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Функция сброса пароля находится в разработке')));
                          },
                          child: Text('Забыли пароль?'),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Отображение ошибки
                      if (auth.error != null)
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            auth.error!,
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(height: auth.error != null ? 16 : 0),

                      // Кнопка входа
                      ElevatedButton(
                        onPressed: auth.isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: auth.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ))
                            : Text(
                                'Войти',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                      SizedBox(height: 20),

                      // Или продолжить с помощью
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'или',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                      ),

                      // Вход с гостевым режимом (если есть)
                      OutlinedButton.icon(
                        icon: Icon(Icons.person_outline),
                        label: Text('Войти как гость'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          // Реализуйте вход для гостя, если это предусмотрено
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Функция гостевого входа находится в разработке')));
                        },
                      ),
                      SizedBox(height: 20),

                      // Регистрация
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Нет аккаунта?'),
                          TextButton(
                            onPressed: () {
                              // Навигация на экран регистрации, если у API есть такая функция
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Функция регистрации находится в разработке')));
                              // Раскомментируйте, если создадите экран регистрации
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (_) => RegisterScreen(),
                              //   ),
                              // );
                            },
                            child: Text('Зарегистрироваться'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
