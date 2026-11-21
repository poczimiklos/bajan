import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/checkin.dart';
import '../../providers/sheets_sync.dart';

/// Napi check-in: alvás / fáradtság / felkészültség (1–5), koffein, kreatin.
/// Minden módosítás azonnal mentődik, és a táblázat „Check-in" fülére is felkerül.
class CheckInCard extends ConsumerWidget {
  const CheckInCard({super.key});

  static const _caffeineStep = 50;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(todayCheckInProvider);
    final notifier = ref.read(todayCheckInProvider.notifier);

    Widget scale(String label, int? value, void Function(int?) onPick) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            SizedBox(width: 96, child: Text(label, style: TextStyle(color: context.muted))),
            for (var i = 1; i <= 5; i++)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text('$i'),
                  selected: value == i,
                  onSelected: (on) => onPick(on ? i : null),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ]),
        );

    final summary = c.isEmpty
        ? 'Alvás, fáradtság, felkészültség (1–5), koffein, kreatin'
        : [
            'Alvás ${c.sleep ?? '–'}',
            'Fáradtság ${c.fatigue ?? '–'}',
            'Felk. ${c.readiness ?? '–'}',
            if (c.caffeineMg > 0) '${c.caffeineMg} mg koffein',
            if (c.creatineG > 0) 'kreatin ✓',
          ].join(' · ');

    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: c.isEmpty,
          title: const Text('Check-in', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(summary, style: TextStyle(color: context.muted, fontSize: 12)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: [
            scale('Alvás', c.sleep, (v) => notifier.update((x) => x.copyWith(sleep: v))),
            scale('Fáradtság', c.fatigue, (v) => notifier.update((x) => x.copyWith(fatigue: v))),
            scale('Felkészültség', c.readiness, (v) => notifier.update((x) => x.copyWith(readiness: v))),
            const SizedBox(height: 4),
            Row(children: [
              SizedBox(width: 96, child: Text('Koffein', style: TextStyle(color: context.muted))),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: c.caffeineMg <= 0
                    ? null
                    : () => notifier.update((x) => x.copyWith(caffeineMg: (x.caffeineMg - _caffeineStep).clamp(0, 2000))),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              SizedBox(
                width: 72,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text('${c.caffeineMg} mg',
                      key: ValueKey(c.caffeineMg),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () =>
                    notifier.update((x) => x.copyWith(caffeineMg: (x.caffeineMg + _caffeineStep).clamp(0, 2000))),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ]),
            Row(children: [
              SizedBox(width: 96, child: Text('Kreatin', style: TextStyle(color: context.muted))),
              Switch(
                value: c.creatineG > 0,
                onChanged: (on) => notifier.update((x) => x.copyWith(creatineG: on ? 5 : 0)),
              ),
              Text(c.creatineG > 0 ? '${fmtNum(c.creatineG)} g' : 'nem', style: TextStyle(color: context.muted)),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Rövid, animált belépő effekt a kártyákhoz.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int delayMs;
  const FadeSlideIn({super.key, required this.child, this.delayMs = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 18), child: child),
      ),
      child: child,
    );
  }
}

String checkInSummaryDate(CheckIn c) => dayKey(c.date);
