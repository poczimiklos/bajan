import 'dart:math' as math;

/// Supported estimated-1RM formulas.
enum E1rmFormula { epley, brzycki, lombardi, rpeChart }

extension E1rmFormulaLabel on E1rmFormula {
  String get label => switch (this) {
        E1rmFormula.epley => 'Epley',
        E1rmFormula.brzycki => 'Brzycki',
        E1rmFormula.lombardi => 'Lombardi',
        E1rmFormula.rpeChart => 'RPE chart',
      };
}

/// Fraction of 1RM for N reps performed at RPE 10 (index = reps, 1..12).
const List<double> _rpeChart = [
  0,
  1.0,
  0.955,
  0.922,
  0.892,
  0.863,
  0.837,
  0.811,
  0.786,
  0.762,
  0.739,
  0.707,
  0.680,
];

double _pct(double repsAtMax) {
  if (repsAtMax <= 1) return 1.0;
  if (repsAtMax >= 12) return _rpeChart[12];
  final lo = repsAtMax.floor();
  final f = repsAtMax - lo;
  return _rpeChart[lo] * (1 - f) + _rpeChart[lo + 1] * f;
}

/// Estimates a 1RM. Returns null when the input is not meaningful.
/// The RPE-chart method needs an RPE (>0); otherwise Epley is used.
double? estimate1RM({
  required double weight,
  required int reps,
  double? rpe,
  E1rmFormula formula = E1rmFormula.epley,
}) {
  if (weight <= 0 || reps <= 0) return null;
  switch (formula) {
    case E1rmFormula.rpeChart:
      if (rpe != null && rpe > 0) {
        final total = reps + (10 - rpe.clamp(0, 10));
        if (total <= 12) return weight / _pct(total.toDouble());
      }
      return reps == 1 ? weight : weight * (1 + reps / 30);
    case E1rmFormula.epley:
      return reps == 1 ? weight : weight * (1 + reps / 30);
    case E1rmFormula.brzycki:
      if (reps == 1) return weight;
      if (reps >= 37) return null;
      return weight * 36 / (37 - reps);
    case E1rmFormula.lombardi:
      return weight * math.pow(reps, 0.10).toDouble();
  }
}
