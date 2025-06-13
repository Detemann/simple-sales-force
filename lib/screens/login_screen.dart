import 'package:flutter/material.dart';
import 'package:trabalhon3/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final id = _idController.text;
    final password = _passwordController.text;
    final user = await UserRepository().authenticate(id, password);

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', user.name);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID ou senha inválidos')));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo ID
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'ID', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Informe o ID' : null,
              ),
              const SizedBox(height: 16),
              // Campo Senha
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty ? 'Informe a senha' : null,
              ),
              const SizedBox(height: 24),
              // Botão Login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Entrar'),
                ),
              ),
              const SizedBox(height: 8),
              // Link para cadastro de usuário
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register_user'),
                child: const Text('Cadastrar novo usuário'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
