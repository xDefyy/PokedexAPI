import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pokedexproject/class/pokemon.dart';
import 'package:pokedexproject/data/characterr_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokedexproject/widgets/pokemon_card.dart';
import 'package:pokedexproject/widgets/pokemon_stats_chart.dart';

class PokeWidget extends StatefulWidget {
  final Function() onThemeToggle;
  final bool isDarkMode;

  const PokeWidget({
    Key? key,
    required this.onThemeToggle,
    required this.isDarkMode,
  }) : super(key: key);

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
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (!isLoading) {
        if (selectedType.isEmpty) {
          getCharactersfromApi();
        } else {
          getCharactersByType(selectedType);
        }
      }
    }
  }

  void getCharactersfromApi() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final List<Pokemon> response = await characterApi.getPokemon(offset);
      if (mounted) {
        setState(() {
          pokeList.addAll(response);
          _loadFavorites();
          filteredPokeList = List.from(pokeList);
          offset += 20;
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
      filteredPokeList.clear();
    });

    try {
      final List<Pokemon> response =
          await characterApi.getPokemonByType(type.toLowerCase());
      if (mounted) {
        setState(() {
          pokeList = response;
          _loadFavorites();
          filteredPokeList = List.from(pokeList);
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading Pokémon of type $type')),
        );
      }
    }
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
        final Color typeColor =
            typeColors[pokemon.types.first.toLowerCase()] ?? Colors.grey;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: typeColor,
                width: 2,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: typeColors[pokemon.types.first.toLowerCase()]
                          ?.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          pokemon.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Image.network(
                          pokemon.url,
                          height: 150,
                          width: 150,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: pokemon.types
                              .map((type) => Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4),
                                    child: Chip(
                                      label: Text(
                                        type,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor:
                                          typeColors[type.toLowerCase()] ??
                                              Colors.grey,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InfoCard(
                              title: 'Height',
                              value: pokemon.height,
                              icon: Icons.height,
                            ),
                            InfoCard(
                              title: 'Weight',
                              value: pokemon.weight,
                              icon: Icons.fitness_center,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Base Stats',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        PokemonStatsChart(
                          stats: pokemon.baseStats,
                          color: typeColor,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    child: Text('Close'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network(
          'https://raw.githubusercontent.com/PokeAPI/media/master/logo/pokeapi_256.png',
          height: 50,
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: widget.onThemeToggle,
          ),
          IconButton(
            icon: Icon(
              showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: _filterFavorites,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
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
                      // IconButton(
                      //   icon: Icon(Icons.search),
                      //   onPressed: () {
                      //     _filterPokemonList(_searchController.text);
                      //   },
                      // ),
                    ],
                  ),
                ),
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
                          selectedColor: typeColors[type.toLowerCase()]
                              ?.withOpacity(0.3), // Add color based on type
                          onSelected: (selected) {
                            if (selected) {
                              _filterByType(type);
                            } else {
                              setState(() {
                                selectedType = '';
                                _refresh(); // Reset and reload all Pokémon
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
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

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
