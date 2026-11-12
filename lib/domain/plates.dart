/// Plates needed on ONE side of the bar (greedy, heaviest first).
/// Returns null if the target cannot be built with the available plates.
List<double>? platesPerSide({
  required double target,
  double bar = 20,
  List<double> available = const [25, 20, 15, 10, 5, 2.5, 1.25],
}) {
  var rest = (target - bar) / 2;
  if (rest < 0) return null;
  final result = <double>[];
  final plates = [...available]..sort((a, b) => b.compareTo(a));
  for (final p in plates) {
    while (rest + 1e-9 >= p) {
      result.add(p);
      rest -= p;
    }
  }
  return rest.abs() < 1e-6 ? result : null;
}
