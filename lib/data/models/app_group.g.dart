// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppGroupAdapter extends TypeAdapter<AppGroup> {
  @override
  final typeId = 2;

  @override
  AppGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppGroup(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      members: fields[3] == null ? [] : (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppGroup obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.members);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppGroup _$AppGroupFromJson(Map<String, dynamic> json) => _AppGroup(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String,
  members:
      (json['members'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$AppGroupToJson(_AppGroup instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': instance.icon,
  'members': instance.members,
};
