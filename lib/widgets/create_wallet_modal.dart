import 'package:finance_app/providers/wallet_provider.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class CreateWalletModal extends StatefulWidget {
  final Function() onWalletCreated;

  const CreateWalletModal({
    Key? key,
    required this.onWalletCreated,
  }) : super(key: key);

  @override
  _CreateWalletModalState createState() => _CreateWalletModalState();
}

class _CreateWalletModalState extends State<CreateWalletModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  int _walletType = 1; // По умолчанию обычный кошелек
  int? _desiredBalance;
  Color _selectedColor = Colors.blue;
  int? _selectedIcon;

  bool _isCreating = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Выберите цвет'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Отмена'),
          ),
        ],
      ),
    );
  }

  Future<void> _createWallet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);

      // Преобразуем цвет в строку формата hex
      final String colorStr =
          '#${_selectedColor.value.toRadixString(16).substring(2)}';

      final result = await walletProvider.addWallet(
        _nameController.text,
        _walletType,
        desiredBalance: _desiredBalance,
        color: colorStr,
        icon: _selectedIcon,
      );

      setState(() {
        _isCreating = false;
      });

      if (result) {
        widget.onWalletCreated();
        Navigator.of(context).pop();
      } else {
        setState(() {
          _error = walletProvider.error ?? 'Не удалось создать кошелек';
        });
      }
    } catch (e) {
      setState(() {
        _isCreating = false;
        _error = 'Ошибка: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Center(
                  child: Text(
                    'Создание кошелька',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SizedBox(height: AppTheme.paddingL),

                // Название кошелька
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Название кошелька',
                    hintText: 'Например: Зарплатная карта',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите название кошелька';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppTheme.paddingM),

                // Тип кошелька
                Text(
                  'Тип кошелька',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppTheme.paddingS),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<int>(
                        title: Text('Обычный'),
                        value: 1,
                        groupValue: _walletType,
                        onChanged: (value) {
                          setState(() {
                            _walletType = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<int>(
                        title: Text('Цель'),
                        value: 2,
                        groupValue: _walletType,
                        onChanged: (value) {
                          setState(() {
                            _walletType = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.paddingM),

                // Целевая сумма (только для кошелька типа "Цель")
                if (_walletType == 2)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Целевая сумма',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: AppTheme.paddingS),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Сумма',
                          hintText: 'Например: 100000',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusS),
                          ),
                          suffixText: 'KZT',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _desiredBalance = int.tryParse(value);
                          });
                        },
                        validator: (value) {
                          if (_walletType == 2 &&
                              (value == null || value.isEmpty)) {
                            return 'Пожалуйста, укажите целевую сумму';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppTheme.paddingM),
                    ],
                  ),

                // Выбор цвета
                Text(
                  'Цвет кошелька',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppTheme.paddingS),
                GestureDetector(
                  onTap: _showColorPicker,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        'Выбрать цвет',
                        style: TextStyle(
                          color: ThemeData.estimateBrightnessForColor(
                                      _selectedColor) ==
                                  Brightness.light
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppTheme.paddingL),

                // Отображение ошибки
                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppTheme.paddingM),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red[800]),
                    ),
                  ),

                SizedBox(height: AppTheme.paddingM),

                // Кнопки управления
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Отмена'),
                      ),
                    ),
                    SizedBox(width: AppTheme.paddingM),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _createWallet,
                        child: _isCreating
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text('Создать'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
