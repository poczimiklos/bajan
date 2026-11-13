import 'package:flutter_test/flutter_test.dart';
import 'package:powerlifting_tracker/data/block1_program.dart';
import 'package:powerlifting_tracker/data/models.dart';

void main() {
  test('imports the five-week Block1 plan with all three training days', () {
    final program = buildBlock1Program({
      'Tempo 4-2-0': 'tempo',
      'Low bar guggolás': 'low-bar',
      'bench': 'bench',
      'lehuzas magam melle': 'pulldown',
      'tarogatas': 'fly',
      'b francia': 'french-press',
      'oldal emeles': 'lateral-raise',
      'deadlift': 'deadlift',
      'szeles lehuzas': 'wide-pulldown',
      'kalapacsb': 'hammer-curl',
      'oldalemeles': 'lateral-raise',
      'squat': 'squat',
      'chest press alva': 'chest-press',
      'evezes szeles': 'row',
      'hatsoval': 'rear-delt',
      'cmbf': 'cmbf',
      'combh': 'combh',
    });

    final block = program.blocks.single;
    expect(program.name, block1ProgramName);
    expect(block.weekCount, 5);
    expect(block.days.map((day) => day.weekday), [DateTime.tuesday, DateTime.thursday, DateTime.saturday]);
    expect(block.days.map((day) => day.exercises.length), [7, 5, 8]);

    final tuesday = block.days.first;
    final squat = tuesday.exercises.firstWhere((exercise) => exercise.exerciseId == 'low-bar');
    expect(squat.forWeek(0).single.sets, 3);
    expect(squat.forWeek(2).single.weight, 192.5);
    expect(squat.forWeek(4).single.loadType, LoadType.free);

    final thursday = block.days[1];
    final widePulldown = thursday.exercises.firstWhere((exercise) => exercise.exerciseId == 'wide-pulldown');
    expect(widePulldown.forWeek(2).single.note, 'benedekfele · Terhelés: m+5');
    expect(widePulldown.forWeek(3).single.loadType, LoadType.max);

    final saturday = block.days.last;
    final chestPress = saturday.exercises.firstWhere((exercise) => exercise.exerciseId == 'chest-press');
    expect(chestPress.forWeek(0).single.repsText, '8-7');
    expect(chestPress.forWeek(0).single.weight, 18);
    expect(chestPress.forWeek(0).single.weightMax, 17);
  });
}
