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
  bool _isHintsDrawerOpen = false;

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
    if (_currentPuzzle == null) return;
    
    final clue = _currentPuzzle!.clues[clueIndex];
    print('Revealing clue $clueIndex: ${clue.text}');
    print('Current revealed IDs: $_revealedClueIds');
    
    setState(() {
      _revealedClueIds.add(clueIndex.toString());
      _score += clue.cost; // cost is negative, so this subtracts from score
    });
    
    print('After reveal - revealed IDs: $_revealedClueIds');
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (!_gameEnded) {
      setState(() {
        _guessLocation = point;
      });
    }
  }

  void _toggleHintsDrawer() {
    setState(() {
      _isHintsDrawerOpen = !_isHintsDrawerOpen;
    });
  }

  bool _isMobileScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
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
      await UserStorageService.recordGameResult(
        difficulty: _currentDifficulty.name,
        score: finalScore,
        distance: distance,
        cluesUsed: _revealedClueIds.length,
      );
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
              const SizedBox(height: 8),
              _buildMapLegend(),
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

    // Calculate appropriate zoom level based on distance
    double zoomLevel;
    if (distance < 100) {
      zoomLevel = 8.0; // Very close - show detailed view
    } else if (distance < 500) {
      zoomLevel = 6.0; // Close - show regional view
    } else if (distance < 2000) {
      zoomLevel = 4.0; // Medium distance - show country view
    } else if (distance < 5000) {
      zoomLevel = 3.0; // Far - show continental view
    } else {
      zoomLevel = 2.0; // Very far - show global view
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(centerLat, centerLng),
        initialZoom: zoomLevel,
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
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.location_on, color: Colors.white, size: 20),
              ),
            ),
            Marker(
              point: correctLocation,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.flag, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [_guessLocation!, correctLocation],
              color: Colors.blue,
              strokeWidth: 4.0,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            icon: Icons.location_on,
            color: Colors.red,
            label: 'Your Guess',
          ),
          _buildLegendItem(
            icon: Icons.flag,
            color: Colors.green,
            label: 'Correct Location',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
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
      body: _isMobileScreen(context) ? _buildMobileLayout() : _buildDesktopLayout(),
      floatingActionButton: _isMobileScreen(context) 
        ? Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: _toggleHintsDrawer,
                heroTag: "hints",
                backgroundColor: Colors.purple,
                child: Icon(
                  _isHintsDrawerOpen ? Icons.close : Icons.lightbulb_outline,
                ),
                tooltip: _isHintsDrawerOpen ? 'Close Hints' : 'Open Hints',
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                heroTag: "profile",
                child: const Icon(Icons.person),
                tooltip: 'View Profile',
              ),
            ],
          )
        : FloatingActionButton(
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

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Main content
        Column(
          children: [
            ScoreDisplay(score: _score),
            Expanded(
              child: _buildMapView(),
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
        // Backdrop (rendered first, so it's behind the drawer)
        if (_isHintsDrawerOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleHintsDrawer,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
        // Hints drawer overlay (rendered last, so it's on top)
        if (_isHintsDrawerOpen)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drawer header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Clues',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _toggleHintsDrawer,
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // Clues content
                  Expanded(
                    child: _currentPuzzle != null
                        ? ClueDossier(
                            clues: _currentPuzzle!.clues,
                            revealedClueIds: _revealedClueIds,
                            onRevealClue: _revealClue,
                          )
                        : const Center(child: Text('Loading clues...')),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        ScoreDisplay(score: _score),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: _currentPuzzle != null
                    ? ClueDossier(
                        clues: _currentPuzzle!.clues,
                        revealedClueIds: _revealedClueIds,
                        onRevealClue: _revealClue,
                      )
                    : const Center(child: Text('Loading clues...')),
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
