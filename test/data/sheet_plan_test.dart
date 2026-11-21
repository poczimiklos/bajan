import 'package:flutter_test/flutter_test.dart';
import 'package:powerlifting_tracker/data/models.dart';
import 'package:powerlifting_tracker/data/sheets/plan_builder.dart';
import 'package:powerlifting_tracker/data/sheets/sheet_plan.dart';

void main() {
  test('a táblázat cellái előírássá alakulnak', () {
    final a = parseCell(const SheetCell(week: 0, name: 'x', sets: '2', reps: '8-7', load: 'm+5'), 0, 0);
    expect(a.loadType, LoadType.max);
    expect(a.repsMin, 8);
    expect(a.repsMax, 7);

    final b = parseCell(const SheetCell(week: 0, name: 'x', sets: '3', reps: '5', load: '@8', note: 'topset kinti'), 0, 0);
    expect(b.loadType, LoadType.rpe);
    expect(b.rpeMin, 8);
    expect(b.setType, SetType.top);
    expect(b.note, 'kinti');

    final c = parseCell(const SheetCell(week: 0, name: 'x', sets: '1', reps: '3', load: '197,5-200'), 0, 0);
    expect(c.weight, 197.5);
    expect(c.weightMax, 200);
  });

  test('főemelésnél a legnehezebb sor top set, utána back-off', () {
    const sq = Exercise(id: 'comp_deadlift', name: 'Deadlift', category: 'main', lift: Lift.deadlift);
    SheetCell cell(String sets, String reps, String load) => SheetCell(week: 0, name: 'deadlift', sets: sets, reps: reps, load: load);
    final plan = SheetPlan(sheet: 'Block-1', weeks: 1, startDate: DateTime(2026, 10, 20), days: [
      SheetDay('csutortok', 4, [
        SheetLine(1, [cell('1', '2', '225')]),
        SheetLine(2, [cell('1', '1', '235')]),
        SheetLine(3, [cell('3', '4', '195')]),
      ]),
    ]);
    final block = buildBlock(plan, ExerciseResolver([sq]));
    final sets = block.days.single.exercises.single.sets;
    expect(sets.map((s) => s.setType), [SetType.working, SetType.top, SetType.backoff]);
    expect(block.days.single.name, 'Csütörtök');
  });
}
