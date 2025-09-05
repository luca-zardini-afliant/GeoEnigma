import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/puzzle_model.dart';

class PuzzleService {
  static Future<List<Puzzle>> loadPuzzles() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/puzzles.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList
          .map((json) => Puzzle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load puzzles: $e');
    }
  }

  static Puzzle getRandomPuzzle(List<Puzzle> puzzles, String difficulty) {
    final filteredPuzzles = puzzles.where((puzzle) => puzzle.level == difficulty).toList();
    if (filteredPuzzles.isEmpty) {
      throw Exception('No puzzles found for difficulty: $difficulty');
    }
    final random = DateTime.now().millisecondsSinceEpoch % filteredPuzzles.length;
    return filteredPuzzles[random];
  }
}
