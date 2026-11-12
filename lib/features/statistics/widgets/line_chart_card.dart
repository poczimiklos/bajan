import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/settings.dart';
import '../../../domain/stats.dart';

class LineChartCard extends StatelessWidget {
  final List<DatedValue> points;
  final AppSettings settings;
  const LineChartCard({super.key, required this.points, required this.settings});

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return Center(
        child: Text(points.isEmpty ? 'No data in this range' : 'Need at least two sessions to draw a trend',
            style: TextStyle(color: context.muted)),
      );
    }
    final t0 = points.first.date.millisecondsSinceEpoch.toDouble();
    const day = 86400000.0;
    final spots = [
      for (final p in points) FlSpot((p.date.millisecondsSinceEpoch - t0) / day, settings.toDisplay(p.value)),
    ];
    final ys = spots.map((s) => s.y);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);
    final pad = ((maxY - minY) * 0.15).clamp(2, 1000).toDouble();
    final spanDays = spots.last.x.clamp(1, 100000).toDouble();
    return LineChart(LineChartData(
      minY: (minY - pad).floorToDouble(),
      maxY: (maxY + pad).ceilToDouble(),
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
            reservedSize: 42,
            getTitlesWidget: (v, m) =>
                Text(fmtNum(v, decimals: 0), style: TextStyle(color: context.muted, fontSize: 10)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            interval: (spanDays / 4).clamp(1, 100000).toDouble(),
            getTitlesWidget: (v, m) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                DateFormat('d MMM').format(DateTime.fromMillisecondsSinceEpoch((t0 + v * day).round())),
                style: TextStyle(color: context.muted, fontSize: 10),
              ),
            ),
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touched) => [
            for (final t in touched)
              LineTooltipItem(
                '${fmtNum(t.y)} ${settings.unitLabel}\n${DateFormat('d MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch((t0 + t.x * day).round()))}',
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
          ],
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          preventCurveOverShooting: true,
          color: context.accent,
          barWidth: 3,
          dotData: FlDotData(show: spots.length <= 40),
          belowBarData: BarAreaData(show: true, color: context.accent.withValues(alpha: 0.12)),
        ),
      ],
    ));
  }
}
