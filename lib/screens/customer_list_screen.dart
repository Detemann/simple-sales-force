import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<Map<String, dynamic>> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final db = await DatabaseHelper.instance.database;
    final customers = await db.query('clients', where: 'deleted = ?', whereArgs: [0], orderBy: 'name');

    setState(() {
      _customers = customers;
    });
  }

  Future<void> _deleteCustomer(String id) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'customers',
      {'deleted': 1, 'lastModified': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente excluído')));

    _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Clientes')),
      body: _customers.isEmpty
          ? const Center(child: Text('Nenhum cliente cadastrado.'))
          : ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                return ListTile(
                  title: Text(customer['name']),
                  subtitle: Text(customer['email'] ?? 'Sem e-mail'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCustomer(customer['id']),
                  ),
                );
              },
            ),
    );
  }
}
