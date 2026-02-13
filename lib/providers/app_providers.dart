import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/app_settings.dart';
import '../data/models/app_group.dart';
import '../data/models/transaction.dart';
import '../data/models/enums.dart';
import '../data/models/category.dart';
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

  Future<void> deleteBulkTransactions(Transaction template) async {
    // Aynı isimli, aynı gruptaki ve aynı tipteki tüm işlemleri bul (Tekrarlayanlar için)
    final toDelete = state.where((t) => 
      t.title == template.title && 
      t.groupId == template.groupId && 
      t.type == template.type &&
      t.date.year == template.date.year // Sadece aynı yıla ait olanları sil
    ).toList();
    
    for (final t in toDelete) {
      await ref.read(transactionsRepositoryProvider).deleteTransaction(t.id);
    }
    
    final deleteIds = toDelete.map((t) => t.id).toSet();
    state = state.where((t) => !deleteIds.contains(t.id)).toList();
  }

  Future<void> togglePaid(String id) async {
    final transaction = state.firstWhere((t) => t.id == id);
    final updated = transaction.copyWith(isPaid: !transaction.isPaid);
    await ref.read(transactionsRepositoryProvider).saveTransaction(updated);
    state = [for (final t in state) if (t.id == id) updated else t];
  }

  Future<void> updateCategoryColor(String categoryName, int newColorCode) async {
    // 1. Etkilenen işlemleri bul
    final transactionsToUpdate = state.where((t) => t.category == categoryName).toList();
    
    if (transactionsToUpdate.isEmpty) return;

    // 2. Renkleri güncelle
    final updatedTransactions = transactionsToUpdate.map((t) {
      return t.copyWith(colorCode: newColorCode);
    }).toList();

    // 3. Veritabanına toplu kaydet
    await ref.read(transactionsRepositoryProvider).saveTransactions(updatedTransactions);

    // 4. State'i güncelle
    state = state.map((t) {
      if (t.category == categoryName) {
        return t.copyWith(colorCode: newColorCode);
      }
      return t;
    }).toList();
  }
}

@riverpod
class SelectedDateNotifier extends _$SelectedDateNotifier {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month);
  }
}

@riverpod
class CategoriesNotifier extends _$CategoriesNotifier {
  @override
  List<Category> build() {
    final repo = ref.watch(categoriesRepositoryProvider);
    final categories = repo.getAllCategories();
    
    if (categories.isEmpty) {
      final defaults = [
        Category(name: 'Market', colorCode: 0xFFFB8C00), // Hex: Orange
        Category(name: 'Kira', colorCode: 0xFF8E24AA),  // Hex: Purple
        Category(name: 'Fatura', colorCode: 0xFFE53935), // Hex: Red
        Category(name: 'Maaş', colorCode: 0xFF43A047),  // Hex: Green
        Category(name: 'Genel', colorCode: 0xFF1E88E5),  // Hex: Blue
      ];
      repo.saveCategories(defaults);
      return defaults;
    }
    return categories;
  }

  Future<void> addCategory(Category category) async {
    await ref.read(categoriesRepositoryProvider).saveCategory(category);
    state = [...state, category];
  }

  Future<void> updateCategory(Category category) async {
    // Hive'da güncellemek için (Key ile bulup save yapmak gerekebilir veya direkt save)
    // HiveObject olduğu için .save() çağrılabilir ama burada yeni nesne geliyor olabilir.
    // Repository üzerinden güncelleme yapmak en doğrusu.
    await ref.read(categoriesRepositoryProvider).saveCategory(category);
    
    // State'i güncelle
    state = state.map((c) => c.name == category.name ? category : c).toList();
  }
}

@riverpod
List<Transaction> filteredTransactions(Ref ref) {
  final settings = ref.watch(appSettingsProvider);
  final transactions = ref.watch(transactionsProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  
  if (settings.activeGroupId == null) return [];
  
  // Basic filtering by group
  final groupTransactions = transactions.where((t) => t.groupId == settings.activeGroupId).toList();
  
  // Filter by selected year and month
  return groupTransactions.where((t) => 
    t.date.year == selectedDate.year && 
    t.date.month == selectedDate.month
  ).toList();
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
  final selectedDate = ref.watch(selectedDateProvider);
  return _calculateDashboardData(transactions, selectedDate);
}

@riverpod
Map<String, List<Transaction>> incomeDashboard(Ref ref) {
  final transactions = ref.watch(incomeTransactionsProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return _calculateDashboardData(transactions, selectedDate);
}

Map<String, List<Transaction>> _calculateDashboardData(List<Transaction> transactions, DateTime selectedDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day); 
  
  // 1. Gecikenler: Bugünden önce olanlar VE ödenmemiş olanlar (Tüm zamanlar olabilir ama seçili grup içinde)
  // NOT: Gecikenler genellikle sadece "seçili ay" ile sınırlı değildir, ödenene kadar orada durur.
  // Ancak kullanıcı sadece seçili ayın gecikenlerini görmek istiyorsa aşağıdaki mantık geçerlidir.
  // Mevcut yapıda 'transactions' zaten seçili ay ile filtrelenmiş durumda (filteredTransactionsProvider'dan geliyor).
  
  final delayed = transactions.where((t) => 
    t.date.isBefore(today) && 
    !t.isPaid
  ).toList();

  // 2. Ödenenler: Seçili ay içinde olanlar VE ödenmiş olanlar
  final paid = transactions.where((t) => 
    t.isPaid
  ).toList();

  // 3. Gelecek: Bugün ve sonrası, seçili ay içinde olanlar VE ÖDENMEMİŞ olanlar
  final upcoming = transactions.where((t) => 
    (t.date.isAfter(today) || t.date.isAtSameMomentAs(today)) && 
    !t.isPaid
  ).toList();
  
  delayed.sort((a, b) => a.date.compareTo(b.date));
  upcoming.sort((a, b) => a.date.compareTo(b.date));
  paid.sort((a, b) => b.date.compareTo(a.date));

  return {
    'delayed': delayed,
    'paid': paid,
    'upcoming': upcoming,
  };
}

@riverpod
Map<String, List<Transaction>> dashboardTransactions(Ref ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return _calculateDashboardData(transactions, selectedDate);
}
