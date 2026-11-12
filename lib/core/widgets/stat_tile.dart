import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color? valueColor;
  const StatTile({super.key, required this.label, required this.value, this.unit, this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            if (icon != null) ...[Icon(icon, size: 14, color: context.muted), const SizedBox(width: 4)],
            Flexible(
                child:
                    Text(label, style: TextStyle(color: context.muted, fontSize: 12), overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(value,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: valueColor),
                    overflow: TextOverflow.ellipsis),
              ),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Text(unit!, style: TextStyle(color: context.muted, fontSize: 12))
              ],
            ],
          ),
        ],
      ),
    );
  }
}
