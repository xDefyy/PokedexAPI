import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedexproject/class/pokemon.dart';

class CharacterApi {
  Future<List<Pokemon>> getPokemon(int offset) async {
    final url =
        Uri.parse('https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=20');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Pokemon> pokemons = [];

      for (var pokemonData in data['results']) {
        final pokemonUrl = pokemonData['url'];
        final pokemonResponse = await http.get(Uri.parse(pokemonUrl));

        if (pokemonResponse.statusCode == 200) {
          final pokemonDetail = jsonDecode(pokemonResponse.body);

          // Crear una instancia de Pokemon y agregarla a la lista
          pokemons.add(Pokemon.fromJson(pokemonDetail));
        } else {
          throw Exception('Failed to load Pokémon details');
        }
      }
      return pokemons;
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }
}
