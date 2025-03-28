import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pokedexproject/class/pokemon.dart';
import 'package:pokedexproject/data/characterr_api.dart';
import 'package:pokedexproject/widgets/info_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokedexproject/widgets/pokemon_card.dart';
import 'package:pokedexproject/widgets/pokemon_stats_chart.dart';
import 'package:pokedexproject/widgets/pokemon_list_item.dart';
import 'package:pokedexproject/widgets/pokeball_loading.dart';
import 'package:pokedexproject/services/notification_services.dart';
import 'package:pokedexproject/screens/pokemon_compare_screen.dart';

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
  bool isAlphabeticalSort = false;

  final Map<int, List<Pokemon>> _pageCache = {};
  static const int pageSize = 20;
  bool hasMorePokemons = true;

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

  bool isGridView = true;

  @override
  void initState() {
    super.initState();
    // _loadFavorites();
    getCharactersfromApi();
  }

  void getCharactersfromApi() async {
    if (isLoading || !hasMorePokemons) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (_pageCache.containsKey(offset ~/ pageSize)) {
        final cachedList = _pageCache[offset ~/ pageSize]!;
        setState(() {
          if (cachedList.isEmpty) {
            hasMorePokemons = false;
          } else {
            pokeList.addAll(cachedList);
            _loadFavorites();
            filteredPokeList = List.from(pokeList);
            offset += pageSize;
          }
          isLoading = false;
        });
        return;
      }

      final List<Pokemon> response = await characterApi.getAllPokemons();
      if (mounted) {
        setState(() {
          if (response.isEmpty) {
            hasMorePokemons = false;
          } else {
            _pageCache[offset ~/ pageSize] = response;
            pokeList.addAll(response);
            _loadFavorites();
            filteredPokeList = List.from(pokeList);
            offset += pageSize;
          }
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasMorePokemons = false;
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
      final List<Pokemon> response =
          await characterApi.getAllPokemonByType(type);
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
    if (favoritePokemons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No favorite Pokémon found')),
      );
    }
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
    final notis = NotiService();
    setState(() {
      pokemon.isFavorite = !pokemon.isFavorite;
      if (showFavoritesOnly) {
        filteredPokeList = pokeList.where((p) => p.isFavorite).toList();
      }
    });
    final favoritePokemons =
        pokeList.where((p) => p.isFavorite).map((p) => p.name).toList();
    await prefs.setStringList('favoritePokemons', favoritePokemons);
    notis.showNotification(
        title: 'Pokemon Favorito',
        body: pokemon.isFavorite
            ? 'Has marcado a ${pokemon.name} como favorito'
            : 'Has desmarcado a ${pokemon.name} como favorito');
  }

  void _filterPokemonList(String searchQuery) {
    setState(() {
      showFavoritesOnly = false; // Desactivar el filtro de favoritos
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
          await characterApi.getAllPokemonByType(type.toLowerCase());
      if (mounted) {
        setState(() {
          pokeList = response;
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

  void _toggleSort() {
    setState(() {
      isAlphabeticalSort = !isAlphabeticalSort;
      if (isAlphabeticalSort) {
        filteredPokeList.sort((a, b) => a.name.compareTo(b.name));
      } else {
        // Reset to original API order
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
                      color: typeColor.withAlpha(51),
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
                        Hero(
                          tag: 'pokemon-${pokemon.name}',
                          child: Image.network(
                            pokemon.url,
                            fit: BoxFit.contain,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const PokeballLoading();
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                size: 80,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
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

  void _showRandomPokemonDetails() {
    if (pokeList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Pokémon available to show.')),
      );
      return;
    }

    final randomIndex = (pokeList..shuffle()).first;
    _showPokemonDetails(randomIndex);
  }

// para crear el listview
  Widget _buildListItem(int index) {
    return PokemonListItem(
      pokemon: filteredPokeList[index],
      onTap: _showPokemonDetails,
      onFavoriteToggle: () => _toggleFavorite(filteredPokeList[index]),
      isDarkMode: widget.isDarkMode,
      typeColors: typeColors,
    );
  }

  void filterByTypeFavorites(String type) {
    setState(() {
      showFavoritesOnly = true; // Activar el filtro de favoritos
      selectedType = type; // Establecer el tipo seleccionado

      // Filtrar los Pokémon que son favoritos y coinciden con el tipo
      filteredPokeList = pokeList.where((pokemon) {
        return pokemon.isFavorite &&
            pokemon.types.any((pokemonType) =>
                pokemonType.toLowerCase() == type.toLowerCase());
      }).toList();
    });
  }

  // main list de los pokemons
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
            icon: const Icon(Icons.compare_arrows),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PokemonCompareScreen(),
                ),
              );
            },
          ),
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
          IconButton(
            icon: Icon(
              isAlphabeticalSort ? Icons.sort_by_alpha : Icons.sort,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            tooltip: isAlphabeticalSort
                ? 'Sort by default order'
                : 'Sort alphabetically',
            onPressed: _toggleSort,
          ),
          IconButton(
            icon: Icon(
              Icons.shuffle,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            tooltip: 'Random Pokémon',
            onPressed: _showRandomPokemonDetails,
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
                        selectedColor: typeColors[type.toLowerCase()]
                            ?.withAlpha(77), // 0.3 opacity = 77 alpha
                        onSelected: (selected) {
                          if (selected) {
                            filterByTypeFavorites(
                                type); // Llamar a la función aquí
                          } else {
                            setState(() {
                              selectedType = '';
                              _filterFavorites(); // Volver a mostrar solo los favoritos
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
                    ? Center(
                        child: isLoading
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/loading_pokeball.gif',
                                    height: 100,
                                    width: 100,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'ポケモンをロード中...',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              )
                            : Text(
                                'ポケモンが見つかりません',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                      )
                    : isGridView
                        ? GridView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            cacheExtent:
                                1000, // Aumenta el cache para scroll más suave
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.75,
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
                              return RepaintBoundary(
                                child: PokemonCard(
                                  key: ValueKey(filteredPokeList[index].name),
                                  pokemon: filteredPokeList[index],
                                  onTap: (pokemon) =>
                                      _showPokemonDetails(pokemon),
                                  onFavoriteToggle: () =>
                                      _toggleFavorite(filteredPokeList[index]),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            cacheExtent: 1000,
                            itemCount:
                                filteredPokeList.length + (isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= filteredPokeList.length) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return RepaintBoundary(
                                child: _buildListItem(index),
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
