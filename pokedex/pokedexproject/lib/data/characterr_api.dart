import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedexproject/class/pokemon.dart';

class CharacterApi {
  Future<List<Pokemon>> getPokemon(int offset) async {
    final url =
        Uri.parse('https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=100');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Pokemon> pokemons = [];

      List<Future<void>> futures = [];

      for (var pokemonData in data['results']) {
        final pokemonUrl = pokemonData['url'];
        futures.add(http.get(Uri.parse(pokemonUrl)).then((pokemonResponse) {
          if (pokemonResponse.statusCode == 200) {
            final pokemonDetail = jsonDecode(pokemonResponse.body);
            pokemons.add(Pokemon.fromJson(pokemonDetail));
          } else {
            throw Exception('Failed to load Pokémon details');
          }
        }));
      }

      await Future.wait(futures);

      return pokemons;
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }
}
