import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/app_settings.dart';
import '../data/models/app_group.dart';
import '../data/models/transaction.dart';
import '../data/models/enums.dart';
import 'repository_providers.dart';

part 'app_providers.g.dart';

@riverpod
class AppSettingsNotifier extends _$AppSettingsNotifier {
  @override
  AppSettings build() {
    return ref.watch(settingsRepositoryProvider).getSettings();
  }

  Future<void> updateActiveGroup(String? groupId) async {
    await ref.read(settingsRepositoryProvider).updateActiveGroup(groupId);
    state = state.copyWith(activeGroupId: groupId);
  }

  Future<void> updateSettings(AppSettings settings) async {
    await ref.read(settingsRepositoryProvider).saveSettings(settings);
    state = settings;
  }
}

@riverpod
class GroupsNotifier extends _$GroupsNotifier {
  @override
  List<AppGroup> build() {
    return ref.watch(groupsRepositoryProvider).getAllGroups();
  }

  Future<void> addGroup(AppGroup group) async {
    await ref.read(groupsRepositoryProvider).saveGroup(group);
    state = [...state, group];
  }

  Future<void> removeGroup(String id) async {
    await ref.read(groupsRepositoryProvider).deleteGroup(id);
    state = state.where((g) => g.id != id).toList();
  }
}

@riverpod
class TransactionsNotifier extends _$TransactionsNotifier {
  @override
  List<Transaction> build() {
    return ref.watch(transactionsRepositoryProvider).getAllTransactions();
  }

 Future<void> addTransaction(Transaction transaction) async {
    await ref.read(transactionsRepositoryProvider).saveTransaction(transaction);
    
    // Kontrol et: Bu ID zaten listede var mı?
    final exists = state.any((t) => t.id == transaction.id);

    if (exists) {
      // VARSA: Eski olanı bul ve yenisiyle değiştir (Update)
      state = state.map((t) => t.id == transaction.id ? transaction : t).toList();
    } else {
      // YOKSA: Listenin sonuna ekle (Insert)
      state = [...state, transaction];
    }
  }

  Future<void> addTransactions(List<Transaction> transactions) async {
    await ref.read(transactionsRepositoryProvider).saveTransactions(transactions);
    state = [...state, ...transactions];
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionsRepositoryProvider).deleteTransaction(id);
    state = state.where((t) => t.id != id).toList();
  }

  Future<void> togglePaid(String id) async {
    final transaction = state.firstWhere((t) => t.id == id);
    final updated = transaction.copyWith(isPaid: !transaction.isPaid);
    await ref.read(transactionsRepositoryProvider).saveTransaction(updated);
    state = [for (final t in state) if (t.id == id) updated else t];
  }
}

@riverpod
List<Transaction> filteredTransactions(Ref ref) {
  final settings = ref.watch(appSettingsProvider);
  final transactions = ref.watch(transactionsProvider);
  
  if (settings.activeGroupId == null) return [];
  
  return transactions.where((t) => t.groupId == settings.activeGroupId).toList();
}

@riverpod
List<Transaction> expenseTransactions(Ref ref) {
  return ref.watch(filteredTransactionsProvider)
      .where((t) => t.type == TransactionType.expense)
      .toList();
}

@riverpod
List<Transaction> incomeTransactions(Ref ref) {
  return ref.watch(filteredTransactionsProvider)
      .where((t) => t.type == TransactionType.income)
      .toList();
}

@riverpod
Map<String, List<Transaction>> expenseDashboard(Ref ref) {
  final transactions = ref.watch(expenseTransactionsProvider);
  return _calculateDashboardData(transactions);
}

@riverpod
Map<String, List<Transaction>> incomeDashboard(Ref ref) {
  final transactions = ref.watch(incomeTransactionsProvider);
  return _calculateDashboardData(transactions);
}

Map<String, List<Transaction>> _calculateDashboardData(List<Transaction> transactions) {
  final now = DateTime.now();
  // Saat farkını yoksaymak için bugünün başlangıcı (00:00:00)
  final today = DateTime(now.year, now.month, now.day); 
  
  // 1. Gecikenler: Bugünden önce olanlar VE ödenmemiş olanlar
  final delayed = transactions.where((t) => 
    t.date.isBefore(today) && 
    !t.isPaid
  ).toList();

  // 2. Ödenenler: Bu ay içinde olanlar VE ödenmiş olanlar
  final paid = transactions.where((t) => 
    t.date.year == now.year && 
    t.date.month == now.month && 
    t.isPaid
  ).toList();

  // 3. Gelecek: Bugün ve sonrası, bu ay ve yıl içinde olanlar VE ÖDENMEMİŞ olanlar
  final upcoming = transactions.where((t) => 
    (t.date.isAfter(today) || t.date.isAtSameMomentAs(today)) && 
    t.date.year == now.year && 
    t.date.month == now.month && 
    !t.isPaid
  ).toList();
  
  // Sıralama işlemleri (İsteğe bağlı, görsel düzgünlük için)
  delayed.sort((a, b) => a.date.compareTo(b.date)); // Eskiden yeniye
  upcoming.sort((a, b) => a.date.compareTo(b.date)); // Yakından uzağa
  paid.sort((a, b) => b.date.compareTo(a.date));     // Yeniden eskiye

  return {
    'delayed': delayed,
    'paid': paid,
    'upcoming': upcoming,
  };
}

@riverpod
Map<String, List<Transaction>> dashboardTransactions(Ref ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  return _calculateDashboardData(transactions);
}
