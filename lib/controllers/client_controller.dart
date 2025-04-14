import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/client.dart';

class ClientController {
  List<Client> _clients = [];
  int _nextClientId = 1;

  static final ClientController _instance = ClientController._internal();

  factory ClientController() => _instance;

  ClientController._internal();

  Future<void> loadClients() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/clients.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      List<dynamic> jsonList = json.decode(contents);
      _clients = jsonList.map((json) => Client.fromJson(json)).toList();
      _nextClientId = _clients.isNotEmpty ? int.parse(_clients.last.id) + 1 : 1;
    } else {
      _clients = [];
      _nextClientId = 1;
    }
  }

  Future<void> saveClients() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/clients.json');
    await file.writeAsString(json.encode(_clients));
  }

  void addClient(Client client) {
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
    saveClients();
  }

  void updateClient(Client updatedClient) {
    int index = _clients.indexWhere((c) => c.id == updatedClient.id);
    if (index != -1) {
      _clients[index] = updatedClient;
      saveClients();
    }
  }

  void deleteClient(String id) {
    _clients.removeWhere((c) => c.id == id);
    saveClients();
  }

  List<Client> get clients => _clients;
}
