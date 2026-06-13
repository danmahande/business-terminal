import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final Box<Expense> _box = Hive.box<Expense>('expenses');
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  ExpenseProvider() {
    _loadExpenses();
  }

  void _loadExpenses() {
    _expenses = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _box.put(expense.id, expense);
    _loadExpenses();
  }

  double getExpensesForDate(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    final tomorrow = today.add(const Duration(days: 1));
    return _expenses
        .where((e) => e.date.isAfter(today) && e.date.isBefore(tomorrow))
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}
