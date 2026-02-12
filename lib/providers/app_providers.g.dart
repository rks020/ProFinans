// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
    r'ffb581ab3bdb59c3920f2aacb7052e12bd513cc4';

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

String _$groupsNotifierHash() => r'54e52a562bcf8cb97ebab7352809a57b14e7dc86';

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
    r'0a39201dc8263a38c5aaa1dd722e4816a2c6e3fe';

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
    r'5c0b667090570a326827ea4df9ca9a7962e46de2';

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

String _$expenseDashboardHash() => r'5b3e45e20aee67240aa3e684b8b91ebf21214d6a';

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

String _$incomeDashboardHash() => r'760bff3ef91881764d4679467caf7bc4ef7a3f35';

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
    r'67e9600575019e86b796f7a8f0772d4ad3773827';
