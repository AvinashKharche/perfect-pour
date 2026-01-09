import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perfect_pour/models/level.dart';
import 'package:perfect_pour/models/achievement.dart';

class GameState extends ChangeNotifier {
  static const String _highestLevelKey = 'highest_level';
  static const String _totalPerfectPoursKey = 'total_perfect_pours';
  static const String _levelStarsPrefix = 'level_stars_';
  static const String _bestAccuracyPrefix = 'best_accuracy_';
  static const String _currentStreakKey = 'current_streak';
  static const String _bestStreakKey = 'best_streak';
  static const String _totalScoreKey = 'total_score';
  static const String _achievementsKey = 'achievements';
  static const String _hasRatedAppKey = 'has_rated_app';
  
  late SharedPreferences _prefs;
  bool _isLoaded = false;
  
  int _highestUnlockedLevel = 1;
  int _totalPerfectPours = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _totalScore = 0;
  bool _hasRatedApp = false;
  bool _ratePromptShownThisSession = false;
  final Map<int, int> _levelStars = {};
  final Map<int, double> _bestAccuracy = {};
  Set<String> _unlockedAchievements = {};
  
  // Pending achievement to show
  Achievement? _pendingAchievement;
  
  List<Level> _allLevels = [];
  
  // Getters
  bool get isLoaded => _isLoaded;
  int get highestUnlockedLevel => _highestUnlockedLevel;
  int get totalPerfectPours => _totalPerfectPours;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  int get totalScore => _totalScore;
  bool get hasRatedApp => _hasRatedApp;
  bool get ratePromptShownThisSession => _ratePromptShownThisSession;
  List<Level> get allLevels => _allLevels;
  Achievement? get pendingAchievement => _pendingAchievement;
  
  int getStarsForLevel(int level) => _levelStars[level] ?? 0;
  double getBestAccuracyForLevel(int level) => _bestAccuracy[level] ?? 0;
  
  int get totalStars {
    int total = 0;
    _levelStars.forEach((_, stars) => total += stars);
    return total;
  }
  
  int get maxPossibleStars => _allLevels.length * 3;
  
  /// Calculate streak bonus points
  int get streakBonus {
    if (_currentStreak < 2) return 0;
    if (_currentStreak < 3) return 10;
    if (_currentStreak < 5) return 25;
    if (_currentStreak < 10) return 50;
    return 100; // 10+ streak
  }
  
  /// Load progress from SharedPreferences
  Future<void> loadProgress() async {
    _prefs = await SharedPreferences.getInstance();
    
    _highestUnlockedLevel = _prefs.getInt(_highestLevelKey) ?? 1;
    _totalPerfectPours = _prefs.getInt(_totalPerfectPoursKey) ?? 0;
    _currentStreak = _prefs.getInt(_currentStreakKey) ?? 0;
    _bestStreak = _prefs.getInt(_bestStreakKey) ?? 0;
    _totalScore = _prefs.getInt(_totalScoreKey) ?? 0;
    _hasRatedApp = _prefs.getBool(_hasRatedAppKey) ?? false;
    
    // Load achievements
    final achievementsList = _prefs.getStringList(_achievementsKey) ?? [];
    _unlockedAchievements = achievementsList.toSet();
    
    // Load stars and accuracy for each level
    for (int i = 1; i <= 100; i++) {
      final stars = _prefs.getInt('$_levelStarsPrefix$i');
      if (stars != null) _levelStars[i] = stars;
      
      final accuracy = _prefs.getDouble('$_bestAccuracyPrefix$i');
      if (accuracy != null) _bestAccuracy[i] = accuracy;
    }
    
    // Generate all levels
    _allLevels = Level.generateAllLevels();
    
    // DEBUG: Unlock all levels for testing
    _highestUnlockedLevel = 100;
    
    _isLoaded = true;
    notifyListeners();
  }
  
  /// Clear pending achievement after showing
  void clearPendingAchievement() {
    _pendingAchievement = null;
    notifyListeners();
  }
  
  /// Unlock an achievement
  Future<void> _unlockAchievement(AchievementType type) async {
    final key = type.toString();
    if (_unlockedAchievements.contains(key)) return;
    
    _unlockedAchievements.add(key);
    await _prefs.setStringList(_achievementsKey, _unlockedAchievements.toList());
    
    _pendingAchievement = Achievement.get(type);
    notifyListeners();
  }
  
  /// Check if achievement is unlocked
  bool hasAchievement(AchievementType type) {
    return _unlockedAchievements.contains(type.toString());
  }
  
