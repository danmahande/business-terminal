import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/debt.dart';

class DebtProvider extends ChangeNotifier {
  final Box<Debt> _box = Hive.box<Debt>('debts');
  List<Debt> _debts = [];

  List<Debt> get debts => _debts;
  List<Debt> get unpaidDebts => _debts.where((d) => d.remainingAmount > 0).toList();
  double get totalUnpaid => unpaidDebts.fold(0.0, (sum, d) => sum + d.remainingAmount);

  DebtProvider() {
    _loadDebts();
  }

  void _loadDebts() {
    _debts = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addDebt(Debt debt) async {
    await _box.put(debt.id, debt);
    _loadDebts();
  }

  Future<void> updateDebt(Debt debt) async {
    await debt.save();
    _loadDebts();
  }

  Future<void> addPayment(Debt debt, DebtPayment payment) async {
    debt.payments.add(payment);
    if (debt.remainingAmount <= 0) {
      debt.status = 'Paid';
    }
    await debt.save();
    _loadDebts();
  }
}
