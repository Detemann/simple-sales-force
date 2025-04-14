import 'package:flutter/material.dart';
import 'user_list_screen.dart';
import 'client_list_screen.dart';
import 'product_list_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastros')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Usuários'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserListScreen())),
          ),
          ListTile(
            title: Text('Clientes'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ClientListScreen())),
          ),
          ListTile(
            title: Text('Produtos'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen())),
          ),
        ],
      ),
    );
  }
}
