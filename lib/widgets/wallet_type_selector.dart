import 'package:finance_app/models/wallet.dart';
import 'package:flutter/material.dart';

class WalletTypeSelector extends StatelessWidget {
  final int selectedType;
  final Function(int) onTypeChanged;

  const WalletTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

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
            child: Row(
              children: [
                _buildTypeCard(
                  context: context,
                  title: 'Обычный',
                  subtitle: 'Для повседневных трат',
                  icon: Icons.account_balance_wallet,
                  type: Wallet.OrdinaryType,
                  isSelected: selectedType == Wallet.OrdinaryType,
                ),
                const SizedBox(width: 12),
                _buildTypeCard(
                  context: context,
                  title: 'Целевой',
                  subtitle: 'Для накоплений',
                  icon: Icons.savings,
                  type: Wallet.TargetType,
                  isSelected: selectedType == Wallet.TargetType,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required int type,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue.shade400 : Colors.grey.shade200,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
                  size: 28,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color:
                      isSelected ? Colors.blue.shade800 : Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
