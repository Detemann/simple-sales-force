import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  _SyncScreenState createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final _apiService = ApiService();
  bool _isLoading = false;
  String _status = '';

  Future<void> _syncData() async {
    setState(() {
      _isLoading = true;
      _status = 'Iniciando sincronização...';
    });

    try {
      // Sincronizar usuários
      _status = 'Sincronizando usuários...';
      final users = await _apiService.getUsers();
      final db = await DatabaseHelper.instance.database;
      for (final user in users) {
        await db.insert('users', {
          'id': user['id'].toString(),
          'name': user['nome'],
          'password': user['senha'],
          'lastModified': DateTime.parse(user['ultimaAlteracao']).millisecondsSinceEpoch,
          'deleted': 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Sincronizar clientes
      _status = 'Sincronizando clientes...';
      final clients = await _apiService.getClients();
      for (final client in clients) {
        await db.insert('clients', {
          'id': client['id'].toString(),
          'name': client['nome'],
          'type': client['tipo'],
          'document': client['cpfCnpj'],
          'email': client['email'],
          'phone': client['telefone'],
          'zipCode': client['cep'],
          'address': client['endereco'],
          'neighborhood': client['bairro'],
          'city': client['cidade'],
          'state': client['uf'],
          'lastModified': DateTime.parse(client['ultimaAlteracao']).millisecondsSinceEpoch,
          'deleted': 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Sincronizar produtos
      _status = 'Sincronizando produtos...';
      final products = await _apiService.getProducts();
      for (final product in products) {
        await db.insert('products', {
          'id': product['id'].toString(),
          'name': product['nome'],
          'barcode': product['codigoBarra'],
          'unit': product['unidade'],
          'stock': product['qtdEstoque'],
          'cost': product['custo'],
          'price': product['precoVenda'],
          'status': product['Status'],
          'lastModified': DateTime.parse(product['ultimaAlteracao']).millisecondsSinceEpoch,
          'deleted': 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Sincronizar pedidos
      _status = 'Sincronizando pedidos...';
      final orders = await _apiService.getOrders();
      for (final order in orders) {
        // Inserir pedido
        await db.insert('orders', {
          'id': order['id'].toString(),
          'clientId': order['idCliente'].toString(),
          'userId': order['idUsuario'].toString(),
          'total': order['totalPedido'],
          'createdAt': DateTime.parse(order['ultimaAlteracao']).millisecondsSinceEpoch,
          'deleted': 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        // Inserir itens do pedido
        for (final item in order['itens']) {
          await db.insert('order_items', {
            'id': item['id'].toString(),
            'orderId': item['idPedido'].toString(),
            'productId': item['idProduto'].toString(),
            'quantity': item['quantidade'],
            'total': item['totalItem'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        // Inserir pagamentos do pedido
        for (final payment in order['pagamentos']) {
          await db.insert('order_payments', {
            'id': payment['id'].toString(),
            'orderId': payment['idPedido'].toString(),
            'amount': payment['valor'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Atualizar última sincronização
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastSync', DateTime.now().millisecondsSinceEpoch);

      setState(() {
        _status = 'Sincronização concluída com sucesso!';
      });
    } catch (e) {
      setState(() {
        _status = 'Erro na sincronização: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronização')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(onPressed: _syncData, child: const Text('Sincronizar Dados')),
            const SizedBox(height: 20),
            Text(_status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
