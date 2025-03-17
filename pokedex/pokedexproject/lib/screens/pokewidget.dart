import 'package:flutter/material.dart';
import 'package:pokedexproject/class/pokemon.dart';
import 'package:pokedexproject/data/characterr_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokedexproject/widgets/pokemon_card.dart';

class PokeWidget extends StatefulWidget {
  PokeWidget({Key? key}) : super(key: key);

  @override
  _PokeWidgetState createState() => _PokeWidgetState();
}

class _PokeWidgetState extends State<PokeWidget> {
  List<Pokemon> pokeList = [];
  List<Pokemon> filteredPokeList = [];
  CharacterApi characterApi = CharacterApi();
  int offset = 0;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String selectedType = '';
  bool showFavoritesOnly = false;

  final List<String> pokemonTypes = [
    'Normal',
    'Fire',
    'Water',
    'Electric',
    'Grass',
    'Ice',
    'Fighting',
    'Poison',
    'Ground',
    'Flying',
    'Psychic',
    'Bug',
    'Rock',
    'Ghost',
    'Dragon',
    'Dark',
    'Steel',
    'Fairy'
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    getCharactersfromApi();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (selectedType.isEmpty) {
          getCharactersfromApi();
        } else {
          getCharactersByType(selectedType);
        }
      }
    });
  }

  void getCharactersfromApi() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final List<Pokemon> response = await characterApi.getPokemon(offset);
      setState(() {
        pokeList.addAll(response);
        _loadFavorites();
        filteredPokeList = List.from(pokeList);
        offset += 20;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load Pokémon');
    }
  }

  void getCharactersByType(String type) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final List<Pokemon> response = await characterApi.getPokemonByType(type);
      setState(() {
        pokeList.addAll(response);
        _loadFavorites();
        filteredPokeList = List.from(pokeList);
        offset += 20;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load Pokémon by type');
    }
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritePokemons = prefs.getStringList('favoritePokemons') ?? [];
    setState(() {
      pokeList.forEach((pokemon) {
        if (favoritePokemons.contains(pokemon.name)) {
          pokemon.isFavorite = true;
        }
      });
      filteredPokeList = List.from(pokeList);
    });
  }

  void _toggleFavorite(Pokemon pokemon) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pokemon.isFavorite = !pokemon.isFavorite;
    });
    final favoritePokemons =
        pokeList.where((p) => p.isFavorite).map((p) => p.name).toList();
    await prefs.setStringList('favoritePokemons', favoritePokemons);
  }

  void _filterPokemonList(String searchQuery) {
    setState(() {
      filteredPokeList = pokeList
          .where((pokemon) =>
              pokemon.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  void _filterByType(String type) async {
    setState(() {
      isLoading = true;
      selectedType = type;
      offset = 0;
      pokeList.clear();
    });

    getCharactersByType(type);
  }

  void _filterFavorites() {
    setState(() {
      showFavoritesOnly = !showFavoritesOnly;
      if (showFavoritesOnly) {
        filteredPokeList =
            pokeList.where((pokemon) => pokemon.isFavorite).toList();
      } else {
        filteredPokeList = List.from(pokeList);
      }
    });
  }

  Future<void> _refresh() async {
    setState(() {
      offset = 0;
      pokeList.clear();
      selectedType = '';
    });
    getCharactersfromApi();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showPokemonDetails(Pokemon pokemon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.lightBlue[50],
          title: Text(
            pokemon.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          content: Container(
            color: Colors.lightBlue[50],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(pokemon.url),
                SizedBox(height: 10),
                Text(
                  'Type(s): ${pokemon.types.join(', ')}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Weight: ${pokemon.weight}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Height: ${pokemon.height}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Base Stats:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text('HP: ${pokemon.baseStats['hp']}'),
                Text('Attack: ${pokemon.baseStats['attack']}'),
                Text('Defense: ${pokemon.baseStats['defense']}'),
                Text('Special Attack: ${pokemon.baseStats['special-attack']}'),
                Text(
                    'Special Defense: ${pokemon.baseStats['special-defense']}'),
                Text('Speed: ${pokemon.baseStats['speed']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokedex'),
        actions: [
          IconButton(
            icon: Icon(
                showFavoritesOnly ? Icons.favorite : Icons.favorite_border),
            onPressed: _filterFavorites,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          color: Colors.white,
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: 'Search Pokémon',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          onChanged: (value) {
                            _filterPokemonList(value);
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          _filterPokemonList(_searchController.text);
                        },
                      ),
                    ],
                  ),
                ),
                // Choice Chips (for types)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: pokemonTypes.map((type) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 10.0),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: selectedType == type,
                          onSelected: (selected) {
                            if (selected) {
                              _filterByType(type);
                            } else {
                              setState(() {
                                selectedType = '';
                                filteredPokeList = List.from(pokeList);
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Pokémon List
                Expanded(
                  child: filteredPokeList.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          controller: _scrollController,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.75,
                          ),
                          itemCount:
                              filteredPokeList.length + (isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == filteredPokeList.length) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final pokemon = filteredPokeList[index];
                            return PokemonCard(
                              pokemon: pokemon,
                              onFavoriteToggle: _toggleFavorite,
                              onTap: _showPokemonDetails,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
