import 'models.dart';

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Napi check-in (1–5 skálák + koffein + kreatin).
class CheckIn {
  final String id; // yyyy-MM-dd
  final DateTime date;
  final int? sleep, fatigue, readiness; // 1–5
  final int caffeineMg;
  final double creatineG;
  final String note;

  const CheckIn({
    required this.id,
    required this.date,
    this.sleep,
    this.fatigue,
    this.readiness,
    this.caffeineMg = 0,
    this.creatineG = 0,
    this.note = '',
  });

  factory CheckIn.empty(DateTime d) => CheckIn(id: dayKey(d), date: DateTime(d.year, d.month, d.day));

  bool get isEmpty =>
      sleep == null && fatigue == null && readiness == null && caffeineMg == 0 && creatineG == 0 && note.isEmpty;

  CheckIn copyWith({
    Object? sleep = _keep,
    Object? fatigue = _keep,
    Object? readiness = _keep,
    int? caffeineMg,
    double? creatineG,
    String? note,
  }) =>
      CheckIn(
        id: id,
        date: date,
        sleep: identical(sleep, _keep) ? this.sleep : sleep as int?,
        fatigue: identical(fatigue, _keep) ? this.fatigue : fatigue as int?,
        readiness: identical(readiness, _keep) ? this.readiness : readiness as int?,
        caffeineMg: caffeineMg ?? this.caffeineMg,
        creatineG: creatineG ?? this.creatineG,
        note: note ?? this.note,
      );

  DbRow toMap() => {
        'id': id,
        'date': date.millisecondsSinceEpoch,
        'sleep': sleep,
        'fatigue': fatigue,
        'readiness': readiness,
        'caffeine_mg': caffeineMg,
        'creatine_g': creatineG,
        'note': note,
        'updated_at': nowMs(),
      };

  factory CheckIn.fromMap(DbRow m) => CheckIn(
        id: m['id'] as String,
        date: fromMs(m['date'] as int),
        sleep: m['sleep'] as int?,
        fatigue: m['fatigue'] as int?,
        readiness: m['readiness'] as int?,
        caffeineMg: (m['caffeine_mg'] as int?) ?? 0,
        creatineG: ((m['creatine_g'] as num?) ?? 0).toDouble(),
        note: (m['note'] as String?) ?? '',
      );
}

const Object _keep = Object();
