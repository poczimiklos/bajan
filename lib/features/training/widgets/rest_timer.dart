import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/providers.dart';

class RestTimerBar extends ConsumerStatefulWidget {
  const RestTimerBar({super.key});
  @override
  ConsumerState<RestTimerBar> createState() => _RestTimerBarState();
}

class _RestTimerBarState extends ConsumerState<RestTimerBar> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final t = ref.read(restTimerProvider);
      if (!t.active) return;
      if (!DateTime.now().isBefore(t.endsAt!)) {
        HapticFeedback.heavyImpact();
        ref.read(restTimerProvider.notifier).stop();
      } else if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(restTimerProvider);
    if (!t.active) return const SizedBox.shrink();
    final remaining = t.endsAt!.difference(DateTime.now()).inMilliseconds.clamp(0, 1 << 30);
    final secs = (remaining / 1000).ceil();
    final progress = t.total == 0 ? 0.0 : 1 - remaining / (t.total * 1000);
    final glow = 0.08 + 0.12 * (1 + math.sin(DateTime.now().millisecondsSinceEpoch / 360)) / 2;
    final mm = (secs ~/ 60).toString().padLeft(1, '0');
    final ss = (secs % 60).toString().padLeft(2, '0');
    final n = ref.read(restTimerProvider.notifier);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      decoration: ShapeDecoration(
        color: context.cardBg,
        shape: BeveledRectangleBorder(side: BorderSide(color: context.accent.withValues(alpha: 0.7))),
        shadows: [BoxShadow(color: context.accent.withValues(alpha: glow), blurRadius: 16)],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const BeveledRectangleBorder(),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0), minHeight: 3, color: context.accent, backgroundColor: context.fieldBg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(children: [
              Icon(Icons.timer_outlined, color: context.accent),
              const SizedBox(width: 8),
              Text('$mm:$ss',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
              const Spacer(),
              TextButton(onPressed: () => n.add(-15), child: const Text('−15s')),
              TextButton(onPressed: () => n.add(15), child: const Text('+15s')),
              IconButton(onPressed: n.stop, icon: const Icon(Icons.close), tooltip: 'Skip rest'),
            ]),
          ),
        ]),
      ),
    );
  }
}
