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
      height: 300, // Increased from default height
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          maxY: 200,
          minY: 0,
          groupsSpace: 12,
          barGroups: [
            makeGroupData(0, stats['hp'] ?? 0, Colors.green),
            makeGroupData(1, stats['attack'] ?? 0, Colors.red),
            makeGroupData(2, stats['defense'] ?? 0, Colors.blue),
            makeGroupData(
                3, stats['special-attack'] ?? 0, Colors.deepPurpleAccent),
            makeGroupData(4, stats['special-defense'] ?? 0, Colors.pink),
            makeGroupData(5, stats['speed'] ?? 0, Colors.grey),
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: bottomTitles,
                reservedSize: 42,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 20,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
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
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 200,
            color: color.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('HP', style: style);
        break;
      case 1:
        text = const Text('ATK', style: style);
        break;
      case 2:
        text = const Text('DEF', style: style);
        break;
      case 3:
        text = const Text('SpA', style: style);
        break;
      case 4:
        text = const Text('SpD', style: style);
        break;
      case 5:
        text = const Text('SPD', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4.0,
      child: text,
    );
  }
}
