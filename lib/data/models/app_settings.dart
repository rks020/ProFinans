import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
@HiveType(typeId: 4)
abstract class AppSettings extends HiveObject with _$AppSettings {
  AppSettings._();

  factory AppSettings({
    @HiveField(0) String? activeGroupId,
    @HiveField(1) @Default('TRY') String selectedCurrency,
    @HiveField(2) @Default('dark') String themePreference,
    @HiveField(3) @Default(false) bool isPrivacyMode,
    @HiveField(4) String? pinCode,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
}
