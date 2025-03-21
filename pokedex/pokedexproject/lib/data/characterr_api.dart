import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pokedexproject/class/pokemon.dart';
import 'package:pokedexproject/services/network_manager.dart';

class CharacterApi {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const int _batchSize =
      50; // Increased batch size for better performance

  final Map<String, Pokemon> _cachepokemons = {};
  List<Pokemon>? _allPokemons;
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<List<Pokemon>> getAllPokemons() async {
    if (_allPokemons != null) {
      return _allPokemons!;
    }

    //ver si hay conexion a lawifi
    if (await _connectivityService.isConnectedToWifi() == false) {
      return _allPokemons!;
    }

    try {
      final data = await _fetchFromApi('$_baseUrl/pokemon?limit=10000');

      final urls = data['results']
          .map<String>((pokemon) => pokemon['url'] as String)
          .toList();

      _allPokemons = await _processPokemonBatch(urls);
      return _allPokemons!;
    } catch (e) {
      debugPrint('Error fetching Pokemon list: $e');
      throw Exception('Failed to load Pokémon');
    }
  }

  // BATCHES DE POKEMONS PARA PODER CARGAR LOS DATOS DE CADA UNO
  Future<List<Pokemon>> _processPokemonBatch(List<String> urls) async {
    final List<Pokemon> pokemons = [];

    for (var i = 0; i < urls.length; i += _batchSize) {
      final end = (i + _batchSize < urls.length) ? i + _batchSize : urls.length;
      final batch = urls.sublist(i, end);

      final futures = batch.map((url) => _getPokemonDetails(url));
      final results = await Future.wait(futures, eagerError: false);

      pokemons.addAll(results.whereType<Pokemon>());
    }

    return pokemons;
  }

  Future<List<Pokemon>> getAllPokemonByType(String type) async {
    try {
      // Ensure all Pokémon are fetched and cached
      final allPokemons = await getAllPokemons();

      // Filter Pokémon by type locally
      return allPokemons
          .where((pokemon) => pokemon.types
              .map((t) => t.toLowerCase())
              .contains(type.toLowerCase()))
          .toList();
    } catch (e) {
      debugPrint('Error in getAllPokemonByType: $e');
      throw Exception('Failed to load all Pokémon by type');
    }
  }

  Future<Pokemon?> _getPokemonDetails(String url) async {
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

      _cachepokemons[url] = pokemon;
      return pokemon;
    } catch (e) {
      debugPrint('Error fetching Pokemon details: $e');
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
