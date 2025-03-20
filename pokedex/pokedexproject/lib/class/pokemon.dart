class Pokemon {
  final String name;
  final String url;
  final List<String> types;
  final String height;
  final String weight;
  final Map<String, int> baseStats;
  bool isFavorite;

  Pokemon({
    required this.name,
    required this.url,
    required this.types,
    required this.height,
    required this.weight,
    required this.baseStats,
    this.isFavorite = false,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    var typesList = <String>[];
    for (var type in json['types']) {
      typesList.add(type['type']['name']);
    }

    Map<String, int> baseStatsMap = {};
    for (var stat in json['stats']) {
      baseStatsMap[stat['stat']['name']] = stat['base_stat'];
    }

    return Pokemon(
      name: json['name'],
      url: json['sprites']['front_default'],
      types: typesList,
      height: json['height'].toString(),
      weight: json['weight'].toString(),
      baseStats: baseStatsMap,
    );
  }
}
