import 'dart:convert';
import 'dart:io';
import '../models/client.dart';

class ClientController {
  List<Client> _clients = [];
  int _nextClientId = 1;
  static const String _fileName = 'clients.json';
  static const String _androidDataPath = '/data/data/com.example.appmobile/files';

  static final ClientController _instance = ClientController._internal();

  factory ClientController() => _instance;

  ClientController._internal();

  Future<File> get _localFile async {
    final directory = Directory(_androidDataPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}/$_fileName');
  }

  Future<void> loadClients() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        List<dynamic> jsonList = json.decode(contents);
        _clients = jsonList.map((json) => Client.fromJson(json)).toList();
        _nextClientId = _clients.isNotEmpty ? int.parse(_clients.last.id) + 1 : 1;
      }
    } catch (e) {
      print('Erro ao carregar clientes: $e');
      _clients = [];
      _nextClientId = 1;
    }
  }

  Future<void> saveClients() async {
    try {
      final file = await _localFile;
      await file.writeAsString(json.encode(_clients));
    } catch (e) {
      print('Erro ao salvar clientes: $e');
      throw Exception('Não foi possível salvar os clientes: $e');
    }
  }

  Future<void> addClient(Client client) async {
    _clients.add(
      Client(
        id: _nextClientId.toString(),
        nome: client.nome,
        tipo: client.tipo,
        cpfCnpj: client.cpfCnpj,
        email: client.email,
        telefone: client.telefone,
        cep: client.cep,
        endereco: client.endereco,
        bairro: client.bairro,
        cidade: client.cidade,
        uf: client.uf,
      ),
    );
    _nextClientId++;
    await saveClients();
  }

  Future<void> updateClient(Client updatedClient) async {
    final index = _clients.indexWhere((c) => c.id == updatedClient.id);
    if (index != -1) {
      _clients[index] = updatedClient;
      await saveClients();
    }
  }

  Future<void> deleteClient(String id) async {
    _clients.removeWhere((c) => c.id == id);
    await saveClients();
  }

  List<Client> get clients => _clients;
}
