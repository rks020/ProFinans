import 'package:hive_ce/hive.dart';
import '../models/goal.dart';

class GoalsRepository {
  final Box<Goal> _box;

  GoalsRepository(this._box);

  List<Goal> getGoals() {
    return _box.values.toList();
  }

  Future<void> saveGoal(Goal goal) async {
    await _box.put(goal.id, goal);
  }

  Future<void> deleteGoal(String id) async {
    await _box.delete(id);
  }

  Future<void> saveGoals(List<Goal> goals) async {
    final Map<String, Goal> goalMap = {for (var g in goals) g.id: g};
    await _box.putAll(goalMap);
  }
}
