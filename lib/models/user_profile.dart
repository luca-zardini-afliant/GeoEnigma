// User profile and statistics models for Global Enigma game

class UserProfile {
  final String name;
  final int totalGamesPlayed;
  final int totalScore;
  final int bestScore;
  final int averageScore;
  final List<Achievement> achievements;
  final Map<String, DifficultyStats> difficultyStats;
  final DateTime lastPlayed;

  const UserProfile({
    required this.name,
    required this.totalGamesPlayed,
    required this.totalScore,
    required this.bestScore,
    required this.averageScore,
    required this.achievements,
    required this.difficultyStats,
    required this.lastPlayed,
  });

  factory UserProfile.empty() {
    return UserProfile(
      name: 'Player',
      totalGamesPlayed: 0,
      totalScore: 0,
      bestScore: 0,
      averageScore: 0,
      achievements: [],
      difficultyStats: {
        'easy': DifficultyStats.empty('easy'),
        'medium': DifficultyStats.empty('medium'),
        'hard': DifficultyStats.empty('hard'),
      },
      lastPlayed: DateTime.now(),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      totalGamesPlayed: json['totalGamesPlayed'] as int,
      totalScore: json['totalScore'] as int,
      bestScore: json['bestScore'] as int,
      averageScore: json['averageScore'] as int,
      achievements: (json['achievements'] as List)
          .map((achievementJson) => Achievement.fromJson(achievementJson as Map<String, dynamic>))
          .toList(),
      difficultyStats: (json['difficultyStats'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, DifficultyStats.fromJson(value as Map<String, dynamic>))),
      lastPlayed: DateTime.parse(json['lastPlayed'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'bestScore': bestScore,
      'averageScore': averageScore,
      'achievements': achievements.map((achievement) => achievement.toJson()).toList(),
      'difficultyStats': difficultyStats.map((key, value) => MapEntry(key, value.toJson())),
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? name,
    int? totalGamesPlayed,
    int? totalScore,
    int? bestScore,
    int? averageScore,
    List<Achievement>? achievements,
    Map<String, DifficultyStats>? difficultyStats,
    DateTime? lastPlayed,
  }) {
    return UserProfile(
      name: name ?? this.name,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalScore: totalScore ?? this.totalScore,
      bestScore: bestScore ?? this.bestScore,
      averageScore: averageScore ?? this.averageScore,
      achievements: achievements ?? this.achievements,
      difficultyStats: difficultyStats ?? this.difficultyStats,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }
}

class DifficultyStats {
  final String difficulty;
  final int gamesPlayed;
  final int bestScore;
  final int totalScore;
  final int averageScore;
  final int perfectGuesses; // Distance < 25km
  final int totalDistance;

  const DifficultyStats({
    required this.difficulty,
    required this.gamesPlayed,
    required this.bestScore,
    required this.totalScore,
    required this.averageScore,
    required this.perfectGuesses,
    required this.totalDistance,
  });

  factory DifficultyStats.empty(String difficulty) {
    return DifficultyStats(
      difficulty: difficulty,
      gamesPlayed: 0,
      bestScore: 0,
      totalScore: 0,
      averageScore: 0,
      perfectGuesses: 0,
      totalDistance: 0,
    );
  }

  factory DifficultyStats.fromJson(Map<String, dynamic> json) {
    return DifficultyStats(
      difficulty: json['difficulty'] as String,
      gamesPlayed: json['gamesPlayed'] as int,
      bestScore: json['bestScore'] as int,
      totalScore: json['totalScore'] as int,
      averageScore: json['averageScore'] as int,
      perfectGuesses: json['perfectGuesses'] as int,
      totalDistance: json['totalDistance'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'gamesPlayed': gamesPlayed,
      'bestScore': bestScore,
      'totalScore': totalScore,
      'averageScore': averageScore,
      'perfectGuesses': perfectGuesses,
      'totalDistance': totalDistance,
    };
  }

  DifficultyStats copyWith({
    int? gamesPlayed,
    int? bestScore,
    int? totalScore,
    int? averageScore,
    int? perfectGuesses,
    int? totalDistance,
  }) {
    return DifficultyStats(
      difficulty: difficulty,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      bestScore: bestScore ?? this.bestScore,
      totalScore: totalScore ?? this.totalScore,
      averageScore: averageScore ?? this.averageScore,
      perfectGuesses: perfectGuesses ?? this.perfectGuesses,
      totalDistance: totalDistance ?? this.totalDistance,
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      unlocked: json['unlocked'] as bool,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'unlocked': unlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  Achievement copyWith({
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

// Predefined achievements
class Achievements {
  static const List<Achievement> all = [
    Achievement(
      id: 'first_game',
      title: 'First Steps',
      description: 'Complete your first game',
      icon: '🎮',
      unlocked: false,
    ),
    Achievement(
      id: 'perfect_guess',
      title: 'Bullseye',
      description: 'Make a perfect guess (within 25km)',
      icon: '🎯',
      unlocked: false,
    ),
    Achievement(
      id: 'high_score',
      title: 'High Scorer',
      description: 'Achieve a score of 8000 or higher',
      icon: '⭐',
      unlocked: false,
    ),
    Achievement(
      id: 'explorer_easy',
      title: 'Nation Explorer',
      description: 'Complete 10 easy games',
      icon: '🌍',
      unlocked: false,
    ),
    Achievement(
      id: 'explorer_medium',
      title: 'City Explorer',
      description: 'Complete 10 medium games',
      icon: '🏙️',
      unlocked: false,
    ),
    Achievement(
      id: 'explorer_hard',
      title: 'Monument Explorer',
      description: 'Complete 10 hard games',
      icon: '🏛️',
      unlocked: false,
    ),
    Achievement(
      id: 'dedicated',
      title: 'Dedicated Player',
      description: 'Play 50 games total',
      icon: '🏆',
      unlocked: false,
    ),
    Achievement(
      id: 'master',
      title: 'Geography Master',
      description: 'Achieve 5 perfect guesses',
      icon: '👑',
      unlocked: false,
    ),
  ];
}
