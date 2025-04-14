class Product {
  final String id;
  final String nome;
  final String unidade;
  final int qtdEstoque;
  final double precoVenda;
  final int status;
  final double? custo;
  final String? codigoBarra;

  Product({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.qtdEstoque,
    required this.precoVenda,
    required this.status,
    this.custo,
    this.codigoBarra,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'unidade': unidade,
    'qtdEstoque': qtdEstoque,
    'precoVenda': precoVenda,
    'status': status,
    'custo': custo,
    'codigoBarra': codigoBarra,
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nome: json['nome'],
      unidade: json['unidade'],
      qtdEstoque: json['qtdEstoque'],
      precoVenda: json['precoVenda'].toDouble(),
      status: json['status'],
      custo: json['custo']?.toDouble(),
      codigoBarra: json['codigoBarra'],
    );
  }
}
