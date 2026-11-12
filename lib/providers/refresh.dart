import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data_providers.dart';
import 'infrastructure.dart';

/// Call after any write that changes derived data.
void refreshAll(WidgetRef ref) {
  ref
    ..invalidate(historyProvider)
    ..invalidate(setRecordsProvider)
    ..invalidate(recordsProvider)
    ..invalidate(programsProvider)
    ..invalidate(activePlanProvider)
    ..invalidate(exercisesProvider)
    ..invalidate(bodyweightProvider)
    ..invalidate(syncStatusProvider);
}
