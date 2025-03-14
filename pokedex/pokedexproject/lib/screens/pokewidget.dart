import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pokedexproject/class/pokemon.dart';
import 'package:pokedexproject/data/characterr_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void getCharactersfromApi() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final List<Pokemon> response = await characterApi.getPokemon(offset);
    setState(() {
      pokeList.addAll(response);
      _loadFavorites();
      filteredPokeList = List.from(pokeList);
      offset += 20;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    getCharactersfromApi();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getCharactersfromApi();
      }
    });
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

  void _filterPokemonList() async {
    setState(() {
      isLoading = true;
      selectedType = '';
    });

    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isEmpty) {
      setState(() {
        filteredPokeList = List.from(pokeList);
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=100000');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Pokemon> searchResults = [];

      for (var pokemonData in data['results']) {
        if (pokemonData['name'].toLowerCase().contains(searchQuery)) {
          final pokemonUrl = pokemonData['url'];
          final pokemonResponse = await http.get(Uri.parse(pokemonUrl));
          if (pokemonResponse.statusCode == 200) {
            final pokemonDetail = jsonDecode(pokemonResponse.body);
            searchResults.add(Pokemon.fromJson(pokemonDetail));
          }
        }
      }

      setState(() {
        filteredPokeList = searchResults;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load Pokémon');
    }
  }

  void _filterByType(String type) {
    setState(() {
      selectedType = type;
      if (type.isEmpty) {
        filteredPokeList = List.from(pokeList);
      } else {
        filteredPokeList = pokeList
            .where((pokemon) => pokemon.types.contains(type.toLowerCase()))
            .toList();
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
          title: Text(pokemon.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(pokemon.url),
              SizedBox(height: 10),
              Text('Type(s): ${pokemon.types.join(', ')}'),
              Text('Weight: ${pokemon.weight}'),
              Text('Height: ${pokemon.height}'),
              Text('Base Stats:'),
              Text('HP: ${pokemon.baseStats['hp']}'),
              Text('Attack: ${pokemon.baseStats['attack']}'),
              Text('Defense: ${pokemon.baseStats['defense']}'),
              Text('Special Attack: ${pokemon.baseStats['special-attack']}'),
              Text('Special Defense: ${pokemon.baseStats['special-defense']}'),
              Text('Speed: ${pokemon.baseStats['speed']}'),
            ],
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          color: Colors.white,
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
                          onSubmitted: (value) => _filterPokemonList(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: _filterPokemonList,
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: pokemonTypes.map((type) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: selectedType == type,
                          onSelected: (selected) {
                            _filterByType(selected ? type : '');
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
                            return GestureDetector(
                              onTap: () => _showPokemonDetails(pokemon),
                              child: Card(
                                color: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side:
                                      BorderSide(color: Colors.black, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(15.0)),
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
                                            bottomRight: Radius.circular(15.0)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              pokemon.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              pokemon.isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: pokemon.isFavorite
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            onPressed: () =>
                                                _toggleFavorite(pokemon),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
