import 'package:shared_preferences/shared_preferences.dart';
import '../block1_program.dart' show block1ProgramName;
import '../models.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/program_repository.dart';
import 'plan_builder.dart';
import 'sheet_plan.dart';

class ImportResult {
  final bool changed;
  final String? activeCandidate;
  final Set<String> sheetBlockIds;
  final Set<String> allBlockIds;
  const ImportResult({
    required this.changed,
    required this.activeCandidate,
    required this.sheetBlockIds,
    required this.allBlockIds,
  });
}

/// Melyik blokk legyen aktív: a mai napot tartalmazó, különben a következő,
/// különben a legutóbbi.
String? pickActiveBlock(List<ProgramBlock> blocks, DateTime today) {
  final dated = blocks.where((b) => b.startDate != null).toList();
  if (dated.isEmpty) return blocks.isEmpty ? null : blocks.last.id;
  final t = DateTime(today.year, today.month, today.day);
  DateTime end(ProgramBlock b) => DateTime(b.startDate!.year, b.startDate!.month, b.startDate!.day + b.weekCount * 7);
  final current = dated.where((b) => !t.isBefore(b.startDate!) && t.isBefore(end(b))).toList()
    ..sort((a, b) => b.startDate!.compareTo(a.startDate!));
  if (current.isNotEmpty) return current.first.id;
  final upcoming = dated.where((b) => b.startDate!.isAfter(t)).toList()
    ..sort((a, b) => a.startDate!.compareTo(b.startDate!));
  if (upcoming.isNotEmpty) return upcoming.first.id;
  final past = [...dated]..sort((a, b) => b.startDate!.compareTo(a.startDate!));
  return past.first.id;
}

/// A Block-N fülek beolvasása a helyi adatbázisba. A blokk- és napazonosítók
/// megmaradnak, így a korábbi edzések hivatkozásai nem törnek el.
class SheetImporter {
  final ProgramRepository _programs;
  final ExerciseRepository _exercises;
  final SharedPreferences _prefs;
  SheetImporter(this._programs, this._exercises, this._prefs);

  Future<ImportResult> importAll(SheetPlans res, {bool force = false}) async {
    final known = await _exercises.all(includeArchived: true);
    final resolver = ExerciseResolver(known);
    final programs = await _programs.all();

    final title = res.title.trim().isEmpty ? 'Google Sheets' : res.title.trim();
    Program? prog = programs.where((p) => p.name == title).firstOrNull ??
        programs.where((p) => p.name == block1ProgramName).firstOrNull;
    var changed = false;
    if (prog == null) {
      prog = Program(name: title, description: 'Google Sheets-ből szinkronizálva');
      changed = true;
    } else if (prog.name != title) {
      prog.name = title; // a korábbi beégetett Block1 átvétele
      changed = true;
    }

    final hashes = <String, String>{};
    for (final plan in res.plans) {
      final key = 'sheet_hash_${normName(plan.sheet)}';
      final idx = prog.blocks.indexWhere((b) => normName(b.name) == normName(plan.sheet));
      final existing = idx >= 0 ? prog.blocks[idx] : null;
      if (!force && existing != null && _prefs.getString(key) == plan.hash) continue;
      final block = buildBlock(plan, resolver, existing: existing);
      if (idx >= 0) {
        prog.blocks[idx] = block;
      } else {
        prog.blocks.add(block);
      }
      hashes[key] = plan.hash;
      changed = true;
    }

    if (changed) {
      for (final e in resolver.created) {
        await _exercises.save(e);
      }
      await _programs.save(prog);
      for (final e in hashes.entries) {
        await _prefs.setString(e.key, e.value);
      }
    }

    final sheetNames = {for (final p in res.plans) normName(p.sheet)};
    final sheetBlocks = prog.blocks.where((b) => sheetNames.contains(normName(b.name))).toList();
    final all = <String>{
      for (final p in programs.where((p) => p.id != prog!.id)) ...p.blocks.map((b) => b.id),
      ...prog.blocks.map((b) => b.id),
    };
    return ImportResult(
      changed: changed,
      activeCandidate: pickActiveBlock(sheetBlocks, DateTime.now()),
      sheetBlockIds: {for (final b in sheetBlocks) b.id},
      allBlockIds: all,
    );
  }
}
