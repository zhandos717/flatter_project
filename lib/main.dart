import 'package:finance_app/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/category_provider.dart';
import 'utils/environment_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Установка окружения для API
  EnvironmentConfig.setEnvironment(Environment.local);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'FinTrack',
            theme: ThemeData(
              primarySwatch: Colors.green,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: AppBarTheme(
                elevation: 0,
              ),
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.green,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: AppBarTheme(
                elevation: 0,
              ),
              brightness: Brightness.dark,
            ),
            themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      return LoginScreen();
    }

    return MainScreen();
  }
}
