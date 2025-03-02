import 'package:finance_app/models/wallet.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class WalletTypeFilter extends StatelessWidget {
  final int selectedType;
  final Function(int) onTypeChanged;

  const WalletTypeFilter({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: AppTheme.paddingM, vertical: AppTheme.paddingS),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      elevation: 0.5,
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingS),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.paddingS),
          child: Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  title: 'Обычный',
                  subtitle: 'Для повседневных трат',
                  icon: Icons.account_balance_wallet,
                  type: Wallet.OrdinaryType,
                  isSelected: selectedType == Wallet.OrdinaryType,
                ),
              ),
              Expanded(
                child: _buildTypeButton(
                  title: 'Целевой',
                  subtitle: 'Для накоплений',
                  icon: Icons.savings,
                  type: Wallet.TargetType,
                  isSelected: selectedType == Wallet.TargetType,
                ),
              ),
            ],
          ),
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
      onTap: () => onTypeChanged(type),
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
              size: 28,
            ),
            SizedBox(height: AppTheme.paddingXS),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
