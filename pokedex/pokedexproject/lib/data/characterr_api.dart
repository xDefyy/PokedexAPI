import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedexproject/class/pokemon.dart';

class CharacterApi {
  // Fetch Pokémon with offset, limit 20 per request (you can change limit as needed)
  Future<List<Pokemon>> getPokemon(int offset) async {
    final url =
        Uri.parse('https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=20');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<String> pokemonUrls = [];

      // Collect URLs of Pokémon to fetch concurrently
      for (var pokemonData in data['results']) {
        pokemonUrls.add(pokemonData['url']);
      }

      // Fetch all Pokémon details concurrently
      List<Pokemon> pokemons = await _fetchPokemonsConcurrently(pokemonUrls);

      return pokemons;
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }

  // Method to fetch Pokémon details by type (e.g., Fire, Water, etc.)
  Future<List<Pokemon>> getPokemonByType(String type) async {
    final url = Uri.parse('https://pokeapi.co/api/v2/type/$type');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<String> pokemonUrls = [];

      // Collect URLs of Pokémon by type
      for (var pokemonData in data['pokemon']) {
        pokemonUrls.add(pokemonData['pokemon']['url']);
      }

      // Fetch all Pokémon details concurrently
      List<Pokemon> pokemons = await _fetchPokemonsConcurrently(pokemonUrls);

      return pokemons;
    } else {
      throw Exception('Failed to load Pokémon by type');
    }
  }

  Future<List<Pokemon>> _fetchPokemonsConcurrently(
      List<String> pokemonUrls) async {
    List<Future<Pokemon?>> futures = pokemonUrls.map((url) {
      return _fetchPokemonDetail(url);
    }).toList();

    // Wait for all futures to complete and filter out null results
    List<Pokemon> pokemons = (await Future.wait(futures))
        .where((pokemon) => pokemon != null) // Filter out null values
        .cast<Pokemon>() // Cast to List<Pokemon>
        .toList();

    return pokemons;
  }

  // Helper function to fetch detailed info of a single Pokémon
  Future<Pokemon?> _fetchPokemonDetail(String pokemonUrl) async {
    final response = await http.get(Uri.parse(pokemonUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return Pokemon(
        name: data['name'],
        url: data['sprites']['front_default'], // Pokémon image URL
        types: List<String>.from(
            data['types'].map((type) => type['type']['name'])),
        height: data['height'].toString(),
        weight: data['weight'].toString(),
        baseStats: {
          'hp': data['stats'][0]['base_stat'],
          'attack': data['stats'][1]['base_stat'],
          'defense': data['stats'][2]['base_stat'],
          'special-attack': data['stats'][3]['base_stat'],
          'special-defense': data['stats'][4]['base_stat'],
          'speed': data['stats'][5]['base_stat'],
        },
      );
    } else {
      print('Failed to load Pokémon details');
      return null;
    }
  }
}
