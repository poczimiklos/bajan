import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../domain/load_parser.dart';

// ─────────────────────────── prescription editor ───────────────────────────

class SheetResult {
  final List<PrescribedSet> sets;
  final bool propagate;
  final double step;
  final bool removeExercise;
  SheetResult(this.sets, {this.propagate = false, this.step = 0, this.removeExercise = false});
}

/// Applies coach-style load text ("205", "[145-155] R5-6", "75%", "R8-9", "max", "last +2.5").
void applyLoadText(PrescribedSet ps, String raw) {
  final t = raw.trim().toLowerCase();
  ps
    ..weight = null
    ..weightMax = null
    ..rpeMin = null
    ..rpeMax = null
    ..constant = false
    ..repeatUntil = false;
  if (t.isEmpty) {
    ps.loadType = LoadType.free;
    return;
  }
  if (t.startsWith('last')) {
    ps.loadType = LoadType.linear;
    ps.weight = parseNum(t.replaceAll(RegExp(r'[^0-9.,]'), '')) ?? 0;
    return;
  }
  final p = parsePrescription(raw);
  ps
    ..rpeMin = p.rpeMin
    ..rpeMax = p.rpeMax
    ..constant = p.isConstant
    ..repeatUntil = p.isRepeat;
  if (p.isMax) {
    ps.loadType = LoadType.max;
  } else if (p.isPercent) {
    ps.loadType = LoadType.pct;
    ps.weight = p.weight;
  } else if (p.weight != null) {
    ps.loadType = LoadType.abs;
    ps.weight = p.weight;
    ps.weightMax = p.weightMax;
  } else if (p.rpeMin != null) {
    ps.loadType = LoadType.rpe;
  } else {
    ps.loadType = LoadType.free;
  }
}

class RowCtl {
  final PrescribedSet set;
  final TextEditingController sets;
  final TextEditingController reps;
  final TextEditingController load;
  final TextEditingController note;
  RowCtl(this.set)
      : sets = TextEditingController(text: '${set.sets}'),
        reps = TextEditingController(text: set.repsText),
        load = TextEditingController(text: set.loadText == 'last +?' ? '' : set.loadText),
        note = TextEditingController(text: set.note);
}

class SetsEditor extends StatefulWidget {
  final String title;
  final int week;
  final int weekCount;
  final List<PrescribedSet> initial;
  const SetsEditor(
      {super.key, required this.title, required this.week, required this.weekCount, required this.initial});
  @override
  State<SetsEditor> createState() => _SetsEditorState();
}

class _SetsEditorState extends State<SetsEditor> {
  late final List<RowCtl> _rows = [for (final s in widget.initial) RowCtl(s.copyForWeek(widget.week))];
  final _step = TextEditingController(text: '2.5');

  List<PrescribedSet> _collect() {
    final out = <PrescribedSet>[];
    for (final r in _rows) {
      final s = r.set;
      s.sets = (int.tryParse(r.sets.text) ?? 1).clamp(1, 30);
      final (a, b) = parseReps(r.reps.text);
      s.repsMin = a;
      s.repsMax = b;
      s.note = r.note.text.trim();
      applyLoadText(s, r.load.text);
      out.add(s);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text('Week ${widget.week + 1}', style: TextStyle(color: context.muted)),
          const SizedBox(height: 4),
          Text(
            'Load examples: 205 · [145-155] R5-6 · 75% · R8-9 · max · last +2.5',
            style: TextStyle(color: context.muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(children: [
                Row(children: [
                  SizedBox(
                    width: 56,
                    child: TextField(
                      controller: _rows[i].sets,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(labelText: 'Sets'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: TextField(
                      controller: _rows[i].reps,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(labelText: 'Reps'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(controller: _rows[i].load, decoration: const InputDecoration(labelText: 'Load')),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _rows.removeAt(i)),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remove row',
                  ),
                ]),
                const SizedBox(height: 6),
                TextField(
                    controller: _rows[i].note,
                    decoration: const InputDecoration(labelText: 'Note (optional)', isDense: true)),
              ]),
            ),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add row'),
            onPressed: () => setState(
                () => _rows.add(RowCtl(PrescribedSet(weekIndex: widget.week, sets: 3, repsMin: 5, repsMax: 5)))),
          ),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: () => Navigator.pop(context, SheetResult(_collect())), child: const Text('Save this week')),
          if (widget.week < widget.weekCount - 1) ...[
            const SizedBox(height: 12),
            Row(children: [
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _step,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: '+kg / week'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    SheetResult(_collect(), propagate: true, step: parseNum(_step.text) ?? 0),
                  ),
                  child: const Text('Save & fill later weeks'),
                ),
              ),
            ]),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context, SheetResult(const [], removeExercise: true)),
            child: const Text('Remove exercise from this day', style: TextStyle(color: AppColors.danger)),
          ),
        ]),
      ),
    );
  }
}
