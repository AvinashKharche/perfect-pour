import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:perfect_pour/models/achievement.dart';
import 'package:perfect_pour/utils/app_theme.dart';
import 'package:perfect_pour/services/audio_service.dart';

class AchievementPopup extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementPopup({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Play achievement sound
    AudioService().playAchievement();
    Future.delayed(const Duration(seconds: 3), onDismiss);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                achievement.color,
                // Simple darkening without lerp to avoid null safety issues
                Color.fromARGB(
                  achievement.color.alpha,
                  (achievement.color.red * 0.8).round(),
                  (achievement.color.green * 0.8).round(),
                  (achievement.color.blue * 0.8).round(),
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: achievement.color.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(achievement.icon, color: Colors.white, size: 24),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 400.ms,
                  ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ACHIEVEMENT UNLOCKED',
                      style: AppTheme.textTheme.labelSmall!.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 1,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement.title,
                      style: AppTheme.textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      achievement.description,
                      style: AppTheme.textTheme.bodyMedium!.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .slideY(begin: -1, end: 0, curve: Curves.elasticOut, duration: 500.ms)
            .shimmer(delay: 400.ms, duration: 1200.ms, color: Colors.white24),
      ),
    );
  }
}
