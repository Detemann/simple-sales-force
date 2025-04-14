import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';

class UserController {
  List<User> _users = [];
  int _nextUserId = 1;

  static final UserController _instance = UserController._internal();

  factory UserController() => _instance;

  UserController._internal();

  Future<void> loadUsers() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/users.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      List<dynamic> jsonList = json.decode(contents);
      _users = jsonList.map((json) => User.fromJson(json)).toList();
      _nextUserId = _users.isNotEmpty ? int.parse(_users.last.id) + 1 : 1;
    } else {
      _users.add(User(id: '1', nome: 'admin', senha: 'admin'));
      _nextUserId = 2;
      await saveUsers();
    }
  }

  Future<void> saveUsers() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/users.json');
    await file.writeAsString(json.encode(_users));
  }

  void addUser(String nome, String senha) {
    _users.add(User(id: _nextUserId.toString(), nome: nome, senha: senha));
    _nextUserId++;
    saveUsers();
  }

  void updateUser(String id, String nome, String senha) {
    int index = _users.indexWhere((u) => u.id == id);
    if (index != -1) {
      _users[index] = User(id: id, nome: nome, senha: senha);
      saveUsers();
    }
  }

  void deleteUser(String id) {
    _users.removeWhere((u) => u.id == id);
    saveUsers();
  }

  User? validateUser(String nome, String senha) {
    return _users.firstWhere((u) => u.nome == nome && u.senha == senha);
  }

  List<User> get users => _users;
}
