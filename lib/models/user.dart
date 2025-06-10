class User {
  final String id;
  final String name;
  final String password;
  final int? lastModified;
  final bool deleted;

  User({required this.id, required this.name, required this.password, this.lastModified, this.deleted = false});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'password': password,
    'lastModified': lastModified,
    'deleted': deleted ? 1 : 0,
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    name: map['name'],
    password: map['password'],
    lastModified: map['lastModified'],
    deleted: map['deleted'] == 1,
  );
}
