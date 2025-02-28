import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final name = _nameController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text;

    // Вызов метода регистрации из AuthProvider
    // Примечание: API метод регистрации не был обнаружен в документации
    // Поэтому показываем сообщение с заглушкой

    // Раскомментируйте этот код, когда у вас будет реализован API регистрации
    /*
    final success = await auth.register(name, phoneNumber, password);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
    */

    // Временная заглушка
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Функция регистрации в процессе разработки. Свяжитесь с администратором для создания учетной записи.'),
        duration: Duration(seconds: 3),
      ),
    );

    // После сообщения возвращаемся на экран входа
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Регистрация'),
        elevation: 0,
      ),
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
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Создание аккаунта',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 30),

                      // Поле ввода имени
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Имя',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: 'Введите ваше имя',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите имя';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

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
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                          if (value.length < 8) {
                            return 'Пароль должен быть не менее 8 символов';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Поле подтверждения пароля
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Подтвердите пароль',
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, подтвердите пароль';
                          }
                          if (value != _passwordController.text) {
                            return 'Пароли не совпадают';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

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

                      // Кнопка регистрации
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
                            )
                        )
                            : Text(
                          'Зарегистрироваться',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Ссылка на экран входа
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Уже есть аккаунт?'),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
                              );
                            },
                            child: Text('Войти'),
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