import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/user_registration_screen.dart';
import 'screens/product_registration_screen.dart';
import 'screens/order_registration_screen.dart';
import 'screens/sync_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SalesApp());
}

class SalesApp extends StatelessWidget {
  const SalesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Força de Venda',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register_user': (_) => const UserRegistrationScreen(),
        '/register_product': (_) => const ProductRegistrationScreen(),
        '/register_order': (_) => const OrderRegistrationScreen(),
        '/sync': (_) => const SyncScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
