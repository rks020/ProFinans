// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GoalsNotifier)
final goalsProvider = GoalsNotifierProvider._();

final class GoalsNotifierProvider
    extends $NotifierProvider<GoalsNotifier, List<Goal>> {
  GoalsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsNotifierHash();

  @$internal
  @override
  GoalsNotifier create() => GoalsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Goal> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Goal>>(value),
    );
  }
}

String _$goalsNotifierHash() => r'b3894becd43b1108f62271b11503b5c9e5a30a6a';

abstract class _$GoalsNotifier extends $Notifier<List<Goal>> {
  List<Goal> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Goal>, List<Goal>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Goal>, List<Goal>>,
              List<Goal>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(goalsProgress)
final goalsProgressProvider = GoalsProgressProvider._();

final class GoalsProgressProvider
    extends
        $FunctionalProvider<
          Map<String, GoalProgress>,
          Map<String, GoalProgress>,
          Map<String, GoalProgress>
        >
    with $Provider<Map<String, GoalProgress>> {
  GoalsProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsProgressHash();

  @$internal
  @override
  $ProviderElement<Map<String, GoalProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, GoalProgress> create(Ref ref) {
    return goalsProgress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, GoalProgress> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, GoalProgress>>(value),
    );
  }
}

String _$goalsProgressHash() => r'45463261492bbf69c0f51c75e1eabe09c9fa5eb2';
