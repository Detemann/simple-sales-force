class Client {
  final String id;
  final String nome;
  final String tipo;
  final String cpfCnpj;
  final String? email;
  final String? telefone;
  final String? cep;
  final String? endereco;
  final String? bairro;
  final String? cidade;
  final String? uf;

  Client({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.cpfCnpj,
    this.email,
    this.telefone,
    this.cep,
    this.endereco,
    this.bairro,
    this.cidade,
    this.uf,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'tipo': tipo,
    'cpfCnpj': cpfCnpj,
    'email': email,
    'telefone': telefone,
    'cep': cep,
    'endereco': endereco,
    'bairro': bairro,
    'cidade': cidade,
    'uf': uf,
  };

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nome: json['nome'],
      tipo: json['tipo'],
      cpfCnpj: json['cpfCnpj'],
      email: json['email'],
      telefone: json['telefone'],
      cep: json['cep'],
      endereco: json['endereco'],
      bairro: json['bairro'],
      cidade: json['cidade'],
      uf: json['uf'],
    );
  }
}
