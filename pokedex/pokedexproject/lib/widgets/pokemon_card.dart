import 'package:flutter/material.dart';
import 'package:pokedexproject/class/pokemon.dart';

const Map<String, Color> typeColors = {
  'normal': Colors.brown,
  'fire': Colors.red,
  'water': Colors.blue,
  'electric': Colors.yellow,
  'grass': Colors.green,
  'ice': Colors.cyan,
  'fighting': Colors.orange,
  'poison': Colors.purple,
  'ground': Colors.brown,
  'flying': Colors.lightBlue,
  'psychic': Colors.pink,
  'bug': Colors.lightGreen,
  'rock': Colors.grey,
  'ghost': Colors.indigo,
  'dragon': Colors.deepPurple,
  'dark': Colors.black,
  'steel': Colors.blueGrey,
  'fairy': Colors.pinkAccent,
};

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final Function(Pokemon) onTap;
  final VoidCallback onFavoriteToggle;

  const PokemonCard({
    Key? key,
    required this.pokemon,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  Widget _buildTypeChip(String type) {
    final Color typeColor = typeColors[type.toLowerCase()] ?? Colors.grey;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: typeColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: typeColor,
          width: 1,
        ),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String primaryType = pokemon.types.first.toLowerCase();
    final Color cardColor = typeColors[primaryType] ?? Colors.grey;

    return GestureDetector(
      onTap: () => onTap(pokemon),
      child: Card(
        color: cardColor.withOpacity(0.1),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: cardColor, width: 2),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15.0)),
                    child: Image.network(
                      pokemon.url,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black26
                        : Colors.white38,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        pokemon.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: pokemon.types
                            .map((type) => Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  child: _buildTypeChip(type),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  pokemon.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: pokemon.isFavorite ? Colors.red : Colors.black54,
                ),
                onPressed: () => onFavoriteToggle(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
