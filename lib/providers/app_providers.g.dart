// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currencyRates)
final currencyRatesProvider = CurrencyRatesProvider._();

final class CurrencyRatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, CurrencyRate>>,
          Map<String, CurrencyRate>,
          FutureOr<Map<String, CurrencyRate>>
        >
    with
        $FutureModifier<Map<String, CurrencyRate>>,
        $FutureProvider<Map<String, CurrencyRate>> {
  CurrencyRatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currencyRatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currencyRatesHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, CurrencyRate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, CurrencyRate>> create(Ref ref) {
    return currencyRates(ref);
  }
}

String _$currencyRatesHash() => r'9b7536d04e9f2f304494891a88aad2fdb48c26b5';

@ProviderFor(AppSettingsNotifier)
final appSettingsProvider = AppSettingsNotifierProvider._();

final class AppSettingsNotifierProvider
    extends $NotifierProvider<AppSettingsNotifier, AppSettings> {
  AppSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsNotifierHash();

  @$internal
  @override
  AppSettingsNotifier create() => AppSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettings>(value),
    );
  }
}

String _$appSettingsNotifierHash() =>
    r'8b30e308c125f2d77f9a52a2ac7c7c260c484b04';

abstract class _$AppSettingsNotifier extends $Notifier<AppSettings> {
  AppSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppSettings, AppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppSettings, AppSettings>,
              AppSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PinState)
final pinStateProvider = PinStateProvider._();

final class PinStateProvider extends $NotifierProvider<PinState, bool> {
  PinStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinStateHash();

  @$internal
  @override
  PinState create() => PinState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$pinStateHash() => r'90b296fc68a84680ad93d72a06a21e5de2743201';

abstract class _$PinState extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MainScreenIndex)
final mainScreenIndexProvider = MainScreenIndexProvider._();

final class MainScreenIndexProvider
    extends $NotifierProvider<MainScreenIndex, int> {
  MainScreenIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mainScreenIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mainScreenIndexHash();

  @$internal
  @override
  MainScreenIndex create() => MainScreenIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$mainScreenIndexHash() => r'841e7ced549d62247d0f70c88d59a92889b3de8e';

abstract class _$MainScreenIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(LastAddedTransactionId)
final lastAddedTransactionIdProvider = LastAddedTransactionIdProvider._();

final class LastAddedTransactionIdProvider
    extends $NotifierProvider<LastAddedTransactionId, String?> {
  LastAddedTransactionIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastAddedTransactionIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastAddedTransactionIdHash();

  @$internal
  @override
  LastAddedTransactionId create() => LastAddedTransactionId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$lastAddedTransactionIdHash() =>
    r'7a68d518d3b3f32cae0e734e3280d64caef11998';

abstract class _$LastAddedTransactionId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(GroupsNotifier)
final groupsProvider = GroupsNotifierProvider._();

final class GroupsNotifierProvider
    extends $NotifierProvider<GroupsNotifier, List<AppGroup>> {
  GroupsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupsNotifierHash();

  @$internal
  @override
  GroupsNotifier create() => GroupsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AppGroup> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AppGroup>>(value),
    );
  }
}

String _$groupsNotifierHash() => r'55eb356e718038da6d24463e48316f79d173d599';

abstract class _$GroupsNotifier extends $Notifier<List<AppGroup>> {
  List<AppGroup> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<AppGroup>, List<AppGroup>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<AppGroup>, List<AppGroup>>,
              List<AppGroup>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TransactionsNotifier)
final transactionsProvider = TransactionsNotifierProvider._();

final class TransactionsNotifierProvider
    extends $NotifierProvider<TransactionsNotifier, List<Transaction>> {
  TransactionsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionsNotifierHash();

  @$internal
  @override
  TransactionsNotifier create() => TransactionsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transaction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transaction>>(value),
    );
  }
}

String _$transactionsNotifierHash() =>
    r'f85581494b49ffe50abdf1e5e5d7c6d062b51bde';

