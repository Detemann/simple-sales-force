import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/client.dart';
import 'package:http/http.dart' as http;

class ViaCepService {
  Future<Client> fetchAddress(String cep) async {
    final url = Uri.parse('https://viacep.com.br/ws/$cep/json');
    final response = await http.get(url);
    final data = json.decode(response.body);
    return Client(
      id: '',
      name: '',
      type: 'F',
      cpfCnpj: '',
      email: '',
      phone: '',
      cep: data['cep'],
      address: data['logradouro'],
      neighborhood: data['bairro'],
      city: data['localidade'],
      state: data['uf'],
    );
  }
}
