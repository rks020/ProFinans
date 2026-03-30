import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_ce/hive.dart';
import '../data/models/app_settings.dart';
import '../data/models/app_group.dart';
import '../data/models/transaction.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/groups_repository.dart';
import '../data/repositories/transactions_repository.dart';
import '../data/repositories/categories_repository.dart';
import '../data/repositories/goals_repository.dart';
import '../data/models/category.dart';
import '../data/models/goal.dart';

part 'repository_providers.g.dart';

@riverpod
GoalsRepository goalsRepository(Ref ref) {
  final box = Hive.box<Goal>('goals');
  return GoalsRepository(box);
}

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  final box = Hive.box<AppSettings>('settings');
  return SettingsRepository(box);
}

@riverpod
GroupsRepository groupsRepository(Ref ref) {
  final box = Hive.box<AppGroup>('groups');
  return GroupsRepository(box);
}

@riverpod
TransactionsRepository transactionsRepository(Ref ref) {
  final box = Hive.box<Transaction>('transactions');
  return TransactionsRepository(box);
}

@riverpod
CategoriesRepository categoriesRepository(Ref ref) {
  final box = Hive.box<Category>('categories');
  return CategoriesRepository(box);
}
