// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscriptions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(detectedSubscriptions)
final detectedSubscriptionsProvider = DetectedSubscriptionsProvider._();

final class DetectedSubscriptionsProvider
    extends
        $FunctionalProvider<
          List<SubscriptionCandidate>,
          List<SubscriptionCandidate>,
          List<SubscriptionCandidate>
        >
    with $Provider<List<SubscriptionCandidate>> {
  DetectedSubscriptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'detectedSubscriptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$detectedSubscriptionsHash();

  @$internal
  @override
  $ProviderElement<List<SubscriptionCandidate>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SubscriptionCandidate> create(Ref ref) {
    return detectedSubscriptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SubscriptionCandidate> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SubscriptionCandidate>>(value),
    );
  }
}

String _$detectedSubscriptionsHash() =>
    r'50ae3f985c2fdb9c1eb202f5a2b95821ea5debd5';

@ProviderFor(totalMonthlySubscriptions)
final totalMonthlySubscriptionsProvider = TotalMonthlySubscriptionsProvider._();

final class TotalMonthlySubscriptionsProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  TotalMonthlySubscriptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalMonthlySubscriptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalMonthlySubscriptionsHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return totalMonthlySubscriptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$totalMonthlySubscriptionsHash() =>
    r'02f5871c18fc4e05d553018fe2176a4c1ff4d154';
