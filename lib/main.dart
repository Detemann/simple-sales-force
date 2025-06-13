import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trabalhon3/screens/ProductEdit.dart';
import 'package:trabalhon3/screens/customer_list_screen.dart';
import 'package:trabalhon3/screens/customer_registration_screen.dart';
import 'package:trabalhon3/screens/product_screen.dart';
import 'package:trabalhon3/services/database_helper.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/user_registration_screen.dart';
import 'screens/product_registration_screen.dart';
import 'screens/order_registration_screen.dart';
import 'screens/order_list_screen.dart';
import 'screens/sync_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  runApp(const SalesApp());
}

class SalesApp extends StatelessWidget {
  const SalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Força de Venda',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/register_user': (_) => const UserRegistrationScreen(),
        '/register_product': (_) => const ProductRegistrationScreen(),
        '/register_order': (_) => const OrderRegistrationScreen(),
        '/register_client': (_) => const CustomerRegistrationScreen(),
        '/sync': (_) => const SyncScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/products': (_) => const ProductScreen(),
        '/edit_product': (ctx) {
          final id = ModalRoute.of(ctx)!.settings.arguments as String;
          return ProductEditScreen(productId: id);
        },
        '/orders': (_) => const OrderListScreen(),
        '/clients': (_) => const CustomerListScreen(),
      },
    );
  }
}
