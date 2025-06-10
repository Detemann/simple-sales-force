class Product {
  final String id;
  final String name;
  final String unit;
  final double stockQty;
  final double price;
  final int status;
  final double? cost;
  final String? barcode;
  final int? lastModified;
  final bool deleted;

  Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.stockQty,
    required this.price,
    required this.status,
    this.cost,
    this.barcode,
    this.lastModified,
    this.deleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'unit': unit,
    'stockQty': stockQty,
    'price': price,
    'status': status,
    'cost': cost,
    'barcode': barcode,
    'lastModified': lastModified,
    'deleted': deleted ? 1 : 0,
  };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
    id: map['id'],
    name: map['name'],
    unit: map['unit'],
    stockQty: map['stockQty'],
    price: map['price'],
    status: map['status'],
    cost: map['cost'],
    barcode: map['barcode'],
    lastModified: map['lastModified'],
    deleted: map['deleted'] == 1,
  );
}
