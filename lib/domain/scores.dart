/// DOTS relative strength score.
/// DOTS = total * 500 / (a + b*bw + c*bw^2 + d*bw^3 + e*bw^4)
double? dotsScore({required double totalKg, required double bodyweightKg, required bool male}) {
  if (totalKg <= 0 || bodyweightKg <= 0) return null;
  final c = male
      ? const [-307.75076, 24.0900756, -0.1918759221, 0.0007391293, -0.000001093]
      : const [-57.96288, 13.6175032, -0.1126655495, 0.0005158568, -0.0000010706];
  final b = bodyweightKg;
  final denom = c[0] + c[1] * b + c[2] * b * b + c[3] * b * b * b + c[4] * b * b * b * b;
  if (denom <= 0) return null;
  return totalKg * 500 / denom;
}
