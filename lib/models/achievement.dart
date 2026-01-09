import 'package:flutter/material.dart';
import 'package:perfect_pour/utils/app_theme.dart';

enum AchievementType {
  firstPerfect,
  streak3,
  streak5,
  streak10,
  level10,
  level25,
  level50,
  level100,
  speedDemon,
  precisionMaster,
}

class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  static Achievement get(AchievementType type) {
    switch (type) {
      case AchievementType.firstPerfect:
        return const Achievement(
          type: AchievementType.firstPerfect,
          title: 'First Drop!',
          description: 'Complete your first perfect pour',
          icon: Icons.water_drop,
          color: AppTheme.accentSecondary,
        );
      case AchievementType.streak3:
        return const Achievement(
          type: AchievementType.streak3,
          title: 'On Fire!',
          description: '3 perfect pours in a row',
          icon: Icons.local_fire_department,
          color: AppTheme.accentWarning,
        );
      case AchievementType.streak5:
        return const Achievement(
          type: AchievementType.streak5,
          title: 'Unstoppable!',
          description: '5 perfect pours in a row',
          icon: Icons.bolt,
          color: AppTheme.accentPrimary,
        );
      case AchievementType.streak10:
        return const Achievement(
          type: AchievementType.streak10,
          title: 'LEGENDARY!',
          description: '10 perfect pours in a row',
          icon: Icons.auto_awesome,
          color: AppTheme.accentTertiary,
        );
      case AchievementType.level10:
        return const Achievement(
          type: AchievementType.level10,
          title: 'Getting Started',
          description: 'Complete level 10',
          icon: Icons.trending_up,
          color: AppTheme.accentSuccess,
        );
      case AchievementType.level25:
        return const Achievement(
          type: AchievementType.level25,
          title: 'Quarter Way',
          description: 'Complete level 25',
          icon: Icons.workspace_premium,
          color: AppTheme.accentSecondary,
        );
      case AchievementType.level50:
        return const Achievement(
          type: AchievementType.level50,
          title: 'Halfway Hero',
          description: 'Complete level 50',
          icon: Icons.military_tech,
          color: AppTheme.accentWarning,
        );
      case AchievementType.level100:
        return const Achievement(
          type: AchievementType.level100,
          title: 'POUR MASTER',
          description: 'Complete all 100 levels',
          icon: Icons.emoji_events,
          color: AppTheme.accentTertiary,
        );
      case AchievementType.speedDemon:
        return const Achievement(
          type: AchievementType.speedDemon,
          title: 'Speed Demon',
          description: 'Complete a timed level with 3+ seconds left',
          icon: Icons.speed,
          color: AppTheme.accentError,
        );
      case AchievementType.precisionMaster:
        return const Achievement(
          type: AchievementType.precisionMaster,
          title: 'Precision Master',
          description: 'Hit exactly 0.0% difference',
          icon: Icons.gps_fixed,
          color: AppTheme.accentSuccess,
        );
    }
  }
}
