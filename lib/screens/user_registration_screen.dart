import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../repositories/user_repository.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserRepository _userRepository = UserRepository();

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text.trim();
      final String password = _passwordController.text.trim();

      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        password: password,
        lastModified: DateTime.now().millisecondsSinceEpoch,
        deleted: false,
      );

      await _userRepository.insertUser(newUser);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuário "$name" salvo com sucesso!')));

      _nameController.clear();
      _passwordController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'Senha obrigatória' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _saveUser, child: const Text('Salvar Usuário')),
            ],
          ),
        ),
      ),
    );
  }
}
