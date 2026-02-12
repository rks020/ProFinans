import 'package:hive_ce/hive.dart';
import '../models/app_group.dart';

class GroupsRepository {
  final Box<AppGroup> _box;

  GroupsRepository(this._box);

  List<AppGroup> getAllGroups() {
    return _box.values.toList();
  }

  AppGroup? getGroup(String id) {
    return _box.get(id);
  }

  Future<void> saveGroup(AppGroup group) async {
    await _box.put(group.id, group);
  }

  Future<void> deleteGroup(String id) async {
    await _box.delete(id);
  }
}
