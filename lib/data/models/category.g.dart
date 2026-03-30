// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final typeId = 5;

  @override
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Category(
      name: fields[0] as String,
      colorCode: (fields[1] as num).toInt(),
      budgetLimit: (fields[2] as num?)?.toDouble(),
      type: fields[3] as TransactionType?,
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.colorCode)
      ..writeByte(2)
      ..write(obj.budgetLimit)
      ..writeByte(3)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  name: json['name'] as String,
  colorCode: (json['colorCode'] as num).toInt(),
  budgetLimit: (json['budgetLimit'] as num?)?.toDouble(),
  type: $enumDecodeNullable(_$TransactionTypeEnumMap, json['type']),
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'name': instance.name,
  'colorCode': instance.colorCode,
  'budgetLimit': instance.budgetLimit,
  'type': _$TransactionTypeEnumMap[instance.type],
};

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
  TransactionType.investment: 'investment',
};
