import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/settings.dart';
import 'infrastructure.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  AppSettings build() => AppSettings.load(ref.watch(sharedPrefsProvider));

  Future<void> update(AppSettings Function(AppSettings s) change) async {
    state = change(state);
    await state.save(ref.read(sharedPrefsProvider));
  }
}
