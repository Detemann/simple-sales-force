import 'package:flutter/material.dart';
import '../../controllers/client_controller.dart';
import '../../models/client.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;

  ClientFormScreen({this.client});

  @override
  _ClientFormScreenState createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _tipoController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _nomeController.text = widget.client!.nome;
      _tipoController.text = widget.client!.tipo;
      _cpfCnpjController.text = widget.client!.cpfCnpj;
      _emailController.text = widget.client!.email ?? '';
      _telefoneController.text = widget.client!.telefone ?? '';
      _cepController.text = widget.client!.cep ?? '';
      _enderecoController.text = widget.client!.endereco ?? '';
      _bairroController.text = widget.client!.bairro ?? '';
      _cidadeController.text = widget.client!.cidade ?? '';
      _ufController.text = widget.client!.uf ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.client == null ? 'Novo Cliente' : 'Editar Cliente')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nomeController, 'Nome*', validator: _validateRequired),
              DropdownButtonFormField<String>(
                value: _tipoController.text.isNotEmpty ? _tipoController.text : null,
                items:
                    ['F', 'J'].map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo == 'F' ? 'Pessoa Física' : 'Pessoa Jurídica'),
                      );
                    }).toList(),
                onChanged: (value) => _tipoController.text = value!,
                decoration: InputDecoration(labelText: 'Tipo*'),
                validator: (value) => value == null ? 'Selecione o tipo' : null,
              ),
              _buildTextField(_cpfCnpjController, 'CPF/CNPJ*', validator: _validateRequired),
              _buildTextField(_emailController, 'E-mail'),
              _buildTextField(_telefoneController, 'Telefone'),
              _buildTextField(_cepController, 'CEP'),
              _buildTextField(_enderecoController, 'Endereço'),
              _buildTextField(_bairroController, 'Bairro'),
              _buildTextField(_cidadeController, 'Cidade'),
              _buildTextField(_ufController, 'UF'),
              ElevatedButton(child: Text('Salvar'), onPressed: _saveClient),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {String? Function(String?)? validator}) {
    return TextFormField(controller: controller, decoration: InputDecoration(labelText: label), validator: validator);
  }

  String? _validateRequired(String? value) {
    return value == null || value.isEmpty ? 'Campo obrigatório' : null;
  }

  void _saveClient() {
    if (_formKey.currentState!.validate()) {
      final client = Client(
        id: widget.client?.id ?? '',
        nome: _nomeController.text,
        tipo: _tipoController.text,
        cpfCnpj: _cpfCnpjController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        telefone: _telefoneController.text.isNotEmpty ? _telefoneController.text : null,
        cep: _cepController.text.isNotEmpty ? _cepController.text : null,
        endereco: _enderecoController.text.isNotEmpty ? _enderecoController.text : null,
        bairro: _bairroController.text.isNotEmpty ? _bairroController.text : null,
        cidade: _cidadeController.text.isNotEmpty ? _cidadeController.text : null,
        uf: _ufController.text.isNotEmpty ? _ufController.text : null,
      );

      if (widget.client == null) {
        ClientController().addClient(client);
      } else {
        ClientController().updateClient(client.copyWith(id: widget.client!.id));
      }
      Navigator.pop(context);
    }
  }
}

extension ClientCopyWith on Client {
  Client copyWith({String? id}) {
    return Client(
      id: id ?? this.id,
      nome: this.nome,
      tipo: this.tipo,
      cpfCnpj: this.cpfCnpj,
      email: this.email,
      telefone: this.telefone,
      cep: this.cep,
      endereco: this.endereco,
      bairro: this.bairro,
      cidade: this.cidade,
      uf: this.uf,
    );
  }
}
