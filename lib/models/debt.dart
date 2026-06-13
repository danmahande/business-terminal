import 'package:hive/hive.dart';

part 'debt.g.dart';

@HiveType(typeId: 3)
class Debt extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String customerName;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  String status;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  List<DebtPayment> payments;
  
  @HiveField(8)
  String? customerPhone;

  Debt({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.date,
    this.dueDate,
    this.status = 'Current',
    this.notes,
    this.payments = const [],
    this.customerPhone,
  });

  double get remainingAmount {
    double paid = payments.fold(0, (sum, payment) => sum + payment.amount);
    return amount - paid;
  }
}

@HiveType(typeId: 4)
class DebtPayment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  DebtPayment({
    required this.id,
    required this.amount,
    required this.date,
  });
}
