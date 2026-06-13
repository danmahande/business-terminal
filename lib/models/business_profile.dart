import 'package:hive/hive.dart';

part 'business_profile.g.dart';

@HiveType(typeId: 8)
class BusinessProfile extends HiveObject {
  @HiveField(0)
  String? shopName;

  @HiveField(1)
  String? tin;

  @HiveField(2)
  String? category;

  @HiveField(3)
  int? yearsOperating;

  @HiveField(4)
  String? phone;

  @HiveField(5)
  String? email;

  @HiveField(6)
  String? location;

  @HiveField(7)
  String? logoPath;

  @HiveField(8)
  double vatRate;

  @HiveField(9)
  String? invoiceFooter;

  @HiveField(10)
  DateTime? lastBackupDate;

  @HiveField(11)
  double? dailyTarget;
  
  @HiveField(12)
  double? savingsPercentage; // Percentage to save from each sale
  
  @HiveField(13)
  double totalSavings; // Total amount saved
  
  @HiveField(14)
  DateTime? savingsStartDate; // When savings were activated

  BusinessProfile({
    this.shopName,
    this.tin,
    this.category,
    this.yearsOperating,
    this.phone,
    this.email,
    this.location,
    this.logoPath,
    this.vatRate = 18.0,
    this.invoiceFooter,
    this.lastBackupDate,
    this.dailyTarget,
    this.savingsPercentage,
    this.totalSavings = 0.0,
    this.savingsStartDate,
  });
}
