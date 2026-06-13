// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BusinessProfileAdapter extends TypeAdapter<BusinessProfile> {
  @override
  final int typeId = 8;

  @override
  BusinessProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BusinessProfile(
      shopName: fields[0] as String?,
      tin: fields[1] as String?,
      category: fields[2] as String?,
      yearsOperating: fields[3] as int?,
      phone: fields[4] as String?,
      email: fields[5] as String?,
      location: fields[6] as String?,
      logoPath: fields[7] as String?,
      vatRate: fields[8] as double,
      invoiceFooter: fields[9] as String?,
      lastBackupDate: fields[10] as DateTime?,
      dailyTarget: fields[11] as double?,
      savingsPercentage: fields[12] as double?,
      totalSavings: fields[13] as double,
      savingsStartDate: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BusinessProfile obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.shopName)
      ..writeByte(1)
      ..write(obj.tin)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.yearsOperating)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.logoPath)
      ..writeByte(8)
      ..write(obj.vatRate)
      ..writeByte(9)
      ..write(obj.invoiceFooter)
      ..writeByte(10)
      ..write(obj.lastBackupDate)
      ..writeByte(11)
      ..write(obj.dailyTarget)
      ..writeByte(12)
      ..write(obj.savingsPercentage)
      ..writeByte(13)
      ..write(obj.totalSavings)
      ..writeByte(14)
      ..write(obj.savingsStartDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
