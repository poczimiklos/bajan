import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../domain/e1rm.dart';
import '../../../providers/providers.dart';

// ─────────────────────────── Set row ───────────────────────────

class SetRow extends ConsumerWidget {
  final Workout workout;
  final WorkoutExercise we;
  final int index;
  const SetRow({super.key, required this.workout, required this.we, required this.index});

  InputDecoration _dec(String? hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      );

  static final _numFormat = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = we.sets[index];
    final settings = ref.watch(settingsProvider);
    final editor = ref.read(workoutEditorProvider.notifier);
    final rir = settings.rpeScale == 'rir';

    String wText(double? kg) => kg == null ? '' : fmtNum(settings.toDisplay(kg), decimals: 2);
    String rText(double? rpe) => rpe == null ? '' : fmtNum(rir ? 10 - rpe : rpe);

    final e1 = (s.weight != null && s.reps != null)
        ? estimate1RM(weight: s.weight!, reps: s.reps!, rpe: s.rpe, formula: settings.formula)
        : null;
    final hasTarget = s.prescText.isNotEmpty || s.prescReps != null || s.prescWeight != null;
    final delta = (s.prescWeight != null && s.weight != null) ? s.weight! - s.prescWeight! : null;

    final typeColor = switch (s.type) {
      SetType.warmup => AppColors.warn,
      SetType.backoff => AppColors.gold,
      SetType.amrap => AppColors.danger,
      SetType.custom => context.accent,
      _ => context.muted,
    };

    void toggle() {
      if (!s.completed && (s.weight == null || s.reps == null)) {
        snack(context, 'Enter weight and reps first.');
        return;
      }
      final nowDone = !s.completed;
      editor.updateSet(we.id, s.id, (x) => x.completed = nowDone);
      if (nowDone) {
        HapticFeedback.mediumImpact();
        if (settings.autoRest) {
          ref.read(restTimerProvider.notifier).start(s.type == SetType.warmup ? 60 : settings.restSeconds);
        }
      }
    }

    return Dismissible(
      key: ValueKey('dismiss-${s.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(top: 6),
        decoration: const BoxDecoration(color: AppColors.danger),
        child: const Icon(Icons.delete, color: AppColors.text),
      ),
      onDismissed: (_) {
        final removed = s;
        final at = index;
        editor.removeSet(we.id, s.id);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: const Text('Set removed'),
            action: SnackBarAction(label: 'Undo', onPressed: () => editor.insertSet(we.id, at, removed)),
          ));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        decoration: BoxDecoration(
          color: s.completed ? context.accent.withValues(alpha: 0.14) : Colors.transparent,
          border: Border.all(
            color: s.completed ? context.accent.withValues(alpha: 0.6) : AppColors.gold.withValues(alpha: 0.16),
          ),
        ),
        child: Column(children: [
          Row(children: [
            InkWell(
              customBorder: const BeveledRectangleBorder(),
              onTap: () => editor.cycleSetType(we.id, s.id),
              child: SizedBox(
                width: 44,
                height: 48,
                child: Center(
                  child: Text(
                    SetType.short(s.type).isEmpty ? '${index + 1}' : SetType.short(s.type),
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: typeColor),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: TextFormField(
                  key: ValueKey('${s.id}-w'),
                  initialValue: wText(s.weight),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: _numFormat,
                  decoration: _dec(s.prescWeight == null ? null : wText(s.prescWeight)),
                  onChanged: (v) {
                    final shown = parseNum(v);
                    editor.updateSet(we.id, s.id, (x) => x.weight = shown == null ? null : settings.toKg(shown));
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: TextFormField(
                  key: ValueKey('${s.id}-r'),
                  initialValue: s.reps?.toString() ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _dec(s.prescReps?.toString()),
                  onChanged: (v) => editor.updateSet(we.id, s.id, (x) => x.reps = int.tryParse(v)),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: TextFormField(
                  key: ValueKey('${s.id}-p'),
                  initialValue: rText(s.rpe),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: _numFormat,
                  decoration: _dec(s.targetRpe == null ? null : rText(s.targetRpe)),
                  onChanged: (v) {
                    final shown = parseNum(v);
                    editor.updateSet(we.id, s.id, (x) => x.rpe = shown == null ? null : (rir ? 10 - shown : shown));
                  },
                ),
              ),
            ),
            SizedBox(
              width: 52,
              height: 52,
              child: IconButton(
                onPressed: toggle,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                  child: s.completed
                      ? Icon(Icons.check_circle, key: const ValueKey('on'), color: context.accent, size: 34)
                      : Icon(Icons.radio_button_unchecked, key: const ValueKey('off'), color: context.muted, size: 34),
                ),
              ),
            ),
          ]),
          if (hasTarget || e1 != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 0, 8, 2),
              child: Row(children: [
                Expanded(
                  child: Text(
                    [
                      if (hasTarget)
                        'Target ${s.prescText.isEmpty ? '' : '${s.prescText} '}${s.prescReps != null ? '× ${s.prescReps}' : ''}'
                            .trim(),
                      if (delta != null && delta.abs() > 0.01)
                        'Δ ${delta > 0 ? '+' : ''}${fmtNum(settings.toDisplay(delta))}',
                    ].join(' · '),
                    style: TextStyle(color: context.muted, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (e1 != null)
                  Text('e1RM ${fmtNum(settings.toDisplay(e1))}', style: TextStyle(color: context.muted, fontSize: 11)),
              ]),
            ),
        ]),
      ),
    );
  }
}
