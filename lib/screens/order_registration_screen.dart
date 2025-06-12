import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';

class OrderRegistrationScreen extends StatefulWidget {
  const OrderRegistrationScreen({super.key});

  @override
  State createState() => _OrderRegistrationScreenState();
}

class _OrderRegistrationScreenState extends State<OrderRegistrationScreen> {
  final List<Map<String, dynamic>> _items = [];
  final List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _customers = [];
  Map<String, dynamic>? _selectedCustomer;

  String? _selectedProduct;
  double _totalItems = 0;
  double _totalPayments = 0;

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _paymentValueController = TextEditingController();

  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCustomers();
  }

  Future _loadProducts() async {
    final db = await DatabaseHelper.instance.database;
    final list = await db.query('products', where: 'deleted = ?', whereArgs: [0], orderBy: 'name ASC');
    setState(() {
      _products = list;
    });
  }

  Future<void> _loadCustomers() async {
    final db = await DatabaseHelper.instance.database;
    final customers = await db.query('clients', where: 'deleted = ?', whereArgs: [0], orderBy: 'name');
    setState(() {
      _customers = customers;
    });
  }

  void _addItem() {
    if (_selectedProduct == null) return;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    if (quantity <= 0 || price <= 0) return;
    final total = quantity * price;
    setState(() {
      _items.add({'product': _selectedProduct, 'quantity': quantity, 'price': price, 'total': total});
      _totalItems += total;
    });

    _quantityController.clear();
    _priceController.clear();
  }

  void _removeItem(int index) {
    setState(() {
      _totalItems -= _items[index]['total'];
      _items.removeAt(index);
    });
  }

  void _addPayment() {
    final value = double.tryParse(_paymentValueController.text) ?? 0;
    if (value <= 0) return;
    setState(() {
      _payments.add({'value': value});
      _totalPayments += value;
    });
    _paymentValueController.clear();
  }

  void _removePayment(int index) {
    setState(() {
      _totalPayments -= _payments[index]['value'];
      _payments.removeAt(index);
    });
  }

  void _saveOrder() async {
    if (_items.isEmpty || _payments.isEmpty) {
      _showError("O pedido precisa de pelo menos 1 item e 1 pagamento.");
      return;
    }
    if (_totalItems != _totalPayments) {
      _showError("O total dos pagamentos deve ser igual ao total dos itens.");
      return;
    }

    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      batch.insert('orders', {'id': orderId, 'total': _totalItems, 'createdAt': DateTime.now().microsecondsSinceEpoch});

      for (final item in _items) {
        batch.insert('order_items', {
          'orderId': orderId,
          'clientId': _selectedCustomer!['id'],
          'productId': item['product'],
          'quantity': item['quantity'],
          'price': item['price'],
          'total': item['total'],
        });
      }

      for (final payment in _payments) {
        batch.insert('order_payments', {'orderId': orderId, 'value': payment['value']});
      }

      await batch.commit(noResult: true);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido salvo com sucesso!')));

      setState(() {
        _items.clear();
        _payments.clear();
        _totalItems = 0;
        _totalPayments = 0;
        _selectedProduct = null;
      });
    } catch (e) {
      _showError("Erro ao salvar o pedido: $e");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Pedido')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Adicionar Item', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField(
              value: _selectedProduct,
              decoration: const InputDecoration(labelText: 'Produto *'),
              items: [
                const DropdownMenuItem(value: null, child: Text('-')),
                ..._products.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['name'] as String))),
              ],
              onChanged: (v) => setState(() => _selectedProduct = v),
            ),
            const SizedBox(height: 16),
            const Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedCustomer != null ? _selectedCustomer!['id'].toString() : null,
              decoration: const InputDecoration(
                hintText: 'Selecione um cliente',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('-', style: TextStyle(color: Colors.grey)),
                ),
                ..._customers.map((c) {
                  return DropdownMenuItem<String>(value: c['id'].toString(), child: Text(c['name']));
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCustomer = _customers.firstWhere((c) => c['id'].toString() == value, orElse: () => {});
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantidade *'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Preço *'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _addItem, child: const Text('Adicionar Item')),
            const SizedBox(height: 20),
            const Text('Itens do Pedido'),
            ..._items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return ListTile(
                title: Text(
                  '${_products.firstWhere((p) => p['id'] == item['product'])['name']} - '
                  '${item['quantity']} x R\$${item['price']}',
                ),
                subtitle: Text('Total: R\$${item['total'].toStringAsFixed(2)}'),
                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeItem(i)),
              );
            }).toList(),

            const SizedBox(height: 24),
            const Text('Adicionar Pagamento', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _paymentValueController,
              decoration: const InputDecoration(labelText: 'Valor *'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _addPayment, child: const Text('Adicionar Pagamento')),

            const SizedBox(height: 20),
            const Text('Pagamentos'),
            ..._payments.asMap().entries.map((entry) {
              final i = entry.key;
              final payment = entry.value;
              return ListTile(
                title: Text('R\$${payment['value'].toStringAsFixed(2)}'),
                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _removePayment(i)),
              );
            }).toList(),

            const SizedBox(height: 24),
            Text('Total Itens: R\$${_totalItems.toStringAsFixed(2)}'),
            Text('Total Pagamentos: R\$${_totalPayments.toStringAsFixed(2)}'),

            const SizedBox(height: 16),
            ElevatedButton(onPressed: _saveOrder, child: const Text('Salvar Pedido')),
          ],
        ),
      ),
    );
  }
}
