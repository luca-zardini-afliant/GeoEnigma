import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _soundEnabled = true;

  // Enable/disable sound effects
  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  static bool get soundEnabled => _soundEnabled;

  // Play system sound effects using Flutter's built-in sounds
  static Future<void> playClickSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('Error playing click sound: $e');
    }
  }

  static Future<void> playSuccessSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      print('Error playing success sound: $e');
    }
  }

  static Future<void> playErrorSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      print('Error playing error sound: $e');
    }
  }

  static Future<void> playHintRevealSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('Error playing hint reveal sound: $e');
    }
  }

  static Future<void> playTimerTickSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('Error playing timer tick sound: $e');
    }
  }

  static Future<void> playGameStartSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      print('Error playing game start sound: $e');
    }
  }

  static Future<void> playGameEndSound() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      print('Error playing game end sound: $e');
    }
  }
}
