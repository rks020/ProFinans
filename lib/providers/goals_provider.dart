import 'package:riverpod_annotation/riverpod_annotation.dart';
export '../data/models/goal.dart';
import 'repository_providers.dart';
import 'app_providers.dart';

part 'goals_provider.g.dart';

@riverpod
class GoalsNotifier extends _$GoalsNotifier {
  @override
  List<Goal> build() {
    return ref.watch(goalsRepositoryProvider).getGoals();
  }

  Future<void> addGoal(Goal goal) async {
    await ref.read(goalsRepositoryProvider).saveGoal(goal);
    state = [...state, goal];
  }

  Future<void> updateGoal(Goal goal) async {
    await ref.read(goalsRepositoryProvider).saveGoal(goal);
    state = [for (final g in state) if (g.id == goal.id) goal else g];
  }

  Future<void> deleteGoal(String id) async {
    await ref.read(goalsRepositoryProvider).deleteGoal(id);
    state = state.where((g) => g.id != id).toList();
  }
}

class GoalProgress {
  final Goal goal;
  final double currentAmount;

  GoalProgress({required this.goal, required this.currentAmount});

  double get percent => (goal.targetAmount > 0) ? (currentAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
  double get remaining => (goal.targetAmount - currentAmount).clamp(0.0, double.infinity);
}

@riverpod
Map<String, GoalProgress> goalsProgress(Ref ref) {
  final goals = ref.watch(goalsProvider);
  final transactions = ref.watch(transactionsProvider);
  
  final Map<String, double> savingsPerGoal = {};
  for (final t in transactions) {
    if (t.goalId != null) {
      // Tüm türler (Gelir, Gider, Yatırım) bir hedefle ilişkilendirildiğinde
      // hedefe katkı olarak (+ değer) kabul edilir.
      savingsPerGoal[t.goalId!] = (savingsPerGoal[t.goalId!] ?? 0) + t.amount;
    }
  }
  
  final Map<String, GoalProgress> progressMap = {};
  for (final goal in goals) {
    final total = goal.currentAmount + (savingsPerGoal[goal.id] ?? 0);
    progressMap[goal.id] = GoalProgress(goal: goal, currentAmount: total);
  }
  
  return progressMap;
}
