import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/sheets/sheets_client.dart';
import '../../../providers/providers.dart';

String _t(DateTime? d) {
  if (d == null) return '–';
  String p(int n) => n.toString().padLeft(2, '0');
  return '${p(d.month)}.${p(d.day)}. ${p(d.hour)}:${p(d.minute)}';
}

/// Google Sheets kapcsolat: Apps Script webapp URL + token.
class SheetsSection extends ConsumerStatefulWidget {
  const SheetsSection({super.key});
  @override
  ConsumerState<SheetsSection> createState() => _SheetsSectionState();
}

class _SheetsSectionState extends ConsumerState<SheetsSection> {
  late final TextEditingController _url;
  late final TextEditingController _token;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    final c = ref.read(sheetsConfigProvider);
    _url = TextEditingController(text: c.url);
    _token = TextEditingController(text: c.token);
  }

  @override
  void dispose() {
    _url.dispose();
    _token.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(sheetsConfigProvider.notifier).save(_url.text, _token.text);
    if (!mounted) return;
    snack(context, 'Mentve. Szinkronizálás…');
    await ref.read(sheetsSyncProvider.notifier).syncNow();
  }

  Future<void> _test() async {
    setState(() => _testing = true);
    try {
      await ref.read(sheetsConfigProvider.notifier).save(_url.text, _token.text);
      final info = await ref.read(sheetsSyncProvider.notifier).testConnection();
      if (mounted) snack(context, 'Kapcsolat rendben: $info');
    } on SheetsException catch (e) {
      if (mounted) snack(context, 'Hiba: ${e.message}');
    } catch (e) {
      if (mounted) snack(context, 'Hiba: $e');
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(sheetsSyncProvider);
    final cfg = ref.watch(sheetsConfigProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SectionTitle('Google Sheets'),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'A terv a táblázat Block-N füleiről jön, a naplód és a check-ined pedig visszakerül a Napló, Edzések és Check-in fülekre.',
            style: TextStyle(color: context.muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Webalkalmazás URL', hintText: 'https://script.google.com/macros/s/…/exec'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _token,
            autocorrect: false,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Token'),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton(onPressed: _save, child: const Text('Mentés és szinkron')),
            OutlinedButton(onPressed: _testing ? null : _test, child: Text(_testing ? 'Teszt…' : 'Kapcsolat tesztelése')),
            if (cfg.configured)
              OutlinedButton(
                onPressed: sync.busy ? null : () => ref.read(sheetsSyncProvider.notifier).syncNow(),
                child: Text(sync.busy ? 'Szinkron…' : 'Szinkron most'),
              ),
          ]),
          const SizedBox(height: 12),
          Text('Terv utoljára: ${_t(sync.lastPull)}   ·   Napló utoljára: ${_t(sync.lastPush)}',
              style: TextStyle(color: context.muted, fontSize: 12)),
          Text('Küldésre vár: ${sync.pending}', style: TextStyle(color: context.muted, fontSize: 12)),
          if (sync.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Hiba: ${sync.error}', style: const TextStyle(color: AppColors.danger, fontSize: 12)),
            ),
        ]),
      ),
    ]);
  }
}
