import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';
import '../services/viacep_service.dart';

class CustomerRegistrationScreen extends StatefulWidget {
  const CustomerRegistrationScreen({super.key});

  @override
  State<CustomerRegistrationScreen> createState() => _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState extends State<CustomerRegistrationScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Cliente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'ID *'),
                validator: (value) => value?.isEmpty ?? true ? 'ID é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome *'),
                validator: (value) => value?.isEmpty ?? true ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _typeController.text,
                decoration: const InputDecoration(labelText: 'Tipo *'),
                items: const [
                  DropdownMenuItem(value: 'F', child: Text('Física')),
                  DropdownMenuItem(value: 'J', child: Text('Jurídica')),
                ],
                onChanged: (value) => setState(() => _typeController.text = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cpfCnpjController,
                decoration: InputDecoration(labelText: _typeController.text == 'F' ? 'CPF *' : 'CNPJ *'),
                validator: (value) => value?.isEmpty ?? true ? 'CPF/CNPJ é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cepController,
                      decoration: const InputDecoration(labelText: 'CEP'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _searchCep,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Buscar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Endereço'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _neighborhoodController,
                decoration: const InputDecoration(labelText: 'Bairro'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'Cidade'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(labelText: 'UF'),
                      maxLength: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _saveCustomer, child: const Text('Salvar Cliente')),
            ],
          ),
        ),
      ),
    );
  }
}
