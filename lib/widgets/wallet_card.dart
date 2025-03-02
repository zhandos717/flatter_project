import 'package:finance_app/models/wallet.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class WalletCard extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const WalletCard({
    Key? key,
    required this.wallet,
    required this.onTap,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Получаем цвет из строки hex
    Color walletColor;
    try {
      walletColor = Color(int.parse(wallet.color.replaceAll('#', '0xFF')));
    } catch (e) {
      walletColor = Colors.blue; // Цвет по умолчанию
    }

    // Получаем иконку кошелька
    IconData walletIcon;
    if (wallet.icon != null) {
      final iconIndex = int.tryParse(wallet.icon!) ?? 0;
      switch (iconIndex) {
        case 1:
          walletIcon = Icons.account_balance_wallet;
          break;
        case 2:
          walletIcon = Icons.credit_card;
          break;
        case 3:
          walletIcon = Icons.savings;
          break;
        case 4:
          walletIcon = Icons.attach_money;
          break;
        case 5:
          walletIcon = Icons.account_balance;
          break;
        case 6:
          walletIcon = Icons.shopping_bag;
          break;
        case 7:
          walletIcon = Icons.euro;
          break;
        case 8:
          walletIcon = Icons.payment;
          break;
        default:
          walletIcon = Icons.account_balance_wallet;
      }
    } else {
      walletIcon = Icons.account_balance_wallet;
    }

    // Вычисляем прогресс для целевого кошелька
    double progress = 0.0;
    if (wallet.typeAsInt == Wallet.TargetType &&
        wallet.desiredBalance != null) {
      final targetAmount = double.tryParse(wallet.desiredBalance!) ?? 0.0;
      if (targetAmount > 0) {
        progress = wallet.balanceAsDouble / targetAmount;
        // Ограничиваем прогресс до 100%
        progress = progress > 1.0 ? 1.0 : progress;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                walletColor.withOpacity(0.1),
                walletColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхняя часть с информацией о кошельке
              Padding(
                padding: EdgeInsets.all(AppTheme.paddingM),
                child: Row(
                  children: [
                    // Иконка кошелька
                    Container(
                      padding: EdgeInsets.all(AppTheme.paddingM),
                      decoration: BoxDecoration(
                        color: walletColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        walletIcon,
                        color: walletColor,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: AppTheme.paddingM),
                    // Название и баланс
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wallet.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${wallet.balanceAsDouble.toStringAsFixed(2)} ₸',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (wallet.typeAsInt == Wallet.TargetType &&
                                  wallet.desiredBalance != null) ...[
                                Text(
                                  ' / ${double.tryParse(wallet.desiredBalance!)?.toStringAsFixed(2) ?? '0.00'} ₸',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Кнопка редактирования
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                      ),
                      onPressed: onEdit,
                    ),
                  ],
                ),
              ),

              // Прогресс-бар для целевого кошелька
              if (wallet.typeAsInt == Wallet.TargetType) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Прогресс:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: walletColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(walletColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTheme.paddingM),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