abstract class _$TransactionsNotifier extends $Notifier<List<Transaction>> {
  List<Transaction> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Transaction>, List<Transaction>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Transaction>, List<Transaction>>,
              List<Transaction>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedDateNotifier)
final selectedDateProvider = SelectedDateNotifierProvider._();

final class SelectedDateNotifierProvider
    extends $NotifierProvider<SelectedDateNotifier, DateTime> {
  SelectedDateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDateNotifierHash();

  @$internal
  @override
  SelectedDateNotifier create() => SelectedDateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedDateNotifierHash() =>
    r'd9b1a367150700fff0150cecd7e3f556a10a3667';

abstract class _$SelectedDateNotifier extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CategoriesNotifier)
final categoriesProvider = CategoriesNotifierProvider._();

final class CategoriesNotifierProvider
    extends $NotifierProvider<CategoriesNotifier, List<Category>> {
  CategoriesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesNotifierHash();

  @$internal
  @override
  CategoriesNotifier create() => CategoriesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Category> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Category>>(value),
    );
  }
}

String _$categoriesNotifierHash() =>
    r'201ab1051bdeec9908909ce5066b543dff7fabf3';

abstract class _$CategoriesNotifier extends $Notifier<List<Category>> {
  List<Category> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Category>, List<Category>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Category>, List<Category>>,
              List<Category>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredTransactions)
final filteredTransactionsProvider = FilteredTransactionsProvider._();

final class FilteredTransactionsProvider
    extends
        $FunctionalProvider<
          List<Transaction>,
          List<Transaction>,
          List<Transaction>
        >
    with $Provider<List<Transaction>> {
  FilteredTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredTransactionsHash();

  @$internal
  @override
  $ProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Transaction> create(Ref ref) {
    return filteredTransactions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transaction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transaction>>(value),
    );
  }
}

String _$filteredTransactionsHash() =>
    r'fc8eaa7042b48167c6fee03b543ea4368d2c7c09';

@ProviderFor(allGroupTransactions)
final allGroupTransactionsProvider = AllGroupTransactionsProvider._();

final class AllGroupTransactionsProvider
    extends
        $FunctionalProvider<
          List<Transaction>,
          List<Transaction>,
          List<Transaction>
        >
    with $Provider<List<Transaction>> {
  AllGroupTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allGroupTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allGroupTransactionsHash();

  @$internal
  @override
  $ProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Transaction> create(Ref ref) {
    return allGroupTransactions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transaction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transaction>>(value),
    );
  }
}

String _$allGroupTransactionsHash() =>
    r'1c854b379cfcf3bb7829b9572b127b171bb5bbbc';

@ProviderFor(expenseTransactions)
final expenseTransactionsProvider = ExpenseTransactionsProvider._();

final class ExpenseTransactionsProvider
    extends
        $FunctionalProvider<
          List<Transaction>,
          List<Transaction>,
          List<Transaction>
        >
    with $Provider<List<Transaction>> {
  ExpenseTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseTransactionsHash();

  @$internal
  @override
  $ProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Transaction> create(Ref ref) {
    return expenseTransactions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transaction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transaction>>(value),
    );
  }
}

String _$expenseTransactionsHash() =>
    r'401dab5cf4863ff5771fa9e3bbb3715c3cd90d08';

@ProviderFor(incomeTransactions)
final incomeTransactionsProvider = IncomeTransactionsProvider._();

final class IncomeTransactionsProvider
    extends
        $FunctionalProvider<
          List<Transaction>,
          List<Transaction>,
          List<Transaction>
        >
    with $Provider<List<Transaction>> {
  IncomeTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeTransactionsHash();

  @$internal
  @override
  $ProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Transaction> create(Ref ref) {
    return incomeTransactions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transaction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transaction>>(value),
    );
  }
}

