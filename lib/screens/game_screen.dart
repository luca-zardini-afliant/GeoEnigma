import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/puzzle_model.dart';
import '../services/puzzle_service.dart';
import '../services/user_storage_service.dart';
import '../widgets/clue_dossier.dart';
import '../widgets/score_display.dart';
import 'start_screen.dart';
import 'profile_screen.dart';

class GameScreen extends StatefulWidget {
  final Difficulty initialDifficulty;
  
  const GameScreen({
    super.key,
    required this.initialDifficulty,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Puzzle> _puzzles = [];
  Puzzle? _currentPuzzle;
  int _score = 10000;
  List<String> _revealedClueIds = [];
  LatLng? _guessLocation;
  bool _gameEnded = false;
  bool _isLoading = true;
  Difficulty _currentDifficulty = Difficulty.easy;

  @override
  void initState() {
    super.initState();
    _currentDifficulty = widget.initialDifficulty;
    _loadPuzzles();
  }

  Future<void> _loadPuzzles() async {
    try {
      final puzzles = await PuzzleService.loadPuzzles();
      setState(() {
        _puzzles = puzzles;
        _currentPuzzle = PuzzleService.getRandomPuzzle(puzzles, _currentDifficulty.name);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading puzzles: $e')),
        );
      }
    }
  }

  void _revealClue(int clueIndex) {
    final clue = _currentPuzzle!.clues[clueIndex];
    setState(() {
      _revealedClueIds.add(clueIndex.toString());
      _score += clue.cost; // cost is negative, so this subtracts from score
    });
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (!_gameEnded) {
      setState(() {
        _guessLocation = point;
      });
    }
  }

  void _confirmGuess() async {
    if (_guessLocation == null || _currentPuzzle == null) return;

    final distance = _calculateDistance(
      _guessLocation!,
      LatLng(_currentPuzzle!.solution.lat, _currentPuzzle!.solution.lon),
    );

    final penalty = (distance * 2).round();
    final bullseyeBonus = distance < 25 ? 500 : 0;
    final finalScore = _score - penalty + bullseyeBonus;

    setState(() {
      _gameEnded = true;
    });

    // Save game result to user profile
    try {
      print('DEBUG: Recording game result - Score: $finalScore, Distance: $distance, Clues: ${_revealedClueIds.length}');
      final updatedProfile = await UserStorageService.recordGameResult(
        difficulty: _currentDifficulty.name,
        score: finalScore,
        distance: distance,
        cluesUsed: _revealedClueIds.length,
      );
      print('DEBUG: Game result recorded - Total games: ${updatedProfile.totalGamesPlayed}, Best score: ${updatedProfile.bestScore}');
    } catch (e) {
      // Log error but don't interrupt the game
      print('Error saving game result: $e');
    }

    _showEndGameDialog(distance, finalScore, penalty, bullseyeBonus);
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }

  void _showEndGameDialog(double distance, int finalScore, int penalty, int bullseyeBonus) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Correct Location: ${_currentPuzzle!.solution.name}'),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _buildEndGameMap(distance),
              ),
              const SizedBox(height: 16),
              Text('Distance: ${distance.toStringAsFixed(1)} km'),
              const SizedBox(height: 8),
              Text('Final Score: $finalScore'),
              const SizedBox(height: 8),
              Text('Score Breakdown:'),
              Text('  Base Score: $_score'),
              Text('  Distance Penalty: -$penalty'),
              if (bullseyeBonus > 0) Text('  Bullseye Bonus: +$bullseyeBonus'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to difficulty selection
            },
            child: const Text('Back to Menu'),
          ),
          TextButton(
            onPressed: _playAgain,
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEndGameMap(double distance) {
    if (_currentPuzzle == null || _guessLocation == null) {
      return const Center(child: Text('Map unavailable'));
    }

    final correctLocation = LatLng(_currentPuzzle!.solution.lat, _currentPuzzle!.solution.lon);
    final centerLat = (_guessLocation!.latitude + correctLocation.latitude) / 2;
    final centerLng = (_guessLocation!.longitude + correctLocation.longitude) / 2;

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(centerLat, centerLng),
        initialZoom: 4.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.global_enigma',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _guessLocation!,
              child: const Icon(Icons.location_on, color: Colors.red, size: 30),
            ),
            Marker(
              point: correctLocation,
              child: const Icon(Icons.flag, color: Colors.green, size: 30),
            ),
          ],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [_guessLocation!, correctLocation],
              color: Colors.blue,
              strokeWidth: 2.0,
            ),
          ],
        ),
      ],
    );
  }

  void _playAgain() {
    Navigator.of(context).pop(); // Close dialog
    setState(() {
      _currentPuzzle = PuzzleService.getRandomPuzzle(_puzzles, _currentDifficulty.name);
      _score = 10000;
      _revealedClueIds.clear();
      _guessLocation = null;
      _gameEnded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentPuzzle == null) {
      return const Scaffold(
        body: Center(
          child: Text('No puzzle available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Enigma'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getDifficultyColor(_currentDifficulty),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _currentDifficulty.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ScoreDisplay(score: _score),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ClueDossier(
                    clues: _currentPuzzle!.clues,
                    revealedClueIds: _revealedClueIds,
                    onRevealClue: _revealClue,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildMapView(),
                ),
              ],
            ),
          ),
          if (_guessLocation != null && !_gameEnded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _confirmGuess,
                child: const Text('Confirm Guess'),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
        child: const Icon(Icons.person),
        tooltip: 'View Profile',
      ),
    );
  }

  Widget _buildMapView() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(20.0, 0.0),
          initialZoom: 2.0,
          onTap: _onMapTap,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.example.global_enigma',
          ),
          if (_guessLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _guessLocation!,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }
}
