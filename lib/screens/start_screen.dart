import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'profile_screen.dart';
import '../services/user_storage_service.dart';
import '../models/user_profile.dart';

enum Difficulty { easy, medium, hard }

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await UserStorageService.loadUserProfile();
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with profile button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // Spacer for centering
                    const Text(
                      'Choose Difficulty',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.public,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'A Geo-Detective Puzzle Game',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (_userProfile != null) _buildQuickStats(),
                        const SizedBox(height: 24),
                        const Text(
                          'Choose Your Difficulty',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildDifficultyCard(
                          context,
                          'Easy',
                          'Nations and countries\nPerfect for beginners',
                          Difficulty.easy,
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _buildDifficultyCard(
                          context,
                          'Medium',
                          'Cities and urban locations\nA balanced challenge',
                          Difficulty.medium,
                          Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        _buildDifficultyCard(
                          context,
                          'Hard',
                          'Monuments and landmarks\nFor geography experts',
                          Difficulty.hard,
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context,
    String title,
    String description,
    Difficulty difficulty,
    Color color,
  ) {
    return Card(
      elevation: 8,
      child: InkWell(
        onTap: () => _startGame(context, difficulty),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, Difficulty difficulty) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(initialDifficulty: difficulty),
      ),
    );
  }

  Widget _buildQuickStats() {
    if (_userProfile == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Games', _userProfile!.totalGamesPlayed.toString()),
          _buildStatItem('Best Score', _userProfile!.bestScore.toString()),
          _buildStatItem('Achievements', 
            '${_userProfile!.achievements.where((a) => a.unlocked).length}/${_userProfile!.achievements.length}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
