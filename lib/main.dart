import 'package:flutter/material.dart';
import 'controllers/client_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/user_controller.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa controladores e carrega dados
  await UserController().loadUsers();
  await ClientController().loadClients();
  await ProductController().loadProducts();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Força de Vendas',
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
