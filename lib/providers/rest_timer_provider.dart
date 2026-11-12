import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rest_timer_provider.g.dart';

class RestTimerState {
  final DateTime? endsAt;
  final int total; // seconds
  const RestTimerState({this.endsAt, this.total = 0});
  bool get active => endsAt != null;
}

/// Timestamp based: stays correct while the app is in the background.
@Riverpod(keepAlive: true)
class RestTimer extends _$RestTimer {
  @override
  RestTimerState build() => const RestTimerState();

  void start(int seconds) =>
      state = RestTimerState(endsAt: DateTime.now().add(Duration(seconds: seconds)), total: seconds);

  void add(int delta) {
    final e = state.endsAt;
    if (e == null) return;
    state = RestTimerState(endsAt: e.add(Duration(seconds: delta)), total: state.total + delta);
  }

  void stop() => state = const RestTimerState();
}
