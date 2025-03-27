import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pokedexproject/widgets/pokemon_card.dart';

class PokemonStatsChart extends StatelessWidget {
  final Map<String, int> stats;
  final Color color;

  const PokemonStatsChart({
    Key? key,
    required this.stats,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 350,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor!,
              backgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              'Base Stats',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  maxY: 255, // Maximum possible stat value
                  minY: 0,
                  groupsSpace: 20,
                  barGroups: [
                    makeGroupData(0, stats['hp'] ?? 0, Colors.green.shade400),
                    makeGroupData(1, stats['attack'] ?? 0, Colors.red.shade400),
                    makeGroupData(
                        2, stats['defense'] ?? 0, Colors.blue.shade400),
                    makeGroupData(3, stats['special-attack'] ?? 0,
                        Colors.purple.shade400),
                    makeGroupData(
                        4, stats['special-defense'] ?? 0, Colors.pink.shade400),
                    makeGroupData(
                        5, stats['speed'] ?? 0, Colors.orange.shade400),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            bottomTitles(value, meta, textColor),
                        reservedSize: 35,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 50,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 50,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: textColor.withOpacity(0.1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, int y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          color: color,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 255,
            color: color.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta, Color textColor) {
    final style = TextStyle(
      color: textColor,
      fontWeight: FontWeight.w600,
      fontSize: 13,
    );

    final Map<int, String> titles = {
      0: 'HP',
      1: 'ATK',
      2: 'DEF',
      3: 'Sp.A',
      4: 'Sp.D',
      5: 'SPD',
    };

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: Text(
          titles[value.toInt()] ?? '',
          style: style,
        ),
      ),
    );
  }
}
