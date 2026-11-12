import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// A labelled row of mutually exclusive chips.
class ChoiceRow<T> extends StatelessWidget {
  final String title;
  final T value;
  final Map<T, String> options;
  final void Function(T) onChanged;
  const ChoiceRow(this.title, this.value, this.options, this.onChanged, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: context.muted, fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 4, children: [
            for (final e in options.entries)
              ChoiceChip(label: Text(e.value), selected: value == e.key, onSelected: (_) => onChanged(e.key)),
          ]),
        ]),
      );
}
