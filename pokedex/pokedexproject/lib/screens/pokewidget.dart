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

  // Add cache map
  final Map<int, List<Pokemon>> _pageCache = {};
  static const int pageSize = 20;

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

  bool isGridView = true; // true for grid, false for list

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
      // Check cache first
      if (_pageCache.containsKey(offset ~/ pageSize)) {
        final cachedList = _pageCache[offset ~/ pageSize]!;
        setState(() {
          pokeList.addAll(cachedList);
          _loadFavorites();
          filteredPokeList = List.from(pokeList);
          offset += pageSize;
          isLoading = false;
        });
        return;
      }

      final List<Pokemon> response = await characterApi.getPokemon(offset);
      if (mounted) {
        // Cache the new page
        _pageCache[offset ~/ pageSize] = response;

        setState(() {
          pokeList.addAll(response);
          _loadFavorites();
          filteredPokeList = List.from(pokeList);
          offset += pageSize;
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
          IconButton(
            icon: Icon(
              isGridView ? Icons.list : Icons.grid_view,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
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
                        selectedColor:
                            typeColors[type.toLowerCase()]?.withOpacity(0.3),
                        onSelected: (selected) {
                          if (selected) {
                            _filterByType(type);
                          } else {
                            setState(() {
                              selectedType = '';
                              _refresh();
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
                    : isGridView
                        ? GridView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // Changed from 2 to 3
                              childAspectRatio:
                                  0.75, // Adjusted for better card proportions
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount:
                                filteredPokeList.length + (isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= filteredPokeList.length) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return PokemonCard(
                                pokemon: filteredPokeList[index],
                                onTap: (pokemon) =>
                                    _showPokemonDetails(pokemon),
                                onFavoriteToggle: () =>
                                    _toggleFavorite(filteredPokeList[index]),
                              );
                            },
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            itemCount:
                                filteredPokeList.length + (isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= filteredPokeList.length) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              final String primaryType = filteredPokeList[index]
                                  .types
                                  .first
                                  .toLowerCase();
                              final Color cardColor =
                                  typeColors[primaryType] ?? Colors.grey;

                              return Card(
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                color: cardColor.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(color: cardColor, width: 2),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.network(
                                      filteredPokeList[index].url,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.error),
                                    ),
                                  ),
                                  title: Text(
                                    filteredPokeList[index].name,
                                    style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Wrap(
                                    spacing: 4,
                                    children: filteredPokeList[index]
                                        .types
                                        .map((type) {
                                      final Color typeColor =
                                          typeColors[type.toLowerCase()] ??
                                              Colors.grey;
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        margin: EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          color: typeColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                    }).toList(),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      filteredPokeList[index].isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: filteredPokeList[index].isFavorite
                                          ? Colors.red
                                          : Colors.black54,
                                      size: 24,
                                    ),
                                    onPressed: () => _toggleFavorite(
                                        filteredPokeList[index]),
                                  ),
                                  onTap: () => _showPokemonDetails(
                                      filteredPokeList[index]),
                                ),
                              );
                            },
                          ),
              ),
            ],
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
