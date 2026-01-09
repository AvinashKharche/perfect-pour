import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:perfect_pour/utils/app_theme.dart';

class StreakIndicator extends StatelessWidget {
  final int streak;

  const StreakIndicator({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    if (streak < 2) return const SizedBox.shrink();

    Color color;
    String text;
    IconData icon;

    if (streak >= 10) {
      color = AppTheme.neonPurple;
      text = 'LEGENDARY! ×$streak';
      icon = Icons.auto_awesome;
    } else if (streak >= 5) {
      color = AppTheme.neonGold;
      text = 'UNSTOPPABLE! ×$streak';
      icon = Icons.bolt;
    } else if (streak >= 3) {
      color = AppTheme.neonOrange;
      text = 'ON FIRE! ×$streak';
      icon = Icons.local_fire_department;
    } else {
      color = AppTheme.neonCyan;
      text = 'STREAK ×$streak';
      icon = Icons.trending_up;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.glowShadow(color, blur: 15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16)
              .animate(onPlay: (c) => c.repeat())
              .shake(duration: 600.ms, delay: 800.ms),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    )
        .animate()
        .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut)
        .fadeIn();
  }
}

class StreakBonusPopup extends StatelessWidget {
  final int streak;
  final int bonusPoints;

  const StreakBonusPopup({
    super.key,
    required this.streak,
    required this.bonusPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.glowShadow(AppTheme.neonGold, blur: 25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔥 STREAK BONUS!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+$bonusPoints',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn()
        .scale(begin: const Offset(0, 0), curve: Curves.elasticOut, duration: 400.ms)
        .then()
        .fadeOut(delay: 1200.ms, duration: 300.ms);
  }
}
