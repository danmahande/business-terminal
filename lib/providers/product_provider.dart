import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final Box<Product> _box = Hive.box<Product>('products');
  List<Product> _products = [];

  List<Product> get products => _products;
  List<Product> get lowStockProducts =>
      _products.where((p) => p.stockQuantity <= p.stockLimit).toList();

  ProductProvider() {
    _loadProducts();
  }

  void _loadProducts() {
    _products = _box.values.toList();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _box.put(product.id, product);
    _loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await product.save();
    _loadProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _box.delete(id);
    _loadProducts();
  }

  Product? getProductById(String id) {
    try {
      return _box.get(id);
    } catch (e) {
      return null;
    }
  }

  List<Product> searchProducts(String query) {
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            (p.barcode != null && p.barcode!.contains(query)))
        .toList();
  }
}
