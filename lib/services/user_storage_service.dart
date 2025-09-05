import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserStorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _userNameKey = 'user_name';

  // Load user profile from local storage
  static Future<UserProfile> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_userProfileKey);
      
      if (profileJson != null) {
        final profileData = json.decode(profileJson) as Map<String, dynamic>;
        return UserProfile.fromJson(profileData);
      } else {
        // Create new profile with default achievements
        final newProfile = UserProfile.empty().copyWith(
          achievements: Achievements.all,
        );
        await saveUserProfile(newProfile);
        return newProfile;
      }
    } catch (e) {
      // If there's an error, return a fresh profile
      return UserProfile.empty().copyWith(
        achievements: Achievements.all,
      );
    }
  }

  // Save user profile to local storage
  static Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(profile.toJson());
      await prefs.setString(_userProfileKey, profileJson);
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  // Update user name
  static Future<void> updateUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name);
      
      // Also update the profile
      final profile = await loadUserProfile();
      final updatedProfile = profile.copyWith(name: name);
      await saveUserProfile(updatedProfile);
    } catch (e) {
      throw Exception('Failed to update user name: $e');
    }
  }

  // Record a game result
  static Future<UserProfile> recordGameResult({
    required String difficulty,
    required int score,
    required double distance,
    required int cluesUsed,
  }) async {
    try {
      final profile = await loadUserProfile();
      
      // Update overall stats
      final newTotalGames = profile.totalGamesPlayed + 1;
      final newTotalScore = profile.totalScore + score;
      final newBestScore = score > profile.bestScore ? score : profile.bestScore;
      final newAverageScore = newTotalScore ~/ newTotalGames;
      
      // Update difficulty-specific stats
      final difficultyStats = profile.difficultyStats[difficulty]!;
      final newDifficultyGames = difficultyStats.gamesPlayed + 1;
      final newDifficultyTotalScore = difficultyStats.totalScore + score;
      final newDifficultyBestScore = score > difficultyStats.bestScore ? score : difficultyStats.bestScore;
      final newDifficultyAverageScore = newDifficultyTotalScore ~/ newDifficultyGames;
      final newPerfectGuesses = distance < 25 ? difficultyStats.perfectGuesses + 1 : difficultyStats.perfectGuesses;
      final newTotalDistance = difficultyStats.totalDistance + distance.round();
      
      final updatedDifficultyStats = difficultyStats.copyWith(
        gamesPlayed: newDifficultyGames,
        bestScore: newDifficultyBestScore,
        totalScore: newDifficultyTotalScore,
        averageScore: newDifficultyAverageScore,
        perfectGuesses: newPerfectGuesses,
        totalDistance: newTotalDistance,
      );
      
      // Check for new achievements
      final updatedAchievements = _checkAchievements(
        profile.achievements,
        newTotalGames,
        newBestScore,
        newPerfectGuesses,
        updatedDifficultyStats,
      );
      
      final updatedProfile = profile.copyWith(
        totalGamesPlayed: newTotalGames,
        totalScore: newTotalScore,
        bestScore: newBestScore,
        averageScore: newAverageScore,
        achievements: updatedAchievements,
        difficultyStats: {
          ...profile.difficultyStats,
          difficulty: updatedDifficultyStats,
        },
        lastPlayed: DateTime.now(),
      );
      
      await saveUserProfile(updatedProfile);
      return updatedProfile;
    } catch (e) {
      throw Exception('Failed to record game result: $e');
    }
  }

  // Check and unlock new achievements
  static List<Achievement> _checkAchievements(
    List<Achievement> currentAchievements,
    int totalGames,
    int bestScore,
    int totalPerfectGuesses,
    DifficultyStats difficultyStats,
  ) {
    final updatedAchievements = <Achievement>[];
    
    for (final achievement in currentAchievements) {
      bool shouldUnlock = false;
      DateTime? unlockedAt = achievement.unlockedAt;
      
      if (!achievement.unlocked) {
        switch (achievement.id) {
          case 'first_game':
            shouldUnlock = totalGames >= 1;
            break;
          case 'perfect_guess':
            shouldUnlock = totalPerfectGuesses >= 1;
            break;
          case 'high_score':
            shouldUnlock = bestScore >= 8000;
            break;
          case 'explorer_easy':
            shouldUnlock = difficultyStats.difficulty == 'easy' && difficultyStats.gamesPlayed >= 10;
            break;
          case 'explorer_medium':
            shouldUnlock = difficultyStats.difficulty == 'medium' && difficultyStats.gamesPlayed >= 10;
            break;
          case 'explorer_hard':
            shouldUnlock = difficultyStats.difficulty == 'hard' && difficultyStats.gamesPlayed >= 10;
            break;
          case 'dedicated':
            shouldUnlock = totalGames >= 50;
            break;
          case 'master':
            shouldUnlock = totalPerfectGuesses >= 5;
            break;
        }
        
        if (shouldUnlock) {
          unlockedAt = DateTime.now();
        }
      }
      
      updatedAchievements.add(achievement.copyWith(
        unlocked: achievement.unlocked || shouldUnlock,
        unlockedAt: unlockedAt,
      ));
    }
    
    return updatedAchievements;
  }

  // Reset all user data
  static Future<void> resetUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userProfileKey);
      await prefs.remove(_userNameKey);
    } catch (e) {
      throw Exception('Failed to reset user data: $e');
    }
  }
}
