import 'package:finance_app/models/wallet.dart';
import 'package:flutter/material.dart';

class WalletType {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const WalletType({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class WalletTypeSelector extends StatelessWidget {
  final int selectedType;
  final Function(int) onTypeChanged;

  WalletTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  // Определение доступных типов кошельков
  final List<WalletType> walletTypes = [
    WalletType(
      id: Wallet.OrdinaryType,
      title: 'Обычный',
      subtitle: 'Для повседневных трат',
      icon: Icons.account_balance_wallet,
      color: Colors.blue,
    ),
    WalletType(
      id: Wallet.TargetType,
      title: 'Целевой',
      subtitle: 'Для накоплений',
      icon: Icons.savings,
      color: Colors.green,
    ),
    WalletType(
      id: 3,
      // Вы можете добавить новый тип в класс Wallet, например, InvestmentType = 3
      title: 'Инвестиционный',
      subtitle: 'Для инвестиций',
      icon: Icons.trending_up,
      color: Colors.purple,
    ),
    WalletType(
      id: 4,
      // CreditType = 4
      title: 'Кредитный',
      subtitle: 'Для учета кредитов',
      icon: Icons.credit_card,
      color: Colors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            'Тип кошелька',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildTypeCard(context, walletTypes[0]),
                    const SizedBox(width: 12),
                    _buildTypeCard(context, walletTypes[1]),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTypeCard(context, walletTypes[2]),
                    const SizedBox(width: 12),
                    _buildTypeCard(context, walletTypes[3]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard(BuildContext context, WalletType type) {
    final isSelected = selectedType == type.id;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(type.id),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isSelected ? type.color.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? type.color : Colors.grey.shade200,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? type.color.withOpacity(0.2)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  type.icon,
                  color: isSelected ? type.color : Colors.grey.shade600,
                  size: 28,
                ),
              ),
              SizedBox(height: 12),
              Text(
                type.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isSelected ? type.color : Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                type.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? type.color.withOpacity(0.8)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
