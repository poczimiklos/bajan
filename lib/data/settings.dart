import 'package:shared_preferences/shared_preferences.dart';
import '../domain/e1rm.dart';

class AppSettings {
  final String username;
  final String sex; // m | f
  final String experience;
  final String goals;
  final String unit; // kg | lb
  final E1rmFormula formula;
  final String rpeScale; // rpe | rir
  final String theme; // dark | light | system
  final int restSeconds;
  final bool autoRest;
  final double barKg;
  final String? activeBlockId;
  final Map<String, double> trainingMax; // lift -> kg (0 = auto)

  const AppSettings({
    this.username = 'Lifter',
    this.sex = 'm',
    this.experience = '',
    this.goals = '',
    this.unit = 'kg',
    this.formula = E1rmFormula.rpeChart,
    this.rpeScale = 'rpe',
    this.theme = 'dark',
    this.restSeconds = 180,
    this.autoRest = true,
    this.barKg = 20,
    this.activeBlockId,
    this.trainingMax = const {},
  });

  bool get isLb => unit == 'lb';
  double toDisplay(double kg) => isLb ? kg * 2.2046226218 : kg;
  double toKg(double shown) => isLb ? shown / 2.2046226218 : shown;
  String get unitLabel => unit;

  AppSettings copyWith({
    String? username,
    String? sex,
    String? experience,
    String? goals,
    String? unit,
    E1rmFormula? formula,
    String? rpeScale,
    String? theme,
    int? restSeconds,
    bool? autoRest,
    double? barKg,
    Object? activeBlockId = _unset,
    Map<String, double>? trainingMax,
  }) =>
      AppSettings(
        username: username ?? this.username,
        sex: sex ?? this.sex,
        experience: experience ?? this.experience,
        goals: goals ?? this.goals,
        unit: unit ?? this.unit,
        formula: formula ?? this.formula,
        rpeScale: rpeScale ?? this.rpeScale,
        theme: theme ?? this.theme,
        restSeconds: restSeconds ?? this.restSeconds,
        autoRest: autoRest ?? this.autoRest,
        barKg: barKg ?? this.barKg,
        activeBlockId: identical(activeBlockId, _unset) ? this.activeBlockId : activeBlockId as String?,
        trainingMax: trainingMax ?? this.trainingMax,
      );

  factory AppSettings.load(SharedPreferences p) => AppSettings(
        username: p.getString('username') ?? 'Lifter',
        sex: p.getString('sex') ?? 'm',
        experience: p.getString('experience') ?? '',
        goals: p.getString('goals') ?? '',
        unit: p.getString('unit') ?? 'kg',
        formula: E1rmFormula.values.firstWhere(
          (f) => f.name == p.getString('formula'),
          orElse: () => E1rmFormula.rpeChart,
        ),
        rpeScale: p.getString('rpeScale') ?? 'rpe',
        theme: p.getString('theme') ?? 'dark',
        restSeconds: p.getInt('restSeconds') ?? 180,
        autoRest: p.getBool('autoRest') ?? true,
        barKg: p.getDouble('barKg') ?? 20,
        activeBlockId: p.getString('activeBlockId'),
        trainingMax: {
          for (final l in const ['squat', 'bench', 'deadlift']) l: p.getDouble('tm_$l') ?? 0,
        },
      );

  Future<void> save(SharedPreferences p) async {
    await p.setString('username', username);
    await p.setString('sex', sex);
    await p.setString('experience', experience);
    await p.setString('goals', goals);
    await p.setString('unit', unit);
    await p.setString('formula', formula.name);
    await p.setString('rpeScale', rpeScale);
    await p.setString('theme', theme);
    await p.setInt('restSeconds', restSeconds);
    await p.setBool('autoRest', autoRest);
    await p.setDouble('barKg', barKg);
    if (activeBlockId == null) {
      await p.remove('activeBlockId');
    } else {
      await p.setString('activeBlockId', activeBlockId!);
    }
    for (final e in trainingMax.entries) {
      await p.setDouble('tm_${e.key}', e.value);
    }
  }
}

const Object _unset = Object();
