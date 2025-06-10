import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _serverLinkController = TextEditingController();
  String _savedLink = '';

  void _saveSettings() {
    setState(() {
      _savedLink = _serverLinkController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configurações salvas com sucesso!')));
  }

  @override
  void initState() {
    super.initState();
    _serverLinkController.text = _savedLink;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _serverLinkController,
              decoration: const InputDecoration(labelText: 'Link do Servidor', hintText: 'Ex: http://localhost:8080'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveSettings, child: const Text('Salvar Configurações')),
          ],
        ),
      ),
    );
  }
}
