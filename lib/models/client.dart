class Client {
  final String id;
  final String name;
  final String type;
  final String cpfCnpj;
  final String? email;
  final String? phone;
  final String? cep;
  final String? address;
  final String? neighborhood;
  final String? city;
  final String? state;
  final int? lastModified;
  final bool deleted;

  Client({
    required this.id,
    required this.name,
    required this.type,
    required this.cpfCnpj,
    this.email,
    this.phone,
    this.cep,
    this.address,
    this.neighborhood,
    this.city,
    this.state,
    this.lastModified,
    this.deleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'cpfCnpj': cpfCnpj,
    'email': email,
    'phone': phone,
    'cep': cep,
    'address': address,
    'neighborhood': neighborhood,
    'city': city,
    'state': state,
    'lastModified': lastModified,
    'deleted': deleted ? 1 : 0,
  };

  factory Client.fromMap(Map<String, dynamic> map) => Client(
    id: map['id'],
    name: map['name'],
    type: map['type'],
    cpfCnpj: map['cpfCnpj'],
    email: map['email'],
    phone: map['phone'],
    cep: map['cep'],
    address: map['address'],
    neighborhood: map['neighborhood'],
    city: map['city'],
    state: map['state'],
    lastModified: map['lastModified'],
    deleted: map['deleted'] == 1,
  );
}
