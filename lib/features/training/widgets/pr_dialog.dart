import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../data/settings.dart';

/// Celebration shown when a workout contains new personal records.
Future<void> showPrDialog(BuildContext context, List<PersonalRecord> prs, AppSettings s) {
  return showDialog<void>(
    context: context,
    builder: (c) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.2, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (c, v, child) => Transform.scale(scale: v, child: child),
            child: Icon(Icons.emoji_events, size: 72, color: c.accent),
          ),
          const SizedBox(height: 8),
          Text(prs.length == 1 ? 'New personal record!' : '${prs.length} new personal records!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [for (final r in prs) _PrTile(r, s)],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: () => Navigator.pop(c), child: const Text('Nice'))),
        ]),
      ),
    ),
  );
}

String prValueText(PersonalRecord r, AppSettings s) {
  if (r.kind == 'reps') {
    return '${fmtNum(r.value, decimals: 0)} reps @ ${fmtNum(s.toDisplay(r.weight ?? 0))} ${s.unitLabel}';
  }
  return '${fmtNum(s.toDisplay(r.value))} ${s.unitLabel}';
}

class _PrTile extends StatelessWidget {
  final PersonalRecord r;
  final AppSettings s;
  const _PrTile(this.r, this.s);
  @override
  Widget build(BuildContext context) {
    final prev = r.previous == null
        ? null
        : (r.kind == 'reps'
            ? '${fmtNum(r.previous, decimals: 0)} reps'
            : '${fmtNum(s.toDisplay(r.previous!))} ${s.unitLabel}');
    final imp = r.improvement;
    final impText = imp == null
        ? ''
        : (r.kind == 'reps' ? '+${fmtNum(imp, decimals: 0)}' : '+${fmtNum(s.toDisplay(imp))} ${s.unitLabel}');
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(r.exerciseName, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('${r.kindLabel}${prev == null ? '' : ' · was $prev'}', style: TextStyle(color: context.muted)),
      trailing:
          Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(prValueText(r, s), style: TextStyle(color: context.accent, fontWeight: FontWeight.w800)),
        if (impText.isNotEmpty) Text(impText, style: TextStyle(color: context.muted, fontSize: 12)),
      ]),
    );
  }
}
