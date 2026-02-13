// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final typeId = 0;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      case 2:
        return TransactionType.investment;
      default:
        return TransactionType.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
      case TransactionType.expense:
        writer.writeByte(1);
      case TransactionType.investment:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrenceRuleAdapter extends TypeAdapter<RecurrenceRule> {
  @override
  final typeId = 1;

  @override
  RecurrenceRule read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrenceRule.none;
      case 1:
        return RecurrenceRule.weekly;
      case 2:
        return RecurrenceRule.monthly;
      case 3:
        return RecurrenceRule.yearly;
      case 4:
        return RecurrenceRule.daily;
      case 5:
        return RecurrenceRule.biweekly;
      case 6:
        return RecurrenceRule.quarterly;
      case 7:
        return RecurrenceRule.semiannually;
      case 8:
        return RecurrenceRule.firstWorkday;
      case 9:
        return RecurrenceRule.lastWorkday;
      default:
        return RecurrenceRule.none;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrenceRule obj) {
    switch (obj) {
      case RecurrenceRule.none:
        writer.writeByte(0);
      case RecurrenceRule.weekly:
        writer.writeByte(1);
      case RecurrenceRule.monthly:
        writer.writeByte(2);
      case RecurrenceRule.yearly:
        writer.writeByte(3);
      case RecurrenceRule.daily:
        writer.writeByte(4);
      case RecurrenceRule.biweekly:
        writer.writeByte(5);
      case RecurrenceRule.quarterly:
        writer.writeByte(6);
      case RecurrenceRule.semiannually:
        writer.writeByte(7);
      case RecurrenceRule.firstWorkday:
        writer.writeByte(8);
      case RecurrenceRule.lastWorkday:
        writer.writeByte(9);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceRuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