String _$incomeTransactionsHash() =>
    r'7c1383a03cc8b01c2bbdf5a973092a6aa56e177a';

@ProviderFor(expenseDashboard)
final expenseDashboardProvider = ExpenseDashboardProvider._();

final class ExpenseDashboardProvider
    extends
        $FunctionalProvider<
          Map<String, List<Transaction>>,
          Map<String, List<Transaction>>,
          Map<String, List<Transaction>>
        >
    with $Provider<Map<String, List<Transaction>>> {
  ExpenseDashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseDashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseDashboardHash();

  @$internal
  @override
  $ProviderElement<Map<String, List<Transaction>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, List<Transaction>> create(Ref ref) {
    return expenseDashboard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<Transaction>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, List<Transaction>>>(
        value,
      ),
    );
  }
}

String _$expenseDashboardHash() => r'403637d5852c0239d65ee82bd71d95ab9ad4e108';

@ProviderFor(incomeDashboard)
final incomeDashboardProvider = IncomeDashboardProvider._();

final class IncomeDashboardProvider
    extends
        $FunctionalProvider<
          Map<String, List<Transaction>>,
          Map<String, List<Transaction>>,
          Map<String, List<Transaction>>
        >
    with $Provider<Map<String, List<Transaction>>> {
  IncomeDashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeDashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeDashboardHash();

  @$internal
  @override
  $ProviderElement<Map<String, List<Transaction>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, List<Transaction>> create(Ref ref) {
    return incomeDashboard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<Transaction>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, List<Transaction>>>(
        value,
      ),
    );
  }
}

String _$incomeDashboardHash() => r'd52156fe49d1b9f36d35b6ce507a924dbf581d7a';

@ProviderFor(investmentTransactions)
final investmentTransactionsProvider = InvestmentTransactionsProvider._();

final class InvestmentTransactionsProvider
    extends
        $FunctionalProvider<
          List<Transaction>,
          List<Transaction>,
          List<Transaction>
        >
    with $Provider<List<Transaction>> {
  InvestmentTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'investmentTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$investmentTransactionsHash();

  @$internal
  @override
  $ProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Transaction> create(Ref ref) {
    return investmentTransactions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transaction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transaction>>(value),
    );
  }
}

String _$investmentTransactionsHash() =>
    r'6f2fa72bc624d7299aa71010f693e4a8346abf53';

@ProviderFor(investmentDashboard)
final investmentDashboardProvider = InvestmentDashboardProvider._();

final class InvestmentDashboardProvider
    extends
        $FunctionalProvider<
          Map<String, List<Transaction>>,
          Map<String, List<Transaction>>,
          Map<String, List<Transaction>>
        >
    with $Provider<Map<String, List<Transaction>>> {
  InvestmentDashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'investmentDashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$investmentDashboardHash();

  @$internal
  @override
  $ProviderElement<Map<String, List<Transaction>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, List<Transaction>> create(Ref ref) {
    return investmentDashboard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<Transaction>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, List<Transaction>>>(
        value,
      ),
    );
  }
}

String _$investmentDashboardHash() =>
    r'e58c15e05b2d793e541be8ab66184155f7df2eee';

@ProviderFor(dashboardTransactions)
final dashboardTransactionsProvider = DashboardTransactionsProvider._();

final class DashboardTransactionsProvider
    extends
        $FunctionalProvider<
          Map<String, List<Transaction>>,
          Map<String, List<Transaction>>,
          Map<String, List<Transaction>>
        >
    with $Provider<Map<String, List<Transaction>>> {
  DashboardTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardTransactionsHash();

  @$internal
  @override
  $ProviderElement<Map<String, List<Transaction>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, List<Transaction>> create(Ref ref) {
    return dashboardTransactions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<Transaction>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, List<Transaction>>>(
        value,
      ),
    );
  }
}

String _$dashboardTransactionsHash() =>
    r'c817c47f1432012e9e46544f16aca45edaea215c';
