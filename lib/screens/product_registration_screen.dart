import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trabalhon3/services/database_helper.dart';

class ProductRegistrationScreen extends StatefulWidget {
  const ProductRegistrationScreen({super.key});

  @override
  State<ProductRegistrationScreen> createState() => _ProductRegistrationScreenState();
}

class _ProductRegistrationScreenState extends State<ProductRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _stockQtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('products', {
      'id': _idController.text,
      'name': _nameController.text,
      'unit': _unitController.text,
      'stockQty': double.parse(_stockQtyController.text),
      'price': double.parse(_priceController.text),
      'status': int.parse(_statusController.text),
      'cost': _costController.text.isNotEmpty ? double.parse(_costController.text) : null,
      'barcode': _barcodeController.text.isNotEmpty ? _barcodeController.text : null,
      'lastModified': now,
      'deleted': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto salvo com sucesso!')));

    Navigator.pushReplacementNamed(context, '/products');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'ID *'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome *'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unidade (un, cx, kg, lt, ml) *'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _stockQtyController,
                decoration: const InputDecoration(labelText: 'Quantidade em Estoque *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (double.tryParse(value) == null) return 'Valor inválido';
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Preço de Venda *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (double.tryParse(value) == null) return 'Valor inválido';
                  return null;
                },
              ),
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: 'Status (0 - Ativo / 1 - Inativo) *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (!(value == '0' || value == '1')) return 'Use 0 ou 1';
                  return null;
                },
              ),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Custo'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(labelText: 'Código de Barras'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveProduct, child: const Text('Salvar Produto')),
            ],
          ),
        ),
      ),
    );
  }
}
