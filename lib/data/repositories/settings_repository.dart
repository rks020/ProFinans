import 'package:hive_ce/hive.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  final Box<AppSettings> _box;

  SettingsRepository(this._box);

  AppSettings getSettings() {
    return _box.get('current') ?? AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put('current', settings);
  }

  Future<void> updateActiveGroup(String? groupId) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(activeGroupId: groupId));
  }
}
