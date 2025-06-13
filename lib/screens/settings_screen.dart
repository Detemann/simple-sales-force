import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _serverLinkController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper.instance.database;
      final settings = await db.query('settings', where: 'key = ?', whereArgs: ['server_url']);
      if (settings.isNotEmpty) {
        _serverLinkController.text = settings.first['value'] as String;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar configurações: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (_serverLinkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URL do servidor é obrigatória')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('settings', {
        'key': 'server_url',
        'value': _serverLinkController.text,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configurações salvas com sucesso!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar configurações: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _serverLinkController,
                    decoration: const InputDecoration(
                      labelText: 'Link do Servidor',
                      hintText: 'Ex: http://localhost:8080',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _saveSettings, child: const Text('Salvar Configurações')),
                ],
              ),
            ),
    );
  }
}
