// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final typeId = 3;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      groupId: fields[1] as String,
      title: fields[2] as String,
      amount: (fields[3] as num).toDouble(),
      date: fields[4] as DateTime,
      type: fields[5] as TransactionType,
      category: fields[6] as String,
      colorCode: (fields[7] as num).toInt(),
      isPaid: fields[8] == null ? false : fields[8] as bool,
      recurrenceRule: fields[9] == null
          ? RecurrenceRule.none
          : fields[9] as RecurrenceRule,
      installmentTotal: (fields[10] as num?)?.toInt(),
      installmentCurrent: (fields[11] as num?)?.toInt(),
      currency: fields[12] as String?,
      originalAmount: (fields[13] as num?)?.toDouble(),
      exchangeRate: (fields[14] as num?)?.toDouble(),
      hasReminder: fields[15] == null ? false : fields[15] as bool,
      reminderInterval: fields[16] == null
          ? ReminderInterval.none
          : fields[16] as ReminderInterval,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.groupId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.colorCode)
      ..writeByte(8)
      ..write(obj.isPaid)
      ..writeByte(9)
      ..write(obj.recurrenceRule)
      ..writeByte(10)
      ..write(obj.installmentTotal)
      ..writeByte(11)
      ..write(obj.installmentCurrent)
      ..writeByte(12)
      ..write(obj.currency)
      ..writeByte(13)
      ..write(obj.originalAmount)
      ..writeByte(14)
      ..write(obj.exchangeRate)
      ..writeByte(15)
      ..write(obj.hasReminder)
      ..writeByte(16)
      ..write(obj.reminderInterval);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Transaction _$TransactionFromJson(Map<String, dynamic> json) => _Transaction(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  title: json['title'] as String,
  amount: (json['amount'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  category: json['category'] as String,
  colorCode: (json['colorCode'] as num).toInt(),
  isPaid: json['isPaid'] as bool? ?? false,
  recurrenceRule:
      $enumDecodeNullable(_$RecurrenceRuleEnumMap, json['recurrenceRule']) ??
      RecurrenceRule.none,
  installmentTotal: (json['installmentTotal'] as num?)?.toInt(),
  installmentCurrent: (json['installmentCurrent'] as num?)?.toInt(),
  currency: json['currency'] as String?,
  originalAmount: (json['originalAmount'] as num?)?.toDouble(),
  exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
  hasReminder: json['hasReminder'] as bool? ?? false,
  reminderInterval:
      $enumDecodeNullable(
        _$ReminderIntervalEnumMap,
        json['reminderInterval'],
      ) ??
      ReminderInterval.none,
);

Map<String, dynamic> _$TransactionToJson(_Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'title': instance.title,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'category': instance.category,
      'colorCode': instance.colorCode,
      'isPaid': instance.isPaid,
      'recurrenceRule': _$RecurrenceRuleEnumMap[instance.recurrenceRule]!,
      'installmentTotal': instance.installmentTotal,
      'installmentCurrent': instance.installmentCurrent,
      'currency': instance.currency,
      'originalAmount': instance.originalAmount,
      'exchangeRate': instance.exchangeRate,
      'hasReminder': instance.hasReminder,
      'reminderInterval': _$ReminderIntervalEnumMap[instance.reminderInterval]!,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
  TransactionType.investment: 'investment',
};

const _$RecurrenceRuleEnumMap = {
  RecurrenceRule.none: 'none',
  RecurrenceRule.weekly: 'weekly',
  RecurrenceRule.monthly: 'monthly',
  RecurrenceRule.yearly: 'yearly',
  RecurrenceRule.daily: 'daily',
  RecurrenceRule.biweekly: 'biweekly',
  RecurrenceRule.quarterly: 'quarterly',
  RecurrenceRule.semiannually: 'semiannually',
  RecurrenceRule.firstWorkday: 'firstWorkday',
  RecurrenceRule.lastWorkday: 'lastWorkday',
};

const _$ReminderIntervalEnumMap = {
  ReminderInterval.none: 'none',
  ReminderInterval.thirtyMinutes: 'thirtyMinutes',
  ReminderInterval.oneHour: 'oneHour',
  ReminderInterval.twelveHours: 'twelveHours',
  ReminderInterval.oneDay: 'oneDay',
  ReminderInterval.twoDays: 'twoDays',
  ReminderInterval.oneWeek: 'oneWeek',
};
