import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
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
      SELECT o.id, o.clientId, o.userId, o.total, o.createdAt, c.name as clientName
      FROM orders o
      LEFT JOIN clients c ON o.clientId = c.id
      WHERE o.deleted = 0
      ORDER BY o.createdAt DESC
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Pedidos')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const Center(child: Text('Nenhum pedido encontrado'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final date = DateTime.fromMillisecondsSinceEpoch(int.parse(order['createdAt'].toString()));

              return ListTile(
                title: Text('Pedido #${order['id']}'),
                subtitle: Text(
                  'Cliente: ${order['clientName']}\n'
                  'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}\n'
                  'Total: R\$ ${(order['total'] as num).toStringAsFixed(2)}',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/register_order'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
