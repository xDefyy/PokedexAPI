import 'package:flutter/material.dart';
import 'package:pokedexproject/class/pokemon.dart';
import 'package:pokedexproject/widgets/pokeball_loading.dart';

class PokemonListItem extends StatelessWidget {
  final Pokemon pokemon;
  final Function(Pokemon) onTap;
  final VoidCallback onFavoriteToggle;
  final bool isDarkMode;
  final Map<String, Color> typeColors;

  const PokemonListItem({
    Key? key,
    required this.pokemon,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isDarkMode,
    required this.typeColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String primaryType = pokemon.types.first.toLowerCase();
    final Color cardColor = typeColors[primaryType] ?? Colors.grey;

    return Card(
      key: ValueKey(pokemon.name),
      elevation: 0, // Changed from 5 to 0 to remove shadow
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: cardColor.withAlpha(26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: cardColor, width: 2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Hero(
          tag: 'pokemon-${pokemon.name}',
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.network(
              pokemon.url,
              fit: BoxFit.contain,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return const PokeballLoading();
              },
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image_rounded,
                size: 40,
                color: Colors.red,
              ),
            ),
          ),
        ),
        title: Text(
          pokemon.name,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: pokemon.types.map((type) {
              final Color typeColor =
                  typeColors[type.toLowerCase()] ?? Colors.grey;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 1), // Reduced padding
                margin: const EdgeInsets.only(
                    right: 4, top: 4), // Changed spacing to margin
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius:
                      BorderRadius.circular(8), // Reduced border radius
                ),
                child: Text(
                  type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8, // Reduced font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            pokemon.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: pokemon.isFavorite ? Colors.red : Colors.black54,
            size: 24,
          ),
          onPressed: onFavoriteToggle,
        ),
        onTap: () => onTap(pokemon),
      ),
    );
  }
}