  /// Save level completion
  Future<void> completeLevel({
    required int levelNumber,
    required int stars,
    required double accuracy,
    required bool isPerfect,
    double difference = 0,
    int remainingSeconds = 0,
  }) async {
    // Calculate base score
    int scoreEarned = stars * 100;
    
    // Update stars if better
    final currentStars = _levelStars[levelNumber] ?? 0;
    if (stars > currentStars) {
      _levelStars[levelNumber] = stars;
      await _prefs.setInt('$_levelStarsPrefix$levelNumber', stars);
    }
    
    // Update best accuracy if better
    final currentAccuracy = _bestAccuracy[levelNumber] ?? 0;
    if (accuracy > currentAccuracy) {
      _bestAccuracy[levelNumber] = accuracy;
      await _prefs.setDouble('$_bestAccuracyPrefix$levelNumber', accuracy);
    }
    
    // Unlock next level
    if (stars > 0 && levelNumber >= _highestUnlockedLevel && levelNumber < 100) {
      _highestUnlockedLevel = levelNumber + 1;
      await _prefs.setInt(_highestLevelKey, _highestUnlockedLevel);
    }
    
    // Track perfect pours and streaks
    if (isPerfect) {
      _totalPerfectPours++;
      _currentStreak++;
      scoreEarned += streakBonus;
      
      if (_currentStreak > _bestStreak) {
        _bestStreak = _currentStreak;
        await _prefs.setInt(_bestStreakKey, _bestStreak);
      }
      
      await _prefs.setInt(_totalPerfectPoursKey, _totalPerfectPours);
      await _prefs.setInt(_currentStreakKey, _currentStreak);
      
      // Check for first perfect achievement
      if (_totalPerfectPours == 1) {
        _unlockAchievement(AchievementType.firstPerfect);
      }
      
      // Check for streak achievements
      if (_currentStreak == 3) {
        _unlockAchievement(AchievementType.streak3);
      } else if (_currentStreak == 5) {
        _unlockAchievement(AchievementType.streak5);
      } else if (_currentStreak == 10) {
        _unlockAchievement(AchievementType.streak10);
      }
      
      // Check for precision master (exactly 0.0% difference)
      if (difference.abs() < 0.05) {
        _unlockAchievement(AchievementType.precisionMaster);
      }
      
      // Check for speed demon (3+ seconds left on timed level)
      if (remainingSeconds >= 3) {
        _unlockAchievement(AchievementType.speedDemon);
      }
    } else {
      // Reset streak on fail
      _currentStreak = 0;
      await _prefs.setInt(_currentStreakKey, 0);
    }
    
    // Update total score
    _totalScore += scoreEarned;
    await _prefs.setInt(_totalScoreKey, _totalScore);
    
    // Check for level milestones
    if (levelNumber == 10 && stars > 0) {
      _unlockAchievement(AchievementType.level10);
    } else if (levelNumber == 25 && stars > 0) {
      _unlockAchievement(AchievementType.level25);
    } else if (levelNumber == 50 && stars > 0) {
      _unlockAchievement(AchievementType.level50);
    } else if (levelNumber == 100 && stars > 0) {
      _unlockAchievement(AchievementType.level100);
    }
    
    notifyListeners();
  }
  
  /// Mark rate prompt as shown for this session
  void markRatePromptShown() {
    _ratePromptShownThisSession = true;
    // Don't notify listeners as this doesn't affect UI rebuilding
  }

  /// Mark app as rated
  Future<void> markAppRated() async {
    _hasRatedApp = true;
    await _prefs.setBool(_hasRatedAppKey, true);
    notifyListeners();
  }
  
  /// Check if level is unlocked
  bool isLevelUnlocked(int level) {
    return level <= _highestUnlockedLevel;
  }
  
  /// Get level by number
  Level getLevel(int number) {
    return _allLevels.firstWhere(
      (l) => l.number == number,
      orElse: () => _allLevels.first,
    );
  }
  
  /// Check if level is a boss level (every 10th level)
  bool isBossLevel(int level) {
    return level % 10 == 0;
  }
  
  /// Reset all progress (for testing)
  Future<void> resetProgress() async {
    await _prefs.clear();
    _highestUnlockedLevel = 1;
    _totalPerfectPours = 0;
    _currentStreak = 0;
    _bestStreak = 0;
    _totalScore = 0;
    _levelStars.clear();
    _bestAccuracy.clear();
    _unlockedAchievements.clear();
    notifyListeners();
  }
  
  /// Unlock all levels (for testing)
  Future<void> unlockAllLevels() async {
    _highestUnlockedLevel = 100;
    await _prefs.setInt(_highestLevelKey, 100);
    notifyListeners();
  }
}
