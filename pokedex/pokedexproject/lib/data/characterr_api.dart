import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pokedexproject/class/pokemon.dart';

class CharacterApi {
  Future<List<Pokemon>> getPokemon(int offset) async {
    final url =
        Uri.parse('https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=20');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<String> pokemonUrls = [];
      for (var pokemonData in data['results']) {
        pokemonUrls.add(pokemonData['url']);
      }
      List<Pokemon> pokemons = await _fetchPokemonsConcurrently(pokemonUrls);
      return pokemons;
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }

  Future<List<Pokemon>> getPokemonByType(String type) async {
    try {
      final url =
          Uri.parse('https://pokeapi.co/api/v2/type/${type.toLowerCase()}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = await compute(jsonDecode, response.body);
        List<String> pokemonUrls = [];
        List<Pokemon> pokemons = [];

        for (var pokemonData in data['pokemon']) {
          if (pokemonData['pokemon'] != null &&
              pokemonData['pokemon']['url'] != null) {
            pokemonUrls.add(pokemonData['pokemon']['url']);
          }
        }

        const int batchSize = 20;
        for (var i = 0; i < pokemonUrls.length; i += batchSize) {
          var end = (i + batchSize < pokemonUrls.length)
              ? i + batchSize
              : pokemonUrls.length;
          var batch = pokemonUrls.sublist(i, end);

          var batchPokemons = await _fetchPokemonsConcurrently(batch);
          pokemons.addAll(batchPokemons);
        }

        return pokemons;
      } else {
        throw Exception(
            'Failed to load Pokémon by type: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getPokemonByType: $e');
      throw Exception('Failed to load Pokémon by type: $e');
    }
  }

  Future<List<Pokemon>> _fetchPokemonsConcurrently(
      List<String> pokemonUrls) async {
    try {
      List<Future<Pokemon?>> futures = pokemonUrls.map((url) {
        return _fetchPokemonDetail(url);
      }).toList();

      List<Pokemon?> results = await Future.wait(
        futures,
        eagerError: false, // Continue processing even if some requests fail
      );

      // Filter out null results and cast to Pokemon
      return results
          .where((pokemon) => pokemon != null)
          .cast<Pokemon>()
          .toList();
    } catch (e) {
      print('Error in _fetchPokemonsConcurrently: $e');
      return [];
    }
  }

  // Helper function to fetch detailed info of a single Pokémon
  Future<Pokemon?> _fetchPokemonDetail(String pokemonUrl) async {
    try {
      final response = await http.get(Uri.parse(pokemonUrl));

      if (response.statusCode == 200) {
        final data = await compute(jsonDecode, response.body);

        return Pokemon(
          name: data['name'],
          url: data['sprites']['front_default'] ?? '',
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
        print('Failed to load Pokémon details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error in _fetchPokemonDetail: $e');
      return null;
    }
  }
}
