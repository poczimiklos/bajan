/// Parsed form of the coach's load notation, e.g.
/// `195`, `195-200`, `[145-155] R5-6`, `[140-152,5]cR6`, `R8-9`,
/// `Repeat R8-9`, `max`, `75%`. Decimal commas are accepted.
class Prescription {
  final double? weight;
  final double? weightMax;
  final double? rpeMin;
  final double? rpeMax;
  final bool isMax;
  final bool isRepeat;
  final bool isConstant;
  final bool isPercent;
  const Prescription({
    this.weight,
    this.weightMax,
    this.rpeMin,
    this.rpeMax,
    this.isMax = false,
    this.isRepeat = false,
    this.isConstant = false,
    this.isPercent = false,
  });
}

final _rpeRe = RegExp(r'r(\d+(?:\.\d+)?)(?:-(\d+(?:\.\d+)?))?');
final _numRe = RegExp(r'(\d+(?:\.\d+)?)(?:-(\d+(?:\.\d+)?))?');

Prescription parsePrescription(String raw) {
  final s = raw.trim().toLowerCase().replaceAll(',', '.');
  if (s.isEmpty || s == '?') return const Prescription();
  if (s == 'max') return const Prescription(isMax: true);
  final isRepeat = s.contains('repeat');
  final isConstant = RegExp(r'\]\s*c').hasMatch(s);
  double? rMin, rMax;
  var rest = s.replaceAll('repeat', '');
  final rm = _rpeRe.firstMatch(rest);
  if (rm != null) {
    rMin = double.tryParse(rm.group(1)!);
    rMax = rm.group(2) != null ? double.tryParse(rm.group(2)!) : rMin;
    rest = rest.replaceRange(rm.start, rm.end, '');
  }
  final isPercent = rest.contains('%');
  rest = rest.replaceAll(RegExp(r'[\[\]c%]'), ' ');
  double? w, wMax;
  final nm = _numRe.firstMatch(rest);
  if (nm != null) {
    w = double.tryParse(nm.group(1)!);
    if (nm.group(2) != null) wMax = double.tryParse(nm.group(2)!);
  }
  return Prescription(
    weight: w,
    weightMax: wMax,
    rpeMin: rMin,
    rpeMax: rMax,
    isRepeat: isRepeat,
    isConstant: isConstant,
    isPercent: isPercent,
  );
}

/// Parses reps like `5`, `8-10`, `8-7` into (min, max).
(int?, int?) parseReps(String raw) {
  final m = RegExp(r'(\d+)(?:\s*-\s*(\d+))?').firstMatch(raw.trim());
  if (m == null) return (null, null);
  final a = int.parse(m.group(1)!);
  final b = m.group(2) != null ? int.parse(m.group(2)!) : a;
  return (a < b ? a : b, a < b ? b : a);
}
