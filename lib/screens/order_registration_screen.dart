import 'package:flutter/material.dart';

class OrderRegistrationScreen extends StatefulWidget {
  const OrderRegistrationScreen({super.key});

  @override
  State<OrderRegistrationScreen> createState() => _OrderRegistrationScreenState();
}

class _OrderRegistrationScreenState extends State<OrderRegistrationScreen> {
  final List<Map<String, dynamic>> _items = [];
  final List<Map<String, dynamic>> _payments = [];

  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final TextEditingController _paymentValueController = TextEditingController();

  double _totalItems = 0;
  double _totalPayments = 0;

  void _addItem() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;

    if (_productController.text.isEmpty || quantity <= 0 || price <= 0) return;

    final total = quantity * price;

    setState(() {
      _items.add({'product': _productController.text, 'quantity': quantity, 'price': price, 'total': total});
      _totalItems += total;
    });

    _productController.clear();
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

  void _saveOrder() {
    if (_items.isEmpty || _payments.isEmpty) {
      _showError("O pedido precisa de pelo menos 1 item e 1 pagamento.");
      return;
    }

    if (_totalItems != _totalPayments) {
      _showError("O total dos pagamentos deve ser igual ao total dos itens.");
      return;
    }

    // Aqui você pode salvar os dados no banco de dados (SQLite) ou enviar para API
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido salvo com sucesso!')));

    setState(() {
      _items.clear();
      _payments.clear();
      _totalItems = 0;
      _totalPayments = 0;
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            TextField(
              controller: _productController,
              decoration: const InputDecoration(labelText: 'Produto'),
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantidade'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Preço'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(onPressed: _addItem, child: const Text('Adicionar Item')),

            const SizedBox(height: 16),
            const Text('Itens do Pedido'),
            ..._items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return ListTile(
                title: Text('${item['product']} - ${item['quantity']} x R\$${item['price']}'),
                subtitle: Text('Total: R\$${item['total'].toStringAsFixed(2)}'),
                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeItem(i)),
              );
            }),

            const SizedBox(height: 24),
            const Text('Adicionar Pagamento', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _paymentValueController,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(onPressed: _addPayment, child: const Text('Adicionar Pagamento')),

            const SizedBox(height: 16),
            const Text('Pagamentos'),
            ..._payments.asMap().entries.map((entry) {
              final i = entry.key;
              final payment = entry.value;
              return ListTile(
                title: Text('R\$${payment['value'].toStringAsFixed(2)}'),
                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _removePayment(i)),
              );
            }),

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
