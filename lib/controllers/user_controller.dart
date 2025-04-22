import 'dart:convert';
import 'dart:io';
import '../models/user.dart';

class UserController {
  List<User> _users = [];
  int _nextUserId = 1;
  static const String _fileName = 'users.json';
  static const String _androidDataPath = '/data/data/com.example.appmobile/files';
  bool _initialized = false;

  static final UserController _instance = UserController._internal();

  factory UserController() => _instance;

  UserController._internal();

  Future<File> get _localFile async {
    final directory = Directory(_androidDataPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}/$_fileName');
  }

  Future<void> _initialize() async {
    if (_initialized) return;

    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonList = json.decode(contents) as List;
        _users = jsonList.map((json) => User.fromJson(json)).toList();
      } else {
        _users = [User(id: '1', nome: 'admin', senha: 'admin')];
        await file.writeAsString(json.encode(_users));
      }

      _nextUserId = _users.isNotEmpty ? _users.map((u) => int.parse(u.id)).reduce((a, b) => a > b ? a : b) + 1 : 1;

      _initialized = true;
    } catch (e) {
      print('Erro na inicialização: $e');
      _users = [User(id: '1', nome: 'admin', senha: 'admin')];
      _nextUserId = 2;
      _initialized = true;
    }
  }

  Future<void> loadUsers() async {
    await _initialize();
  }

  Future<void> saveUsers() async {
    try {
      final file = await _localFile;
      await file.writeAsString(json.encode(_users));
    } catch (e) {
      print('Erro ao salvar usuários: $e');
      throw Exception('Falha ao salvar usuários: $e');
    }
  }

  Future<void> addUser(String nome, String senha) async {
    _users.add(User(id: _nextUserId.toString(), nome: nome, senha: senha));
    _nextUserId++;
    await saveUsers();
  }

  Future<void> updateUser(String id, String nome, String senha) async {
    final index = _users.indexWhere((u) => u.id == id);
    if (index != -1) {
      _users[index] = User(id: id, nome: nome, senha: senha);
      await saveUsers();
    }
  }

  Future<void> deleteUser(String id) async {
    _users.removeWhere((u) => u.id == id);
    await saveUsers();
  }

  User? validateUser(String nome, String senha) {
    try {
      return _users.firstWhere((u) => u.nome == nome && u.senha == senha);
    } catch (e) {
      return null;
    }
  }

  List<User> get users => _users;

  Future<void> clearAllUsers() async {
    _users = _users.where((u) => u.id == '1').toList();
    _nextUserId = 2;
    await saveUsers();
  }

  Future<String> getDebugPath() async {
    final file = await _localFile;
    return file.path;
  }
}
