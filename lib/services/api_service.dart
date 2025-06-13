import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  // Usuários
  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/usuarios'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['dados']);
    }
    throw Exception('Falha ao carregar usuários');
  }

  Future<Map<String, dynamic>> getUser(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/usuarios/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Falha ao carregar usuário');
  }

  // Clientes
  Future<List<Map<String, dynamic>>> getClients() async {
    final response = await http.get(Uri.parse('$baseUrl/clientes'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['dados']);
    }
    throw Exception('Falha ao carregar clientes');
  }

  Future<Map<String, dynamic>> getClient(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/clientes/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Falha ao carregar cliente');
  }

  // Produtos
  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/produtos'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['dados']);
    }
    throw Exception('Falha ao carregar produtos');
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/produtos/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Falha ao carregar produto');
  }

  // Pedidos
  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/pedidos'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['dados']);
    }
    throw Exception('Falha ao carregar pedidos');
  }

  Future<Map<String, dynamic>> getOrder(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/pedidos/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Falha ao carregar pedido');
  }
}
