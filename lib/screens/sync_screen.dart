import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../services/database_helper.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final List<String> _syncLogs = [];
  bool _isSyncing = false;
  final SyncService _syncService = SyncService();

  void _log(String message) {
    setState(() {
      _syncLogs.add(message);
    });
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
      _syncLogs.clear();
    });

    try {
      _log('🔄 Iniciando sincronização...');

      // Carregar URL do servidor das configurações
      final db = await DatabaseHelper.instance.database;
      final settings = await db.query('settings', where: 'key = ?', whereArgs: ['server_url']);
      if (settings.isNotEmpty) {
        _syncService.setBaseUrl(settings.first['value'] as String);
      }

      // Realizar sincronização
      final errors = await _syncService.syncAll();

      if (errors.isEmpty) {
        _log('✅ Sincronização finalizada com sucesso!');
      } else {
        _log('⚠️ Sincronização finalizada com erros:');
        errors.forEach((entity, entityErrors) {
          _log('  $entity:');
          for (final error in entityErrors) {
            _log('    - $error');
          }
        });
      }
    } catch (e) {
      _log('❌ Erro ao sincronizar: $e');
    }

    setState(() {
      _isSyncing = false;
    });
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
