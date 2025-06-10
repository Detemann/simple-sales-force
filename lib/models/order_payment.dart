class OrderPayment {
  final String orderId;
  final String id;
  final double amount;

  OrderPayment({required this.orderId, required this.id, required this.amount});

  Map<String, dynamic> toMap() => {'orderId': orderId, 'id': id, 'amount': amount};

  factory OrderPayment.fromMap(Map<String, dynamic> map) =>
      OrderPayment(orderId: map['orderId'], id: map['id'], amount: map['amount']);
}
