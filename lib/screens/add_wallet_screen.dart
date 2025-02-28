import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_theme.dart';

class AddWalletScreen extends StatefulWidget {
  final Map<String, dynamic>? wallet;

  const AddWalletScreen({Key? key, this.wallet}) : super(key: key);

  @override
  _AddWalletScreenState createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  int _walletType = 1; // 1 - обычный кошелек, 2 - целевой кошелек
  int? _selectedIcon;
  Color _selectedColor = Colors.green;

  // Предопределенные цвета кошельков
  final List<Color> _walletColors = [
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.red,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  // Предопределенные иконки кошельков
  final List<IconData> _walletIcons = [
    Icons.account_balance_wallet,
    Icons.credit_card,
    Icons.savings,
    Icons.attach_money,
    Icons.account_balance,
    Icons.shopping_bag,
    Icons.euro,
    Icons.payment,
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Заполняем поля данными, если редактируем существующий кошелек
    if (widget.wallet != null) {
      _nameController.text = widget.wallet!['name'] ?? '';
      _balanceController.text = widget.wallet!['balance']?.toString() ?? '0';
      _walletType = int.parse(widget.wallet!['type']?.toString() ?? '1');

      // Пытаемся восстановить цвет
      final colorStr = widget.wallet!['color'] ?? '';
      if (colorStr.isNotEmpty) {
        try {
          _selectedColor = Color(int.parse(colorStr.replaceAll('#', '0xFF')));
        } catch (e) {
          _selectedColor = Colors.green;
        }
      }

      // Пытаемся восстановить иконку
      _selectedIcon = widget.wallet!['icon'] != null ? int.parse(widget.wallet!['icon'].toString()) : null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  // Преобразование Color в строку hex
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  Future<void> _saveWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    try {
      final name = _nameController.text;
      final balance = double.tryParse(_balanceController.text) ?? 0;
      final colorHex = _colorToHex(_selectedColor);

      bool success;

      if (widget.wallet == null) {
        // Создаем новый кошелек
        success = await walletProvider.addWallet(
          name,
          _walletType,
          color: colorHex,
          icon: _selectedIcon,
        );
      } else {
        // В реальном приложении здесь будет код для обновления кошелька
        success = true;
      }

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.of(context).pop();
      } else {
        // Показываем сообщение об ошибке
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(walletProvider.error ?? 'Произошла ошибка'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Произошла ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallet == null ? 'Новый кошелек' : 'Редактировать кошелек'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppTheme.paddingM),
          children: [
            // Тип кошелька
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
                        title: 'Обычный',
                        subtitle: 'Для повседневных трат',
                        icon: Icons.account_balance_wallet,
                        type: 1,
                        isSelected: _walletType == 1,
                      ),
                    ),
                    Expanded(
                      child: _buildTypeButton(
                        title: 'Целевой',
                        subtitle: 'Для накоплений',
                        icon: Icons.savings,
                        type: 2,
                        isSelected: _walletType == 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Форма кошелька
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
                    // Название кошелька
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Название кошелька',
                        prefixIcon: Icon(Icons.edit),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите название';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: AppTheme.paddingM),

                    // Текущий баланс
                    TextFormField(
                      controller: _balanceController,
                      decoration: InputDecoration(
                        labelText: 'Текущий баланс',
                        prefixIcon: Icon(Icons.money),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите баланс';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Пожалуйста, введите корректное число';
                        }
                        return null;
                      },
                    ),

                    if (_walletType == 2) ...[
                      SizedBox(height: AppTheme.paddingM),

                      // Желаемый баланс (для целевого кошелька)
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Целевая сумма',
                          prefixIcon: Icon(Icons.flag),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Персонализация кошелька
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
                      'Персонализация',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: AppTheme.paddingM),

                    // Выбор цвета
                    Text(
                      'Цвет кошелька',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppTheme.paddingS),

                    Wrap(
                      spacing: AppTheme.paddingS,
                      runSpacing: AppTheme.paddingS,
                      children: _walletColors.map((color) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                if (_selectedColor == color)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: AppTheme.paddingM),

                    // Выбор иконки
                    Text(
                      'Иконка кошелька',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppTheme.paddingS),

                    Wrap(
                      spacing: AppTheme.paddingS,
                      runSpacing: AppTheme.paddingS,
                      children: _walletIcons.asMap().entries.map((entry) {
                        final index = entry.key;
                        final icon = entry.value;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIcon = index;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _selectedIcon == index
                                  ? _selectedColor
                                  : Colors.grey[200],
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (_selectedIcon == index)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                            child: Icon(
                              icon,
                              color: _selectedIcon == index
                                  ? Colors.white
                                  : Colors.grey[700],
                              size: 20,
                            ),
                          ),
                        );
                      }).toList(),
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
                backgroundColor: _selectedColor,
              ),
              onPressed: _isLoading ? null : _saveWallet,
              icon: _isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Icon(widget.wallet == null ? Icons.add : Icons.save),
              label: Text(
                widget.wallet == null ? 'Создать кошелек' : 'Сохранить изменения',
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
    required String subtitle,
    required IconData icon,
    required int type,
    required bool isSelected,
  }) {
    final color = isSelected ? AppTheme.primaryColor : Colors.grey;

    return InkWell(
      onTap: () {
        setState(() {
          _walletType = type;
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
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}