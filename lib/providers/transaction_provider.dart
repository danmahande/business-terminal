import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final Box<Transaction> _box = Hive.box<Transaction>('transactions');
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  TransactionProvider() {
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactions = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
    _loadTransactions();
  }

  List<Transaction> getTransactionsForDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) => t.date.isAfter(start) && t.date.isBefore(end.add(const Duration(days: 1)))).toList();
  }

  double getTotalSalesForDate(DateTime date) {
    final daily = getTransactionsForDateRange(date, date);
    return daily.fold(0.0, (sum, t) => sum + t.total);
  }
}
