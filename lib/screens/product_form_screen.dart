import 'package:flutter/material.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  ProductFormScreen({this.product});

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _unidadeController = TextEditingController();
  final _qtdEstoqueController = TextEditingController();
  final _precoVendaController = TextEditingController();
  final _statusController = TextEditingController();
  final _custoController = TextEditingController();
  final _codigoBarraController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nomeController.text = widget.product!.nome;
      _unidadeController.text = widget.product!.unidade;
      _qtdEstoqueController.text = widget.product!.qtdEstoque.toString();
      _precoVendaController.text = widget.product!.precoVenda.toString();
      _statusController.text = widget.product!.status.toString();
      _custoController.text = widget.product!.custo?.toString() ?? '';
      _codigoBarraController.text = widget.product!.codigoBarra ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? 'Novo Produto' : 'Editar Produto')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nomeController, 'Nome*'),
              DropdownButtonFormField<String>(
                value: _unidadeController.text.isNotEmpty ? _unidadeController.text : null,
                items:
                    ['un', 'cx', 'kg', 'lt', 'ml'].map((unidade) {
                      return DropdownMenuItem(value: unidade, child: Text(unidade.toUpperCase()));
                    }).toList(),
                onChanged: (value) => _unidadeController.text = value!,
                decoration: InputDecoration(labelText: 'Unidade*'),
                validator: (value) => value == null ? 'Selecione a unidade' : null,
              ),
              _buildNumberField(_qtdEstoqueController, 'Quantidade Estoque*'),
              _buildNumberField(_precoVendaController, 'Preço Venda*'),
              DropdownButtonFormField<int>(
                value: _statusController.text.isNotEmpty ? int.parse(_statusController.text) : null,
                items: [
                  DropdownMenuItem(value: 0, child: Text('Ativo')),
                  DropdownMenuItem(value: 1, child: Text('Inativo')),
                ],
                onChanged: (value) => _statusController.text = value!.toString(),
                decoration: InputDecoration(labelText: 'Status*'),
                validator: (value) => value == null ? 'Selecione o status' : null,
              ),
              _buildNumberField(_custoController, 'Custo', optional: true),
              _buildTextField(_codigoBarraController, 'Código de Barras'),
              ElevatedButton(child: Text('Salvar'), onPressed: _saveProduct),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool validate = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: validate ? null : _validateRequired,
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label, {bool optional = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: optional ? null : _validateNumber,
    );
  }

  String? _validateRequired(String? value) {
    return value == null || value.isEmpty ? 'Campo obrigatório' : null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) return 'Campo obrigatório';
    if (double.tryParse(value) == null) return 'Valor inválido';
    return null;
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id ?? '',
        nome: _nomeController.text,
        unidade: _unidadeController.text,
        qtdEstoque: int.parse(_qtdEstoqueController.text),
        precoVenda: double.parse(_precoVendaController.text),
        status: int.parse(_statusController.text),
        custo: _custoController.text.isNotEmpty ? double.parse(_custoController.text) : null,
        codigoBarra: _codigoBarraController.text.isNotEmpty ? _codigoBarraController.text : null,
      );

      if (widget.product == null) {
        ProductController().addProduct(product);
      } else {
        ProductController().updateProduct(product.copyWith(id: widget.product!.id));
      }
      Navigator.pop(context);
    }
  }
}

extension ProductCopyWith on Product {
  Product copyWith({String? id}) {
    return Product(
      id: id ?? this.id,
      nome: this.nome,
      unidade: this.unidade,
      qtdEstoque: this.qtdEstoque,
      precoVenda: this.precoVenda,
      status: this.status,
      custo: this.custo,
      codigoBarra: this.codigoBarra,
    );
  }
}
