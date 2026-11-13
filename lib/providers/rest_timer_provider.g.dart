// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Timestamp based: stays correct while the app is in the background.

@ProviderFor(RestTimer)
final restTimerProvider = RestTimerProvider._();

/// Timestamp based: stays correct while the app is in the background.
final class RestTimerProvider
    extends $NotifierProvider<RestTimer, RestTimerState> {
  /// Timestamp based: stays correct while the app is in the background.
  RestTimerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'restTimerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$restTimerHash();

  @$internal
  @override
  RestTimer create() => RestTimer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestTimerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestTimerState>(value),
    );
  }
}

String _$restTimerHash() => r'364e1ab17db695d1dd7cc1965cbbe4c86feb53f9';

/// Timestamp based: stays correct while the app is in the background.

abstract class _$RestTimer extends $Notifier<RestTimerState> {
  RestTimerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RestTimerState, RestTimerState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<RestTimerState, RestTimerState>,
        RestTimerState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
