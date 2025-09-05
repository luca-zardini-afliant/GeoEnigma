// Puzzle data models for Global Enigma game

class Puzzle {
  final String id;
  final String level;
  final String category;
  final List<Clue> clues;
  final Solution solution;

  const Puzzle({
    required this.id,
    required this.level,
    required this.category,
    required this.clues,
    required this.solution,
  });

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'] as String,
      level: json['level'] as String,
      category: json['category'] as String,
      clues: (json['clues'] as List)
          .map((clueJson) => Clue.fromJson(clueJson as Map<String, dynamic>))
          .toList(),
      solution: Solution.fromJson(json['solution'] as Map<String, dynamic>),
    );
  }
}

class Clue {
  final String text;
  final int cost;
  final String type;
  final Map<String, dynamic>? data;

  const Clue({
    required this.text,
    required this.cost,
    required this.type,
    this.data,
  });

  factory Clue.fromJson(Map<String, dynamic> json) {
    return Clue(
      text: json['text'] as String,
      cost: json['cost'] as int,
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class Solution {
  final String name;
  final double lat;
  final double lon;

  const Solution({
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory Solution.fromJson(Map<String, dynamic> json) {
    return Solution(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }
}
