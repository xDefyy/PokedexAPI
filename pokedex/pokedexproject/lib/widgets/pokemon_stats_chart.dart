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
    return Container(
      height: 200,
      padding: EdgeInsets.all(8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          maxY: 200,
          minY: 0,
          groupsSpace: 12,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black87,
              tooltipRoundedRadius: 8,
              tooltipPadding: EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String statName =
                    stats.keys.elementAt(group.x.toInt()).toUpperCase();
                return BarTooltipItem(
                  '$statName\n${rod.toY.toInt()}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= stats.keys.length) {
                    return Container();
                  }
                  String text = stats.keys
                      .elementAt(value.toInt())
                      .split('-')
                      .map((word) => word[0].toUpperCase())
                      .join('');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 50,
            checkToShowHorizontalLine: (value) => value % 50 == 0,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.black12,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black12),
          ),
          barGroups: stats.entries.map((entry) {
            return BarChartGroupData(
              x: stats.keys.toList().indexOf(entry.key),
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: color,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 200,
                    color: color.withOpacity(0.1),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
