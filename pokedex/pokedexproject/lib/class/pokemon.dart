class Pokemon {
  final String name;
  final String url;
  final List<String> types;
  final int weight;
  final int height;
  final Map<String, int> baseStats;
  bool isFavorite;

  Pokemon({
    required this.name,
    required this.url,
    required this.types,
    required this.weight,
    required this.height,
    required this.baseStats,
    this.isFavorite = false,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      url: json['sprites']['front_default'],
      types: (json['types'] as List)
          .map((type) => type['type']['name'] as String)
          .toList(),
      weight: json['weight'],
      height: json['height'],
      baseStats: {
        'hp': json['stats'][0]['base_stat'],
        'attack': json['stats'][1]['base_stat'],
        'defense': json['stats'][2]['base_stat'],
        'special-attack': json['stats'][3]['base_stat'],
        'special-defense': json['stats'][4]['base_stat'],
        'speed': json['stats'][5]['base_stat'],
      },
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'types': types,
      'weight': weight,
      'height': height,
      'baseStats': baseStats,
      'isFavorite': isFavorite,
    };
  }
}
