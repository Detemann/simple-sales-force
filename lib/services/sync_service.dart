import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String _baseUrl = 'http://localhost:8080';

  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  Future<Map<String, List<String>>> syncAll() async {
    final errors = <String, List<String>>{};
    final db = await _dbHelper.database;

    try {
      // Sincronizar usuários
      await _syncEntity('usuarios', 'users', errors);

      // Sincronizar clientes
      await _syncEntity('clientes', 'clients', errors);

      // Sincronizar produtos
      await _syncEntity('produtos', 'products', errors);

      // Sincronizar pedidos (apenas envio)
      await _syncEntity('pedidos', 'orders', errors, includeGet: false);
    } catch (e) {
      errors['geral'] = ['Erro geral na sincronização: $e'];
    }

    return errors;
  }

  Future<void> _syncEntity(
    String endpoint,
    String table,
    Map<String, List<String>> errors, {
    bool includeGet = true,
  }) async {
    final db = await _dbHelper.database;
    final url = '$_baseUrl/$endpoint';

    try {
      // 1. Buscar dados do servidor (GET)
      if (includeGet) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final List<dynamic> serverData = json.decode(response.body);
          final batch = db.batch();

          for (final item in serverData) {
            final lastModified = item['lastModified'] as int?;
            final localItem = await db.query(table, where: 'id = ?', whereArgs: [item['id']]);

            if (localItem.isEmpty || (localItem.first['lastModified'] as int? ?? 0) < (lastModified ?? 0)) {
              batch.insert(table, {...item, 'deleted': 0}, conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }

          await batch.commit();
        } else {
          errors[endpoint] = ['Erro ao buscar dados do servidor: ${response.statusCode}'];
        }
      }

      // 2. Enviar dados novos/alterados (POST)
      final localData = await db.query(table, where: 'lastModified IS NOT NULL AND deleted = ?', whereArgs: [0]);

      if (localData.isNotEmpty) {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(localData),
        );

        if (response.statusCode != 200) {
          errors[endpoint] = ['Erro ao enviar dados para o servidor: ${response.statusCode}'];
        }
      }

      // 3. Processar exclusões (DELETE)
      final deletedItems = await db.query(table, where: 'deleted = ?', whereArgs: [1]);

      for (final item in deletedItems) {
        final response = await http.delete(Uri.parse('$url/${item['id']}'));

        if (response.statusCode == 200) {
          await db.delete(table, where: 'id = ?', whereArgs: [item['id']]);
        } else {
          errors[endpoint] = ['Erro ao excluir item ${item['id']}: ${response.statusCode}'];
        }
      }
    } catch (e) {
      errors[endpoint] = ['Erro ao sincronizar $endpoint: $e'];
    }
  }
}
