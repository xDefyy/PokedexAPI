import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pokedexproject/class/pokemon.dart';
import 'package:pokedexproject/data/characterr_api.dart';
import 'package:pokedexproject/widgets/pokemon_card.dart'; // For typeColors map

class PokemonCompareScreen extends StatefulWidget {
  const PokemonCompareScreen({super.key});

  @override
  State<PokemonCompareScreen> createState() => _PokemonCompareScreenState();
}

class _PokemonCompareScreenState extends State<PokemonCompareScreen> {
  Pokemon? firstPokemon;
  Pokemon? secondPokemon;
  final CharacterApi _characterApi = CharacterApi();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final borderColor = isDarkMode ? Colors.white24 : Colors.black12;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Pokemon'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pokemon selectors
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: _buildPokemonSelector(true, isDarkMode)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPokemonSelector(false, isDarkMode)),
                ],
              ),
            ),
            // Stats comparison card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Stats Comparison',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildStatsComparison(textColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatLegend(textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonSelector(bool isFirst, bool isDarkMode) {
    final pokemon = isFirst ? firstPokemon : secondPokemon;
    final typeColor = pokemon != null
        ? typeColors[pokemon.types.first.toLowerCase()] ?? Colors.grey
        : (isDarkMode ? Colors.white24 : Colors.black12);

    return Container(
      height: 180, // Increased height for types
      decoration: BoxDecoration(
        border: Border.all(
          color: typeColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _selectPokemon(isFirst),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (pokemon != null) ...[
              Image.network(
                pokemon.url,
                height: 100,
                width: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                pokemon.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: pokemon.types
                    .map((type) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColors[type.toLowerCase()]
                                  ?.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              type,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ] else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.catching_pokemon,
                    size: 48,
                    color: isDarkMode ? Colors.white54 : Colors.black38,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select ${isFirst ? "First" : "Second"} Pokemon',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsComparison(Color textColor) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: 255,
        minY: 0,
        groupsSpace: 12, // Reduced space
        barGroups: _createBarGroups(),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) =>
                  _bottomTitles(value, meta, textColor),
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 50,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) => FlLine(
            color: textColor.withOpacity(0.1),
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    final stats = [
      'hp',
      'attack',
      'defense',
      'special-attack',
      'special-defense',
      'speed'
    ];

    Color getColorForStat(int index, Pokemon? pokemon) {
      if (pokemon == null) return Colors.grey.shade300;
      final type = pokemon.types.first.toLowerCase();
      final baseColor = typeColors[type] ?? Colors.grey;

      switch (index) {
        case 0:
          return baseColor.withOpacity(0.8); // HP
        case 1:
          return baseColor.withOpacity(0.9); // Attack
        case 2:
          return baseColor.withOpacity(0.7); // Defense
        case 3:
          return baseColor.withOpacity(1.0); // Sp. Attack
        case 4:
          return baseColor.withOpacity(0.6); // Sp. Defense
        case 5:
          return baseColor.withOpacity(0.8); // Speed
        default:
          return baseColor;
      }
    }

    return List.generate(6, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (firstPokemon?.baseStats[stats[index]] ?? 0).toDouble(),
            color: getColorForStat(index, firstPokemon),
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 255,
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
          BarChartRodData(
            toY: (secondPokemon?.baseStats[stats[index]] ?? 0).toDouble(),
            color: getColorForStat(index, secondPokemon),
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 255,
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
        ],
      );
    });
  }

  Widget _bottomTitles(double value, TitleMeta meta, Color textColor) {
    const titles = ['HP', 'ATK', 'DEF', 'Sp.A', 'Sp.D', 'SPD'];
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        titles[value.toInt()],
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatLegend(Color textColor) {
    const statDescriptions = {
      'HP': 'Total health points',
      'ATK': 'Physical attack power',
      'DEF': 'Physical defense power',
      'Sp.A': 'Special attack power',
      'Sp.D': 'Special defense power',
      'SPD': 'Movement speed'
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: statDescriptions.entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _selectPokemon(bool isFirst) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              const Text(
                'Select Pokemon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Pokemon>>(
                  future: _characterApi.getAllPokemons(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final pokemon = snapshot.data![index];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isFirst) {
                                  firstPokemon = pokemon;
                                } else {
                                  secondPokemon = pokemon;
                                }
                              });
                              Navigator.pop(context);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  pokemon.url,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pokemon.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
