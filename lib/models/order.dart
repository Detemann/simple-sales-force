import 'order_item.dart';
import 'order_payment.dart';

class Order {
  final String id;
  final String clientId;
  final String userId;
  final double total;
  final int createdAt;
  final int? lastModified;
  final bool deleted;
  final List<OrderItem>? items;
  final List<OrderPayment>? payments;

  Order({
    required this.id,
    required this.clientId,
    required this.userId,
    required this.total,
    required this.createdAt,
    this.lastModified,
    this.deleted = false,
    this.items,
    this.payments,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'clientId': clientId,
    'userId': userId,
    'total': total,
    'createdAt': createdAt,
    'lastModified': lastModified,
    'deleted': deleted ? 1 : 0,
  };

  factory Order.fromMap(Map<String, dynamic> map) => Order(
    id: map['id'],
    clientId: map['clientId'],
    userId: map['userId'],
    total: map['total'],
    createdAt: map['createdAt'],
    lastModified: map['lastModified'],
    deleted: map['deleted'] == 1,
  );
}
