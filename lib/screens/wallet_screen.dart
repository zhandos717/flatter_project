import 'package:finance_app/providers/wallet_provider.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:finance_app/widgets/wallet_analytics_tab.dart';
import 'package:finance_app/widgets/wallet_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_wallet_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      if (walletProvider.wallets.isEmpty) {
        walletProvider.fetchWallets(type: 1); // 1 - обычные кошельки
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddWalletDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const AddWalletScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildAppBar(innerBoxIsScrolled),
      ],
      body: TabBarView(
        controller: _tabController,
        children: const [
          WalletTab(),
          WalletAnalyticsTab(),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      floating: true,
      snap: true,
      forceElevated: innerBoxIsScrolled,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(18),
        child: _buildTabBar(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      heroTag: 'buttonAdd',
      onPressed: _showAddWalletDialog,
      backgroundColor: AppTheme.primaryColor,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).cardColor,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryColor,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(
            icon: Icon(Icons.account_balance_wallet, size: 16),
            text: 'Мои кошельки',
            iconMargin: EdgeInsets.only(bottom: 2),
          ),
          Tab(
            icon: Icon(Icons.bar_chart, size: 16),
            text: 'Динамика',
            iconMargin: EdgeInsets.only(bottom: 2),
          ),
        ],
      ),
    );
  }
}
