import 'package:flutter/foundation.dart';
import 'audio_service_stub.dart'
    if (dart.library.html) 'audio_service_web.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _soundEnabled = true;
  
  bool get soundEnabled => _soundEnabled;
  
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }
  
  void _playSound(String type) {
    if (!_soundEnabled) return;
    playWebSound(type);
  }
  
  /// Play button tap sound
  void playTap() => _playSound('tap');
  
  /// Start pouring sound (continuous)
  void playPourStart() => _playSound('pourStart');
  
  /// Stop pouring sound
  void playPourStop() => _playSound('pourStop');
  
  /// Play success sound (when you pass a level)
  void playSuccess() => _playSound('success');
  
  /// Play perfect sound (3 stars)
  void playPerfect() => _playSound('perfect');
  
  /// Play fail sound
  void playFail() => _playSound('fail');
  
  /// Play achievement sound
  void playAchievement() => _playSound('achievement');
  
  /// Play streak sound
  void playStreak() => _playSound('streak');
}
