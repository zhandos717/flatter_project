import 'package:finance_app/models/wallet.dart';
import 'package:finance_app/providers/wallet_provider.dart';
import 'package:finance_app/screens/add_wallet_screen.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:finance_app/widgets/wallet_card.dart';
import 'package:finance_app/widgets/wallet_type_filter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({Key? key}) : super(key: key);

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  // По умолчанию показываем обычные кошельки
  int _selectedWalletType = Wallet.OrdinaryType;

  @override
  void initState() {
    super.initState();
    // Загружаем кошельки при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false)
          .loadWallets(_selectedWalletType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок с названием раздела
            Padding(
              padding: EdgeInsets.all(AppTheme.paddingM),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  SizedBox(width: AppTheme.paddingS),
                  Text(
                    'Мои кошельки',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () => _addNewWallet(context),
                  ),
                ],
              ),
            ),

            // Фильтр типов кошельков
            WalletTypeFilter(
              selectedType: _selectedWalletType,
              onTypeChanged: (type) {
                setState(() {
                  _selectedWalletType = type;
                });
                // Перезагружаем кошельки с новым типом
                Provider.of<WalletProvider>(context, listen: false)
                    .loadWallets(_selectedWalletType);
              },
            ),

            // Итоговая сумма по кошелькам выбранного типа
            Consumer<WalletProvider>(
              builder: (context, provider, _) {
                // Вычисляем общую сумму
                double totalBalance = 0;
                for (var wallet in provider.wallets) {
                  totalBalance += wallet.balanceAsDouble;
                }

                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingM,
                    vertical: AppTheme.paddingS,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingM,
                    vertical: AppTheme.paddingS,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    color: Colors.blue.shade50,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Общий баланс:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Text(
                        '${totalBalance.toStringAsFixed(2)} ₸',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: AppTheme.paddingS),

            // Список кошельков
            Expanded(
              child: _buildWalletsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewWallet(context),
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildWalletsList() {
    return Consumer<WalletProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade300,
                ),
                SizedBox(height: AppTheme.paddingM),
                Text(
                  'Ошибка загрузки: ${provider.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade300),
                ),
                SizedBox(height: AppTheme.paddingM),
                ElevatedButton(
                  onPressed: () {
                    provider.loadWallets(_selectedWalletType);
                  },
                  child: Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (provider.wallets.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadWallets(_selectedWalletType);
          },
          child: ListView.builder(
            padding: EdgeInsets.all(AppTheme.paddingM),
            itemCount: provider.wallets.length,
            itemBuilder: (context, index) {
              final wallet = provider.wallets[index];
              return Padding(
                padding: EdgeInsets.only(bottom: AppTheme.paddingM),
                child: WalletCard(
                  wallet: wallet,
                  onTap: () => _openWalletDetails(context, wallet),
                  onEdit: () => _editWallet(context, wallet),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedWalletType == Wallet.OrdinaryType
                ? Icons.account_balance_wallet_outlined
                : Icons.savings_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: AppTheme.paddingM),
          Text(
            _selectedWalletType == Wallet.OrdinaryType
                ? 'У вас пока нет обычных кошельков'
                : 'У вас пока нет целевых кошельков',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.paddingM),
          ElevatedButton.icon(
            onPressed: () => _addNewWallet(context),
            icon: Icon(Icons.add),
            label: Text(_selectedWalletType == Wallet.OrdinaryType
                ? 'Добавить обычный кошелек'
                : 'Добавить целевой кошелек'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.paddingM,
                vertical: AppTheme.paddingS,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Открытие экрана добавления кошелька
  void _addNewWallet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWalletScreen(
          initialType: _selectedWalletType,
        ),
      ),
    ).then((_) {
      // Обновляем список после добавления
      Provider.of<WalletProvider>(context, listen: false)
          .loadWallets(_selectedWalletType);
    });
  }

  // Открытие экрана деталей кошелька
  void _openWalletDetails(BuildContext context, Wallet wallet) {
    // Тут будет переход на экран деталей кошелька
    // Navigator.push(context, MaterialPageRoute(builder: (context) => WalletDetailsScreen(wallet: wallet)));
  }

  // Открытие экрана редактирования кошелька
  void _editWallet(BuildContext context, Wallet wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWalletScreen(wallet: wallet),
      ),
    ).then((_) {
      // Обновляем список после редактирования
      Provider.of<WalletProvider>(context, listen: false)
          .loadWallets(_selectedWalletType);
    });
  }
}
