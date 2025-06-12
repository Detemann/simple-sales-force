import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';

class ProductEditScreen extends StatefulWidget {
  final String productId;

  const ProductEditScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductEditScreenState createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _stockQtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _statusController = TextEditingController();
  final _costController = TextEditingController();
  final _barcodeController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future _loadProduct() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [widget.productId]);
    if (maps.isNotEmpty) {
      final prod = maps.first;
      _idController.text = prod['id'] as String;
      _nameController.text = prod['name'] as String;
      _unitController.text = prod['unit'] as String;
      _stockQtyController.text = (prod['stockQty'] as num).toString();
      _priceController.text = (prod['price'] as num).toString();
      _statusController.text = (prod['status'] as int).toString();
      _costController.text = prod['cost'] != null ? (prod['cost'] as num).toString() : '';
      _barcodeController.text = prod['barcode'] as String? ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future _updateProduct() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'products',
      {
        'name': _nameController.text,
        'unit': _unitController.text,
        'stockQty': double.parse(_stockQtyController.text),
        'price': double.parse(_priceController.text),
        'status': int.parse(_statusController.text),
        'cost': _costController.text.isNotEmpty ? double.parse(_costController.text) : null,
        'barcode': _barcodeController.text.isNotEmpty ? _barcodeController.text : null,
        'lastModified': now,
      },
      where: 'id = ?',
      whereArgs: [widget.productId],
    );

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto atualizado com sucesso!')));

    Navigator.pushReplacementNamed(context, '/products');
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _unitController.dispose();
    _stockQtyController.dispose();
    _priceController.dispose();
    _statusController.dispose();
    _costController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Produto')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(labelText: 'ID'),
                      enabled: false,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nome *'),
                      validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(labelText: 'Unidade *'),
                      validator: (v) => v == null || v.isEmpty ? 'Informe a unidade' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _stockQtyController,
                      decoration: const InputDecoration(labelText: 'Qtd. Estoque *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Informe a quantidade' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Preço de Venda *'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v == null || v.isEmpty ? 'Informe o preço' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _statusController,
                      decoration: const InputDecoration(labelText: 'Status (0 Ativo / 1 Inativo) *'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe o status';
                        final val = int.tryParse(v);
                        if (val == null || (val != 0 && val != 1)) return 'Status inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _costController,
                      decoration: const InputDecoration(labelText: 'Custo'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(labelText: 'Código de Barra'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: _updateProduct, child: const Text('Atualizar Produto')),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
