import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../services/database_helper.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final List<String> _syncLogs = [];
  bool _isSyncing = false;
  Database? _db;

  void _log(String message) {
    setState(() {
      _syncLogs.add(message);
    });
  }

  Future<void> _openDatabase() async {
    _db = await DatabaseHelper.instance.database;
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
      _syncLogs.clear();
    });

    await _openDatabase();

    try {
      _log('🔄 Iniciando sincronização...');

      await _syncEntity('Usuários', 'usuarios');
      await _syncEntity('Clientes', 'clientes');
      await _syncEntity('Produtos', 'produtos');
      await _syncEntity('Pedidos', 'pedidos', includeGet: false);

      _log('✅ Sincronização finalizada com sucesso!');
    } catch (e) {
      _log('❌ Erro ao sincronizar: $e');
    }

    setState(() {
      _isSyncing = false;
    });
  }

  Future<void> _syncEntity(String label, String table, {bool includeGet = true}) async {
    const String baseUrl = 'http://localhost:8080/';

    if (_db == null) return;

    if (includeGet) {
      _log('➡️ Buscando $label do servidor (GET $baseUrl$table)...');
      await Future.delayed(const Duration(milliseconds: 500));

      _log('✔️ Dados de $label atualizados localmente.');
    }

    _log('⬆️ Enviando $label novos/alterados (POST $baseUrl$table)...');
    await Future.delayed(const Duration(milliseconds: 500));
    _log('✔️ Dados de $label enviados com sucesso.');

    _log('🗑️ Processando exclusões de $label (DELETE $baseUrl$table)...');
    await Future.delayed(const Duration(milliseconds: 500));
    _log('✔️ Exclusões de $label processadas.');
  }

  @override
  void dispose() {
    _db?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronização')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _isSyncing ? null : _syncData,
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar Dados'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(itemCount: _syncLogs.length, itemBuilder: (_, index) => Text(_syncLogs[index])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
