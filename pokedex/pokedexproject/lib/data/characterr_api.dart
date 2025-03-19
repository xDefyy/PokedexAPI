import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pokedexproject/class/pokemon.dart';

class CharacterApi {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const int _batchSize = 20;

  // Cache for Pokemon details to avoid duplicate requests
  final Map<String, Pokemon> _cachepokemons = {};

  Future<List<Pokemon>> getPokemon(int offset) async {
    try {
      final data = await _fetchFromApi(
          '$_baseUrl/pokemon?offset=$offset&limit=$_batchSize');

      final urls =
          List<String>.from(data['results'].map((pokemon) => pokemon['url']));

      return _processPokemonBatch(urls);
    } catch (e) {
      print('Error fetching Pokemon list: $e');
      throw Exception('Failed to load Pokémon');
    }
  }

  Future<List<Pokemon>> getPokemonByType(String type) async {
    try {
      final data = await _fetchFromApi('$_baseUrl/type/${type.toLowerCase()}');

      final urls = data['pokemon']
          .where((p) => p['pokemon']?['url'] != null)
          .map<String>((p) => p['pokemon']['url'])
          .cast<String>()
          .toList();

      return _processPokemonBatch(urls);
    } catch (e) {
      print('Error in getPokemonByType: $e');
      throw Exception('Failed to load Pokémon by type');
    }
  }

  Future<List<Pokemon>> _processPokemonBatch(List<String> urls) async {
    final List<Pokemon> pokemons = [];

    // Process in smaller batches to avoid overwhelming the API
    for (var i = 0; i < urls.length; i += _batchSize) {
      final end = (i + _batchSize < urls.length) ? i + _batchSize : urls.length;
      final batch = urls.sublist(i, end);

      final futures = batch.map((url) => _getPokemonDetails(url));
      final results = await Future.wait(futures, eagerError: false);

      pokemons.addAll(results.whereType<Pokemon>());
    }

    return pokemons;
  }

  Future<Pokemon?> _getPokemonDetails(String url) async {
    // Check cache first
    if (_cachepokemons.containsKey(url)) {
      return _cachepokemons[url];
    }

    try {
      final data = await _fetchFromApi(url);
      final pokemon = Pokemon(
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

      // Cache the result
      _cachepokemons[url] = pokemon;
      return pokemon;
    } catch (e) {
      print('Error fetching Pokemon details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchFromApi(String url) async {
    try {
      return await compute(_fetchDataInBackground, PokemonApiRequest(url));
    } catch (e) {
      print('API Error: $e');
      throw Exception('Failed to fetch data from API');
    }
  }
}

class PokemonApiRequest {
  final String url;
  final Map<String, String>? headers;

  const PokemonApiRequest(this.url, {this.headers});
}

Future<Map<String, dynamic>> _fetchDataInBackground(
    PokemonApiRequest request) async {
  final response =
      await http.get(Uri.parse(request.url), headers: request.headers);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  throw Exception('API Error: ${response.statusCode}');
}
