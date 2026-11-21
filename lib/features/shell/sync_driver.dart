import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

/// Háttér-szinkron, amíg az app nyitva van: induláskor, visszatéréskor és
/// félpercenként megnézi, van-e elküldendő napló / változott terv.
/// Ha nincs net, a változások helyben maradnak és később mennek el.
class SyncDriver extends ConsumerStatefulWidget {
  final Widget child;
  const SyncDriver({super.key, required this.child});
  @override
  ConsumerState<SyncDriver> createState() => _SyncDriverState();
}

class _SyncDriverState extends ConsumerState<SyncDriver> with WidgetsBindingObserver {
  Timer? _timer;
  Timer? _first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _tick());
    _first = Timer(const Duration(seconds: 2), () => _tick(force: true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _first?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick(force: true);
  }

  void _tick({bool force = false}) {
    if (!mounted) return;
    ref.read(sheetsSyncProvider.notifier).tick(forcePull: force);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
