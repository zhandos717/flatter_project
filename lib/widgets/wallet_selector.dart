import 'package:finance_app/models/wallet.dart';
import 'package:finance_app/providers/wallet_provider.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:finance_app/widgets/create_wallet_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletSelector extends StatefulWidget {
  final Wallet? currentWallet;
  final Function(Wallet) onWalletChanged;
  final int walletType; // Тип кошелька для отображения

  const WalletSelector({
    Key? key,
    this.currentWallet,
    required this.onWalletChanged,
    this.walletType = 1, // По умолчанию показываем обычные кошельки (тип 1)
  }) : super(key: key);

  @override
  _WalletSelectorState createState() => _WalletSelectorState();
}

class _WalletSelectorState extends State<WalletSelector> {
  Wallet? _selectedWallet;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedWallet = widget.currentWallet;
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Проверяем, загружены ли уже кошельки
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      if (walletProvider.wallets.isEmpty) {
        await walletProvider.fetchWallets();
      }

      // Если кошелек не выбран, выбираем первый из списка
      if (_selectedWallet == null && walletProvider.wallets.isNotEmpty) {
        _selectedWallet = walletProvider.wallets.first;
        widget.onWalletChanged(_selectedWallet!);
      }
    } catch (e) {
      print('Error loading wallets: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Показать модальное окно создания кошелька
  void _showCreateWalletModal() {
    showDialog(
      context: context,
      builder: (context) => CreateWalletModal(
        onWalletCreated: () async {
          // Перезагружаем кошельки после создания нового
          final walletProvider =
              Provider.of<WalletProvider>(context, listen: false);
          await walletProvider.fetchWallets();

          // Выбираем новый кошелек (предполагаем, что он первый в списке)
          if (walletProvider.wallets.isNotEmpty) {
            setState(() {
              _selectedWallet = walletProvider.wallets.first;
            });
            widget.onWalletChanged(_selectedWallet!);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        // Фильтруем кошельки по типу
        final wallets = walletProvider.getWalletsByType(widget.walletType);

        if (walletProvider.isLoading || _isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wallets.isEmpty) {
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
                  onPressed: _showCreateWalletModal,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      widget.onWalletChanged(newValue);
                    }
                  },
                  items: wallets.map<DropdownMenuItem<Wallet>>((wallet) {
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
                  onPressed: _showCreateWalletModal,
                  icon: Icon(Icons.add, size: 16),
                  label: Text('Создать новый'),
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppTheme.paddingS),
                    minimumSize: Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
