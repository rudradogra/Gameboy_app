import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class GameBoySound {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _soundEnabled = true;

  // Initialize the sound system
  static Future<void> initialize() async {
    try {
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  // Play the classic GameBoy button click sound
  static Future<void> playButtonClick() async {
    if (!_soundEnabled) return;

    try {
      // Generate a classic 8-bit button click sound using system sound
      // This creates a brief, crisp click similar to old GameBoy buttons
      await HapticFeedback.lightImpact();

      // We'll also create a simple beep tone programmatically
      // Since we can't include actual sound files easily, we'll use a short system sound
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('Error playing button click sound: $e');
    }
  }

  // Play navigation sound (for D-pad movements)
  static Future<void> playNavigation() async {
    if (!_soundEnabled) return;

    try {
      // Lighter haptic feedback for navigation
      await HapticFeedback.selectionClick();
    } catch (e) {
      print('Error playing navigation sound: $e');
    }
  }

  // Play success sound
  static Future<void> playSuccess() async {
    if (!_soundEnabled) return;

    try {
      await HapticFeedback.mediumImpact();
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('Error playing success sound: $e');
    }
  }

  // Play error sound
  static Future<void> playError() async {
    if (!_soundEnabled) return;

    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      print('Error playing error sound: $e');
    }
  }

  // Toggle sound on/off
  static void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  // Check if sound is enabled
  static bool get isSoundEnabled => _soundEnabled;

  // Dispose of resources
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      print('Error disposing audio player: $e');
    }
  }
}
