// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final typeId = 4;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      activeGroupId: fields[0] as String?,
      selectedCurrency: fields[1] == null ? 'TRY' : fields[1] as String,
      themePreference: fields[2] == null ? 'dark' : fields[2] as String,
      isPrivacyMode: fields[3] == null ? false : fields[3] as bool,
      pinCode: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.activeGroupId)
      ..writeByte(1)
      ..write(obj.selectedCurrency)
      ..writeByte(2)
      ..write(obj.themePreference)
      ..writeByte(3)
      ..write(obj.isPrivacyMode)
      ..writeByte(4)
      ..write(obj.pinCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  activeGroupId: json['activeGroupId'] as String?,
  selectedCurrency: json['selectedCurrency'] as String? ?? 'TRY',
  themePreference: json['themePreference'] as String? ?? 'dark',
  isPrivacyMode: json['isPrivacyMode'] as bool? ?? false,
  pinCode: json['pinCode'] as String?,
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'activeGroupId': instance.activeGroupId,
      'selectedCurrency': instance.selectedCurrency,
      'themePreference': instance.themePreference,
      'isPrivacyMode': instance.isPrivacyMode,
      'pinCode': instance.pinCode,
    };
