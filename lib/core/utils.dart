import 'package:flutter/material.dart';

/// Formats a number without trailing zeros: 100.0 -> "100", 102.5 -> "102.5".
String fmtNum(num? v, {int decimals = 1}) {
  if (v == null) return '–';
  final s = v.toStringAsFixed(decimals);
  if (!s.contains('.')) return s;
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}

double? parseNum(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

void snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
}
