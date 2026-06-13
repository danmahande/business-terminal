import 'package:hive/hive.dart';

part 'purchase_order.g.dart';

@HiveType(typeId: 6)
class PurchaseOrder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? supplier;

  @HiveField(2)
  List<PurchaseOrderItem> items;

  @HiveField(3)
  double total;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String status;

  PurchaseOrder({
    required this.id,
    this.supplier,
    required this.items,
    required this.total,
    required this.date,
    this.status = 'Pending',
  });
}

@HiveType(typeId: 7)
class PurchaseOrderItem extends HiveObject {
  @HiveField(0)
  String productId;

  @HiveField(1)
  String productName;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double? price;

  PurchaseOrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    this.price,
  });
}
