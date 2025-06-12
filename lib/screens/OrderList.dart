import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery('''
      SELECT o.id, o.clientId, o.userId, o.total, o.createdAt
      FROM orders o
      WHERE o.deleted = 0
      ORDER BY o.createdAt DESC
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos Cadastrados')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar pedidos: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final orders = snapshot.data!;
            if (orders.isEmpty) {
              return const Center(child: Text('Nenhum pedido encontrado.'));
            }
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text('Pedido #${order['id']}'),
                  subtitle: Text('Total: R\$${order['total']}'),
                  trailing: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(order['createdAt']))),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
