import 'package:flutter/material.dart';
import '../../controllers/user_controller.dart';
import '../../models/user.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;

  UserFormScreen({this.user});

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nomeController.text = widget.user!.nome;
      _senhaController.text = widget.user!.senha;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user == null ? 'Novo Usuário' : 'Editar Usuário')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value!.isEmpty ? 'Nome é obrigatório' : null,
              ),
              TextFormField(
                controller: _senhaController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Senha é obrigatória' : null,
              ),
              ElevatedButton(child: Text('Salvar'), onPressed: _saveUser),
            ],
          ),
        ),
      ),
    );
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      if (widget.user == null) {
        UserController().addUser(_nomeController.text, _senhaController.text);
      } else {
        UserController().updateUser(widget.user!.id, _nomeController.text, _senhaController.text);
      }
      Navigator.pop(context);
    }
  }
}
