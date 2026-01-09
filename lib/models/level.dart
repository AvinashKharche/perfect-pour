import 'package:perfect_pour/models/liquid_type.dart';

class Level {
  final int number;
  final double targetPercentage;
  final double marginOfError; // e.g., 5.0 means ±5%
  final LiquidType liquidType;
  final bool hasTimeLimit;
  final int timeLimitSeconds;

  const Level({
    required this.number,
    required this.targetPercentage,
    required this.marginOfError,
    required this.liquidType,
    this.hasTimeLimit = false,
    this.timeLimitSeconds = 0,
  });

  /// Check if the pour accuracy is within the acceptable margin
  bool isPerfect(double actualPercentage) {
    final difference = (actualPercentage - targetPercentage).abs();
    return difference <= marginOfError;
  }

  /// Calculate accuracy score (0-100)
  double calculateAccuracy(double actualPercentage) {
    final difference = (actualPercentage - targetPercentage).abs();
    if (difference == 0) return 100;
    if (difference >= marginOfError * 2) return 0;
    return ((1 - (difference / (marginOfError * 2))) * 100).clamp(0, 100);
  }

  /// Get star rating based on accuracy - stricter requirements!
  int getStars(double actualPercentage) {
    final difference = (actualPercentage - targetPercentage).abs();
    // 3 stars: within 30% of margin
    if (difference <= marginOfError * 0.3) return 3;
    // 2 stars: within 70% of margin
    if (difference <= marginOfError * 0.7) return 2;
    // 1 star: within margin
    if (difference <= marginOfError) return 1;
    return 0;
  }

  /// Generate all 100 levels with increasing difficulty
  static List<Level> generateAllLevels() {
    final levels = <Level>[];

    for (int i = 1; i <= 100; i++) {
      levels.add(_generateLevel(i));
    }

    return levels;
  }

  static Level _generateLevel(int levelNumber) {
    // Mix liquid types for variety - different speeds keep you on your toes!
    LiquidType liquidType;
    if (levelNumber <= 5) {
      liquidType = LiquidType.water; // Fast - learn the basics
    } else if (levelNumber <= 10) {
      liquidType = LiquidType.honey; // Slow - false sense of security
    } else {
      // Alternate to keep player guessing!
      final types = [LiquidType.water, LiquidType.oil, LiquidType.honey, LiquidType.lava];
      liquidType = types[(levelNumber + (levelNumber ~/ 7)) % types.length];
    }

    // Target percentage - use tricky decimals for harder levels!
    double targetPercentage;
    if (levelNumber <= 10) {
      // Easy: whole numbers
      final targets = [25, 40, 60, 75, 35, 55, 70, 45, 80, 30];
      targetPercentage = targets[(levelNumber - 1) % targets.length].toDouble();
    } else if (levelNumber <= 30) {
      // Medium: .5 decimals
      final targets = [27.5, 42.5, 67.5, 32.5, 57.5, 72.5, 37.5, 62.5, 77.5, 22.5];
      targetPercentage = targets[(levelNumber - 1) % targets.length];
    } else {
      // Hard: tricky decimals that are hard to hit!
      final targets = [23.7, 41.3, 58.8, 76.2, 34.6, 67.4, 29.1, 83.7, 46.9, 71.3, 
                       38.2, 54.7, 62.8, 79.4, 26.6, 48.3, 85.1, 33.9, 69.7, 91.2];
      targetPercentage = targets[(levelNumber - 1) % targets.length];
    }

    // Margin of error decreases FAST - game gets hard quickly!
    double marginOfError;
    if (levelNumber <= 3) {
      marginOfError = 5.0; // Tutorial: ±5%
    } else if (levelNumber <= 8) {
      marginOfError = 3.0; // Easy: ±3%
    } else if (levelNumber <= 15) {
      marginOfError = 2.0; // Medium: ±2%
    } else if (levelNumber <= 30) {
      marginOfError = 1.5; // Hard: ±1.5%
    } else if (levelNumber <= 50) {
      marginOfError = 1.0; // Very Hard: ±1%
    } else if (levelNumber <= 75) {
      marginOfError = 0.7; // Expert: ±0.7%
    } else {
      marginOfError = 0.5; // Master: ±0.5% (insane precision!)
    }

    // Add time limits earlier - pressure from level 15!
    bool hasTimeLimit = levelNumber > 15;
    int timeLimitSeconds = 0;
    if (hasTimeLimit) {
      if (levelNumber <= 30) {
        timeLimitSeconds = 12;
      } else if (levelNumber <= 50) {
        timeLimitSeconds = 8;
      } else if (levelNumber <= 75) {
        timeLimitSeconds = 6;
      } else {
        timeLimitSeconds = 4; // Insane!
      }
    }

    return Level(
      number: levelNumber,
      targetPercentage: targetPercentage,
      marginOfError: marginOfError,
      liquidType: liquidType,
      hasTimeLimit: hasTimeLimit,
      timeLimitSeconds: timeLimitSeconds,
    );
  }

  String get difficultyName {
    if (number <= 3) return 'Tutorial';
    if (number <= 8) return 'Easy';
    if (number <= 15) return 'Medium';
    if (number <= 30) return 'Hard';
    if (number <= 50) return 'Expert';
    if (number <= 75) return 'Master';
    return 'INSANE';
  }
}
