import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/purchase_order.dart';

class PurchaseOrderProvider extends ChangeNotifier {
  final Box<PurchaseOrder> _box = Hive.box<PurchaseOrder>('purchase_orders');
  List<PurchaseOrder> _orders = [];

  List<PurchaseOrder> get orders => _orders;

  PurchaseOrderProvider() {
    _loadOrders();
  }

  void _loadOrders() {
    _orders = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addOrder(PurchaseOrder order) async {
    await _box.put(order.id, order);
    _loadOrders();
  }

  Future<void> updateOrder(PurchaseOrder order) async {
    await order.save();
    _loadOrders();
  }
}
