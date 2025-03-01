import 'package:file_picker/file_picker.dart';
import 'package:finance_app/models/wallet.dart';
import 'package:finance_app/providers/transaction_provider.dart';
import 'package:finance_app/providers/wallet_provider.dart';
import 'package:finance_app/screens/add_wallet_screen.dart';
import 'package:finance_app/services/api_service.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BankStatementScreen extends StatefulWidget {
  const BankStatementScreen({Key? key}) : super(key: key);

  @override
  _BankStatementScreenState createState() => _BankStatementScreenState();
}

class _BankStatementScreenState extends State<BankStatementScreen> {
  final ApiService _apiService = ApiService();
  bool _isUploading = false;
  String? _error;
  String? _selectedFilePath;
  String? _selectedFileName;

  // Шаг процесса загрузки: 0 - выбор файла, 1 - предпросмотр, 2 - завершено
  int _uploadStep = 0;

  // Данные для предпросмотра
  List<Map<String, dynamic>> _previewTransactions = [];

  // Выбранный кошелек для импорта
  Wallet? _selectedWallet;

  @override
  void initState() {
    super.initState();
    // Загружаем кошельки при инициализации
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    try {
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      if (walletProvider.wallets.isEmpty) {
        await walletProvider
            .fetchWallets(); // Загружаем обычные кошельки (тип 1)
      }
    } catch (e) {
      print('Error loading wallets: $e');
    }
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка выбора файла: $e';
      });
    }
  }

  // Шаг 1: Загрузка и предпросмотр файла
  Future<void> _previewFile() async {
    if (_selectedFilePath == null) {
      setState(() {
        _error = 'Сначала выберите файл для загрузки';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      final result = await _apiService.previewBankStatement(
        _selectedFilePath!,
        _selectedFileName!,
      );

      if (result['success']) {
        // Проверяем, что data — это именно список
        if (result['data'] is List) {
          final List<dynamic> transactionsData = result['data'];

          // Безопасно преобразуем элементы списка в Map<String, dynamic>
          final updatedTransactions = transactionsData.map((item) {
            // Начинаем с пустой Map<String, dynamic>
            Map<String, dynamic> transaction = {};

            // Если это Map, преобразуем каждый ключ в String
            if (item is Map) {
              item.forEach((key, value) {
                // Ключ преобразуем в String
                String stringKey = key.toString();

                // Приводим значения к определенным типам, если знаем их структуру
                if (stringKey == 'date') {
                  transaction[stringKey] = value.toString();
                } else if (stringKey == 'amount') {
                  // Для суммы пытаемся сохранить числовой формат
                  if (value is num) {
                    transaction[stringKey] = value.toString();
                  } else {
                    transaction[stringKey] = value.toString();
                  }
                } else if (stringKey == 'type') {
                  // Для типа, который должен быть int
                  if (value is int) {
                    transaction[stringKey] = value;
                  } else {
                    transaction[stringKey] =
                        int.tryParse(value.toString()) ?? 0;
                  }
                } else {
                  // Все остальные значения преобразуем в строки
                  transaction[stringKey] = value?.toString() ?? '';
                }
              });

              // Добавляем поле selected
              transaction['selected'] = true;
            }

            return transaction;
          }).toList();

          setState(() {
            _previewTransactions =
                List<Map<String, dynamic>>.from(updatedTransactions);
            _uploadStep = 1; // Переход к шагу предпросмотра
            _isUploading = false;
          });
        } else {
          setState(() {
            _error = 'Некорректный формат данных от сервера';
            _isUploading = false;
          });
        }
      } else {
        setState(() {
          _error = result['message'] ?? 'Ошибка предпросмотра файла';
          _isUploading = false;
        });
      }
    } catch (e) {
      print('Ошибка при загрузке файла: $e');
      setState(() {
        _error = 'Ошибка при загрузке файла: $e';
        _isUploading = false;
      });
    }
  }

  // Шаг 2: Создание транзакций из предпросмотра
  Future<void> _createTransactions() async {
    if (_previewTransactions.isEmpty || _selectedWallet == null) {
      setState(() {
        _error = 'Выберите кошелек для импорта транзакций';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      // Фильтруем только выбранные транзакции
      final selectedTransactions = _previewTransactions
          .where((transaction) => transaction['selected'] == true)
          .map((transaction) {
        // Удаляем наш внутренний флаг selected перед отправкой на сервер
        final Map<String, dynamic> apiTransaction = Map.from(transaction);
        apiTransaction.remove('selected');
        return apiTransaction;
      }).toList();

      if (selectedTransactions.isEmpty) {
        setState(() {
          _error = 'Выберите хотя бы одну транзакцию для импорта';
          _isUploading = false;
        });
        return;
      }

      final walletId = _selectedWallet!.id;

      final result = await _apiService.createTransactionsFromStatement(
        walletId as int,
        selectedTransactions,
      );

      if (result['success']) {
        // Обновляем список транзакций, если загрузка успешна
        await Provider.of<TransactionProvider>(context, listen: false)
            .fetchTransactions();

        setState(() {
          _uploadStep = 2; // Успешное завершение
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Транзакции успешно импортированы'),
            backgroundColor: Colors.green,
          ),
        );

        // Через небольшую задержку сбрасываем состояние для нового импорта
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _resetUploadState();
            });
          }
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Ошибка создания транзакций';
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка при создании транзакций: $e';
        _isUploading = false;
      });
    }
  }

  // Сброс состояния после загрузки или при отмене
  void _resetUploadState() {
    setState(() {
      _selectedFilePath = null;
      _selectedFileName = null;
      _previewTransactions = [];
      _selectedWallet = null;
      _uploadStep = 0;
      _error = null;
    });
  }

  // Изменение состояния выбора транзакции
  void _toggleTransactionSelection(int index, bool value) {
    setState(() {
      _previewTransactions[index]['selected'] = value;
    });
  }

  // Выбор всех транзакций
  void _selectAllTransactions(bool value) {
    setState(() {
      for (var transaction in _previewTransactions) {
        transaction['selected'] = value;
      }
    });
  }

  // Открытие экрана создания кошелька
  void _openAddWalletScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWalletScreen(),
      ),
    );

    if (result == true) {
      // Если кошелек был создан, обновляем список
      await _loadWallets();
      // Проверяем, загрузились ли кошельки и выбираем первый
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      if (walletProvider.wallets.isNotEmpty && _selectedWallet == null) {
        setState(() {
          _selectedWallet = walletProvider.wallets.first;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Импорт транзакций'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Блок загрузки выписки
              _buildUploadCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    // В зависимости от текущего шага загрузки показываем соответствующий UI
    switch (_uploadStep) {
      case 0: // Шаг выбора файла
        return _buildFileSelectionStep();
      case 1: // Шаг предпросмотра транзакций
        return _buildPreviewStep();
      case 2: // Шаг успешного завершения
        return _buildSuccessStep();
      default:
        return _buildFileSelectionStep();
    }
  }

  // Шаг 0: Выбор файла для загрузки
  Widget _buildFileSelectionStep() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Загрузить новую выписку',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppTheme.paddingM),
            Text(
              'Поддерживаемые форматы: CSV, XLSX, XLS, PDF',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: AppTheme.paddingM),

            // Отображение выбранного файла
            if (_selectedFilePath != null)
              Container(
                padding: EdgeInsets.all(AppTheme.paddingS),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: AppTheme.paddingS),
                    Expanded(
                      child: Text(
                        _selectedFileName ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedFilePath = null;
                          _selectedFileName = null;
                        });
                      },
                    ),
                  ],
                ),
              ),

            SizedBox(height: AppTheme.paddingM),

            // Кнопки выбора и загрузки файла
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.file_upload),
                    label: Text('Выбрать файл'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      elevation: 0,
                    ),
                    onPressed: _isUploading ? null : _selectFile,
                  ),
                ),
                SizedBox(width: AppTheme.paddingM),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.visibility),
                    label: Text(_isUploading ? 'Загрузка...' : 'Предпросмотр'),
                    onPressed: _isUploading ? null : _previewFile,
                  ),
                ),
              ],
            ),

            // Отображение ошибки
            if (_error != null) _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  // Шаг 1: Предпросмотр и выбор транзакций
  Widget _buildPreviewStep() {
    if (_previewTransactions.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.paddingM),
          child: Column(
            children: [
              Text(
                'Нет данных для предпросмотра',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: AppTheme.paddingM),
              ElevatedButton(
                onPressed: _resetUploadState,
                child: Text('Вернуться к выбору файла'),
              ),
            ],
          ),
        ),
      );
    }

    // Вычисление количества выбранных транзакций и общей суммы
    final selectedCount = _previewTransactions
        .where((transaction) => transaction['selected'] == true)
        .length;

    final totalAmount = _previewTransactions
        .where((transaction) => transaction['selected'] == true)
        .fold(0.0, (total, transaction) {
      return total + double.parse(transaction['amount'].toString());
    });

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с информацией о файле
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Предпросмотр выписки',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: _resetUploadState,
                  tooltip: 'Отменить и вернуться к выбору файла',
                ),
              ],
            ),

            // Информация о выбранном файле
            if (_selectedFileName != null)
              Padding(
                padding: EdgeInsets.only(bottom: AppTheme.paddingS),
                child: Text(
                  'Файл: $_selectedFileName',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),

            // Информация о количестве найденных транзакций
            Padding(
              padding: EdgeInsets.only(bottom: AppTheme.paddingM),
              child: Text(
                'Найдено ${_previewTransactions.length} транзакций',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),

            // Выбор кошелька для импорта
            Padding(
              padding: EdgeInsets.only(bottom: AppTheme.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Выберите кошелек для импорта:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppTheme.paddingS),
                  Consumer<WalletProvider>(
                    builder: (context, walletProvider, child) {
                      final wallets = walletProvider
                          .getWalletsByType(1); // Тип 1 - обычные кошельки

                      if (walletProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (wallets.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(AppTheme.paddingM),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusS),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.amber[700]),
                              SizedBox(width: AppTheme.paddingS),
                              Expanded(
                                child: Text(
                                  'Сначала создайте кошелек',
                                  style: TextStyle(color: Colors.amber[900]),
                                ),
                              ),
                              TextButton(
                                child: Text('Создать'),
                                onPressed: _openAddWalletScreen,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // Выпадающий список кошельков
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusS),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Wallet>(
                                value: _selectedWallet,
                                isExpanded: true,
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppTheme.paddingM),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusS),
                                hint: Text('Выберите кошелек'),
                                onChanged: (Wallet? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedWallet = newValue;
                                    });
                                  }
                                },
                                items: wallets
                                    .map<DropdownMenuItem<Wallet>>((wallet) {
                                  // Получение цвета кошелька
                                  String colorStr = wallet.color;
                                  // Если цвет начинается с #, преобразуем его в формат 0xFF...
                                  if (colorStr.startsWith('#')) {
                                    colorStr = '0xFF${colorStr.substring(1)}';
                                  }

                                  Color walletColor;
                                  try {
                                    walletColor = Color(int.parse(colorStr));
                                  } catch (e) {
                                    walletColor = Colors.grey;
                                  }

                                  return DropdownMenuItem<Wallet>(
                                    value: wallet,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: walletColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: AppTheme.paddingS),
                                        Text(wallet.name),
                                        SizedBox(width: AppTheme.paddingS),
                                        Text(
                                          wallet.balanceAsDouble
                                              .toStringAsFixed(2),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          // Кнопка "Создать новый кошелек"
                          Padding(
                            padding: EdgeInsets.only(top: AppTheme.paddingS),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _openAddWalletScreen,
                                icon: Icon(Icons.add, size: 16),
                                label: Text('Создать новый'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: AppTheme.paddingS),
                                  minimumSize: Size(0, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Чекбокс "Выбрать все"
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppTheme.paddingS),
              child: Row(
                children: [
                  Checkbox(
                    value: _previewTransactions
                        .every((t) => t['selected'] == true),
                    onChanged: (value) {
                      _selectAllTransactions(value ?? true);
                    },
                  ),
                  Text('Выбрать все транзакции'),
                  Spacer(),
                  Text(
                    'Выбрано: $selectedCount из ${_previewTransactions.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Общая сумма выбранных транзакций
            Padding(
              padding: EdgeInsets.only(
                left: AppTheme.paddingM,
                bottom: AppTheme.paddingM,
              ),
              child: Text(
                'Общая сумма: ${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: totalAmount >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ),

            // Список транзакций для предпросмотра
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              height: 300, // Фиксированная высота для списка
              child: ListView.builder(
                itemCount: _previewTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = _previewTransactions[index];
                  return _buildTransactionPreviewItem(transaction, index);
                },
              ),
            ),

            SizedBox(height: AppTheme.paddingM),

            // Кнопки для управления импортом
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetUploadState,
                    child: Text('Отмена'),
                  ),
                ),
                SizedBox(width: AppTheme.paddingM),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text(_isUploading ? 'Импорт...' : 'Импортировать'),
                    onPressed: _isUploading ? null : _createTransactions,
                  ),
                ),
              ],
            ),

            // Отображение ошибки
            if (_error != null) _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  // Шаг 2: Успешное завершение импорта
  Widget _buildSuccessStep() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 48,
            ),
            SizedBox(height: AppTheme.paddingM),
            Text(
              'Транзакции успешно импортированы',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppTheme.paddingM),
            Text(
              'Транзакции добавлены в выбранный кошелек.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.paddingL),
            ElevatedButton(
              onPressed: _resetUploadState,
              child: Text('Импортировать ещё'),
            ),
          ],
        ),
      ),
    );
  }

  // Элемент списка для предпросмотра транзакции
  Widget _buildTransactionPreviewItem(
      Map<String, dynamic> transaction, int index) {
    // Форматирование даты (можно добавить более сложное форматирование)
    String displayDate = transaction['date'].toString().split('T')[0];

    // Определение типа транзакции (расход/доход)
    bool isExpense = transaction['type'] == 2;
    String typeText = isExpense ? 'Расход' : 'Доход';
    Color amountColor = isExpense ? Colors.red : Colors.green;

    String amountText = '${isExpense ? '-' : '+'} ${transaction['amount']}';

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              // Чекбокс для выбора транзакции
              Checkbox(
                value: transaction['selected'] ?? true,
                onChanged: (value) {
                  _toggleTransactionSelection(index, value ?? false);
                },
              ),

              // Иконка типа транзакции
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                  color: amountColor,
                  size: 16,
                ),
              ),
              SizedBox(width: 12),

              // Название и источник транзакции
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      transaction['source'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      displayDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Сумма транзакции
              Text(
                amountText,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),
      ],
    );
  }

  // Отображение сообщения об ошибке
  Widget _buildErrorMessage() {
    return Padding(
      padding: EdgeInsets.only(top: AppTheme.paddingM),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppTheme.paddingM),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
          border: Border.all(
            color: Colors.red[300]!,
          ),
        ),
        child: Text(
          _error!,
          style: TextStyle(
            color: Colors.red[800],
          ),
        ),
      ),
    );
  }
}
