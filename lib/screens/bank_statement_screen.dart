import 'package:file_picker/file_picker.dart';
import 'package:finance_app/models/transaction_preview.dart';
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
  bool _isLoading = false;
  String? _error;
  String? _selectedFilePath;
  String? _selectedFileName;

  // Шаг процесса загрузки: 0 - выбор файла, 1 - предпросмотр, 2 - завершено
  int _currentStep = 0;

  // Данные для предпросмотра
  StatementPreview? _statementPreview;

  // Выбранный кошелек для импорта
  Wallet? _selectedWallet;

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Проверяем, если provider уже загружен и есть кошельки, выбираем первый
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    if (walletProvider.wallets.isNotEmpty && _selectedWallet == null) {
      _selectedWallet = walletProvider.wallets.first;
    }
  }

  Future<void> _loadWallets() async {
    try {
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      if (walletProvider.wallets.isEmpty) {
        await walletProvider.fetchWallets(
            type: 1); // Загружаем обычные кошельки (тип 1)
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
          _error = null;
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
      _isLoading = true;
      _error = null;
    });

    try {
      final preview = await _apiService.previewBankStatement(
        _selectedFilePath!,
        _selectedFileName!,
      );

      if (preview != null) {
        setState(() {
          _statementPreview = preview;
          _currentStep = 1; // Переход к шагу предпросмотра
        });
      } else {
        setState(() {
          _error = 'Не удалось получить предпросмотр банковской выписки';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка при загрузке файла: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Шаг 2: Создание транзакций из предпросмотра
  Future<void> _createTransactions() async {
    if (_statementPreview == null ||
        _statementPreview!.transactions.isEmpty ||
        _selectedWallet == null) {
      setState(() {
        _error = 'Выберите кошелек и транзакции для импорта';
      });
      return;
    }

    final selectedTransactions = _statementPreview!.selectedTransactions;
    if (selectedTransactions.isEmpty) {
      setState(() {
        _error = 'Выберите хотя бы одну транзакцию для импорта';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _apiService.importTransactionsFromPreview(
        _selectedWallet!.id!,
        _statementPreview!,
      );

      if (result) {
        // Обновляем список транзакций, если загрузка успешна
        await Provider.of<TransactionProvider>(context, listen: false)
            .fetchTransactions();

        setState(() {
          _currentStep = 2; // Успешное завершение
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
            _resetUploadState();
          }
        });
      } else {
        setState(() {
          _error = 'Ошибка импорта транзакций';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка при создании транзакций: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Сброс состояния после загрузки или при отмене
  void _resetUploadState() {
    setState(() {
      _selectedFilePath = null;
      _selectedFileName = null;
      _statementPreview = null;
      _currentStep = 0;
      _error = null;
    });
  }

  // Изменение состояния выбора транзакции
  void _toggleTransactionSelection(int index, bool value) {
    setState(() {
      _statementPreview!.transactions[index].selected = value;
    });
  }

  // Выбор всех транзакций
  void _selectAllTransactions(bool value) {
    setState(() {
      for (var transaction in _statementPreview!.transactions) {
        transaction.selected = value;
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

      // Проверяем, загрузились ли кошельки и выбираем первый, если еще не выбран
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
      body: _isLoading && _currentStep != 1
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Блок загрузки выписки
                    _buildCurrentStepWidget(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
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
            if (_selectedFilePath != null) _buildSelectedFileIndicator(),

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
                    onPressed: _isLoading ? null : _selectFile,
                  ),
                ),
                SizedBox(width: AppTheme.paddingM),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.visibility),
                    label: Text(_isLoading ? 'Загрузка...' : 'Предпросмотр'),
                    onPressed: _isLoading || _selectedFilePath == null
                        ? null
                        : _previewFile,
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

  Widget _buildSelectedFileIndicator() {
    return Container(
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
    );
  }

  // Шаг 1: Предпросмотр и выбор транзакций
  Widget _buildPreviewStep() {
    if (_statementPreview == null || _statementPreview!.transactions.isEmpty) {
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
    final selectedCount = _statementPreview!.selectedTransactions.length;
    final totalAmount = _statementPreview!.selectedTransactions
        .fold(0.0, (total, transaction) => total + transaction.amount);
    final totalTransactions = _statementPreview!.transactions.length;

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
            _buildPreviewHeader(),

            // Информация о количестве найденных транзакций
            Padding(
              padding: EdgeInsets.only(bottom: AppTheme.paddingM),
              child: Text(
                'Найдено $totalTransactions транзакций',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),

            // Выбор кошелька для импорта
            _buildWalletSelector(),

            // Чекбокс "Выбрать все" и информация о выбранных транзакциях
            _buildSelectionControls(
                selectedCount, totalTransactions, totalAmount),

            // Список транзакций для предпросмотра
            _buildTransactionsList(),

            SizedBox(height: AppTheme.paddingM),

            // Кнопки для управления импортом
            _buildActionButtons(),

            // Отображение ошибки
            if (_error != null) _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewHeader() {
    return Row(
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
    );
  }

  Widget _buildWalletSelector() {
    return Padding(
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
              final wallets = walletProvider.getWalletsByType(1);

              if (walletProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (wallets.isEmpty) {
                return _buildNoWalletsWarning();
              }

              return _buildWalletDropdown(wallets);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoWalletsWarning() {
    return Container(
      padding: EdgeInsets.all(AppTheme.paddingM),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
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

  Widget _buildWalletDropdown(List<Wallet> wallets) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Wallet>(
              value: _selectedWallet,
              isExpanded: true,
              padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingM),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
              hint: Text('Выберите кошелек'),
              onChanged: (Wallet? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedWallet = newValue;
                  });
                }
              },
              items: wallets.map<DropdownMenuItem<Wallet>>((wallet) {
                Color walletColor = _parseWalletColor(wallet.color);

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
                        wallet.balanceAsDouble.toStringAsFixed(2),
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
                padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingS),
                minimumSize: Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionControls(
      int selectedCount, int totalTransactions, double totalAmount) {
    return Column(
      children: [
        // Чекбокс "Выбрать все"
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppTheme.paddingS),
          child: Row(
            children: [
              Checkbox(
                value: _statementPreview!.transactions.every((t) => t.selected),
                onChanged: (value) {
                  _selectAllTransactions(value ?? true);
                },
              ),
              Text('Выбрать все транзакции'),
              Spacer(),
              Text(
                'Выбрано: $selectedCount из $totalTransactions',
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
      ],
    );
  }

  Widget _buildTransactionsList() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      height: 300, // Фиксированная высота для списка
      child: ListView.builder(
        itemCount: _statementPreview!.transactions.length,
        itemBuilder: (context, index) {
          final transaction = _statementPreview!.transactions[index];
          return _buildTransactionPreviewItem(transaction, index);
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
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
            label: Text(_isLoading ? 'Импорт...' : 'Импортировать'),
            onPressed: _isLoading ? null : _createTransactions,
          ),
        ),
      ],
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
      TransactionPreview transaction, int index) {
    // Форматирование даты (можно добавить более сложное форматирование)
    String displayDate = transaction.date.split('T')[0];

    // Определение типа транзакции (расход/доход)
    bool isExpense = transaction.type == 2;
    Color amountColor = isExpense ? Colors.red : Colors.green;

    String amountText = '${isExpense ? '-' : '+'} ${transaction.amount}';

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              // Чекбокс для выбора транзакции
              Checkbox(
                value: transaction.selected,
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
                      transaction.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      transaction.source,
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

  // Утилиты
  Color _parseWalletColor(String colorStr) {
    try {
      if (colorStr.startsWith('#')) {
        return Color(int.parse('0xFF${colorStr.substring(1)}'));
      } else if (colorStr.startsWith('0x')) {
        return Color(int.parse(colorStr));
      }
      return Color(int.parse('0xFF$colorStr'));
    } catch (e) {
      return Colors.grey;
    }
  }
}
