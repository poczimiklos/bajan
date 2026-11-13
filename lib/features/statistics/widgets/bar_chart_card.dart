import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/settings.dart';
import '../../../domain/stats.dart';

class BarChartCard extends StatelessWidget {
  final List<DatedValue> points;
  final AppSettings settings;
  final DateFormat labelFmt;
  const BarChartCard({super.key, required this.points, required this.settings, required this.labelFmt});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return Center(child: Text('No data in this range', style: TextStyle(color: context.muted)));
    final shown = points.length > 26 ? points.sublist(points.length - 26) : points;
    final every = (shown.length / 5).ceil().clamp(1, 100);
    return BarChart(BarChartData(
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (v) => FlLine(color: context.muted.withValues(alpha: 0.15), strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 46,
            getTitlesWidget: (v, m) => Text(
              v >= 1000 ? '${fmtNum(v / 1000)}k' : fmtNum(v, decimals: 0),
              style: TextStyle(color: context.muted, fontSize: 10),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            getTitlesWidget: (v, m) {
              final i = v.toInt();
              if (i < 0 || i >= shown.length || i % every != 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(labelFmt.format(shown[i].date), style: TextStyle(color: context.muted, fontSize: 10)),
              );
            },
          ),
        ),
      ),
      barGroups: [
        for (var i = 0; i < shown.length; i++)
          BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: settings.toDisplay(shown[i].value),
              color: context.accent,
              width: shown.length > 14 ? 7 : 14,
              borderRadius: BorderRadius.zero,
            ),
          ]),
      ],
    ));
  }
}
