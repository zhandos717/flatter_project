import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets'),
      ),
      body: const Center(
        child: Text('Wallets Screen'),
      ),
    );
  }
}