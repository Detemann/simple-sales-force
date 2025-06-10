class OrderItem {
  final String orderId;
  final String id;
  final String productId;
  final double quantity;
  final double total;

  OrderItem({
    required this.orderId,
    required this.id,
    required this.productId,
    required this.quantity,
    required this.total,
  });

  Map<String, dynamic> toMap() => {
    'orderId': orderId,
    'id': id,
    'productId': productId,
    'quantity': quantity,
    'total': total,
  };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
    orderId: map['orderId'],
    id: map['id'],
    productId: map['productId'],
    quantity: map['quantity'],
    total: map['total'],
  );
}
