import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ElapsedTimer extends StatefulWidget {
  final DateTime start;
  const ElapsedTimer({super.key, required this.start});
  @override
  State<ElapsedTimer> createState() => _ElapsedState();
}

class _ElapsedState extends State<ElapsedTimer> {
  Timer? _t;
  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = DateTime.now().difference(widget.start);
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return Text(h > 0 ? '$h:$m:$s' : '$m:$s', style: TextStyle(fontSize: 12, color: context.muted));
  }
}
