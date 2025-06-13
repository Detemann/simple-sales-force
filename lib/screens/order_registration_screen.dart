import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';
import '../services/viacep_service.dart';

class OrderRegistrationScreen extends StatefulWidget {
  const OrderRegistrationScreen({super.key});

  @override
  State<OrderRegistrationScreen> createState() => _OrderRegistrationScreenState();
}

class _OrderRegistrationScreenState extends State<OrderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController(text: 'F');
  final _cpfCnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  bool _isLoading = false;

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

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _typeController.dispose();
    _cpfCnpjController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _paymentValueController.dispose();
    super.dispose();
  }

  Future<void> _searchCep() async {
    if (_cepController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final viaCep = ViaCepService();
      final client = await viaCep.fetchAddress(_cepController.text);

      setState(() {
        _addressController.text = client.address ?? '';
        _neighborhoodController.text = client.neighborhood ?? '';
        _cityController.text = client.city ?? '';
        _stateController.text = client.state ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao buscar CEP: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('clients', {
      'id': _idController.text,
      'name': _nameController.text,
      'type': _typeController.text,
      'cpfCnpj': _cpfCnpjController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'cep': _cepController.text,
      'address': _addressController.text,
      'neighborhood': _neighborhoodController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'lastModified': now,
      'deleted': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente salvo com sucesso!')));
    _clearForm();
  }

  void _clearForm() {
    _idController.clear();
    _nameController.clear();
    _typeController.text = 'F';
    _cpfCnpjController.clear();
    _emailController.clear();
    _phoneController.clear();
    _cepController.clear();
    _addressController.clear();
    _neighborhoodController.clear();
    _cityController.clear();
    _stateController.clear();
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
      batch.insert('orders', {
        'id': orderId,
        'clientId': _selectedCustomer!['id'],
        'userId': '1', // TODO: Pegar ID do usuário logado
        'total': _totalItems,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastModified': DateTime.now().millisecondsSinceEpoch,
        'deleted': 0,
      });

      for (final item in _items) {
        batch.insert('order_items', {
          'orderId': orderId,
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'productId': item['product'],
          'quantity': item['quantity'],
          'price': item['price'],
          'total': item['total'],
        });
      }

      for (final payment in _payments) {
        batch.insert('order_payments', {
          'orderId': orderId,
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'value': payment['value'],
        });
      }

      await batch.commit(noResult: true);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido salvo com sucesso!')));

      setState(() {
        _items.clear();
        _payments.clear();
        _totalItems = 0;
        _totalPayments = 0;
        _selectedProduct = null;
        _selectedCustomer = null;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCustomer != null ? _selectedCustomer!['id'].toString() : null,
                decoration: const InputDecoration(labelText: 'Cliente *', hintText: 'Selecione um cliente'),
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
                validator: (value) => value == null ? 'Selecione um cliente' : null,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantidade *'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Preço *'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _addItem, child: const Text('Adicionar')),
                ],
              ),
              const SizedBox(height: 16),
              if (_items.isNotEmpty) ...[
                const Text('Itens do Pedido', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final product = _products.firstWhere((p) => p['id'] == item['product']);
                    return ListTile(
                      title: Text(product['name'] as String),
                      subtitle: Text(
                        '${item['quantity']} x R\$ ${item['price'].toStringAsFixed(2)} = R\$ ${item['total'].toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(index),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Total dos Itens: R\$ ${_totalItems.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Adicionar Pagamento', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _paymentValueController,
                      decoration: const InputDecoration(labelText: 'Valor *'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _addPayment, child: const Text('Adicionar')),
                ],
              ),
              const SizedBox(height: 16),
              if (_payments.isNotEmpty) ...[
                const Text('Pagamentos', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _payments.length,
                  itemBuilder: (context, index) {
                    final payment = _payments[index];
                    return ListTile(
                      title: Text('R\$ ${payment['value'].toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removePayment(index),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Total dos Pagamentos: R\$ ${_totalPayments.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _saveOrder, child: const Text('Salvar Pedido')),
            ],
          ),
        ),
      ),
    );
  }
}
