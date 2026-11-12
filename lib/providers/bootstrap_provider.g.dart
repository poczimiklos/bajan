// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Seeds the exercise library and restores an unfinished workout.

@ProviderFor(bootstrap)
final bootstrapProvider = BootstrapProvider._();

/// Seeds the exercise library and restores an unfinished workout.

final class BootstrapProvider extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Seeds the exercise library and restores an unfinished workout.
  BootstrapProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bootstrapProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bootstrapHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return bootstrap(ref);
  }
}

String _$bootstrapHash() => r'1253f639ade81645853e834c89f66fc13dbfa4f0';
