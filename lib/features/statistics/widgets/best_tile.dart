import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../data/settings.dart';

class BestTile extends StatelessWidget {
  final String title;
  final SetRecord? rec;
  final AppSettings settings;
  final String Function(SetRecord) value;
  const BestTile(this.title, this.rec, this.settings, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    final r = rec;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              if (r != null)
                Text(
                  '${r.exerciseName} · ${fmtNum(settings.toDisplay(r.weight))}${settings.unitLabel} × ${r.reps} · ${DateFormat('d MMM yyyy').format(r.date)}',
                  style: TextStyle(color: context.muted, fontSize: 12),
                ),
            ]),
          ),
          Text(r == null ? '–' : value(r), style: TextStyle(color: context.accent, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}
