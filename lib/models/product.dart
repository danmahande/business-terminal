import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  int stockQuantity;

  @HiveField(4)
  int stockLimit;

  @HiveField(5)
  String? category;

  @HiveField(6)
  String? barcode;

  @HiveField(7)
  String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.stockQuantity = 0,
    this.stockLimit = 5,
    this.category,
    this.barcode,
    this.imagePath,
  });
}
