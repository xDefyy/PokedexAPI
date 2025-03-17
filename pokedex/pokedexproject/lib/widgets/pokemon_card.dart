import 'package:flutter/material.dart';
import 'package:pokedexproject/class/pokemon.dart';

const Map<String, Color> typeColors = {
  'Normal': Colors.brown,
  'Fire': Colors.red,
  'Water': Colors.blue,
  'Electric': Colors.yellow,
  'Grass': Colors.green,
  'Ice': Colors.cyan,
  'Fighting': Colors.orange,
  'Poison': Colors.purple,
  'Ground': Colors.brown,
  'Flying': Colors.lightBlue,
  'Psychic': Colors.pink,
  'Bug': Colors.lightGreen,
  'Rock': Colors.grey,
  'Ghost': Colors.indigo,
  'Dragon': Colors.deepPurple,
  'Dark': Colors.black,
  'Steel': Colors.blueGrey,
  'Fairy': Colors.pinkAccent,
};

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final Function(Pokemon) onFavoriteToggle;
  final Function(Pokemon) onTap;

  const PokemonCard({
    Key? key,
    required this.pokemon,
    required this.onFavoriteToggle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener el tipo principal del Pokémon (primer tipo en la lista, por defecto 'Normal')
    final String primaryType =
        pokemon.types.isNotEmpty ? pokemon.types.first : 'Normal';
    final Color cardColor = typeColors[primaryType] ?? Colors.grey;

    return GestureDetector(
      onTap: () => onTap(pokemon),
      child: Card(
        color: cardColor.withOpacity(0.7), // Fondo con color basado en el tipo
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
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Center(
                          child: Text(
                            pokemon.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
                  color: pokemon.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () => onFavoriteToggle(pokemon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
