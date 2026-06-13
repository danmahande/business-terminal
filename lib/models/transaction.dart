import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  double total;

  @HiveField(3)
  String paymentMethod;

  @HiveField(4)
  String? customerPhone;

  @HiveField(5)
  List<TransactionItem> items;
  
  @HiveField(6)
  double? savingsDeducted; // Amount saved from this transaction

  Transaction({
    required this.id,
    required this.date,
    required this.total,
    required this.paymentMethod,
    this.customerPhone,
    required this.items,
    this.savingsDeducted,
  });
}

@HiveType(typeId: 2)
class TransactionItem extends HiveObject {
  @HiveField(0)
  String productId;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double priceAtTime;

  TransactionItem({
    required this.productId,
    required this.quantity,
    required this.priceAtTime,
  });
}
