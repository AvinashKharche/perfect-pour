import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:perfect_pour/models/level.dart';
import 'package:perfect_pour/models/liquid_type.dart';
import 'package:perfect_pour/services/game_state.dart';
import 'package:perfect_pour/utils/app_theme.dart';

class ResultOverlay extends StatelessWidget {
  final Level level;
  final double actualPercentage;
  final VoidCallback onRetry;
  final VoidCallback onNextLevel;
  final VoidCallback onHome;
  final AnimationController animationController;

  const ResultOverlay({
    super.key,
    required this.level,
    required this.actualPercentage,
    required this.onRetry,
    required this.onNextLevel,
    required this.onHome,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final stars = level.getStars(actualPercentage);
    final passed = stars > 0;
    final difference = actualPercentage - level.targetPercentage;
    final streak = gameState.currentStreak;

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        // Fade in background, slide up content
        final opacity = animationController.value;
        final slide = Curves.easeOutCubic.transform(animationController.value);
        
        return Stack(
          children: [
            // Dark Overlay
            Container(color: AppTheme.bgDarkest.withValues(alpha: opacity)),
            
            // Content
            SafeArea(
              child: Align(
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: Offset(0, 50 * (1 - slide)),
                  child: Opacity(
                    opacity: opacity,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Result Icon
                          _buildResultIcon(stars, passed),
                          
                          const SizedBox(height: 32),
                          
                          // Stars
                          _buildStars(stars),
                          
                          if (streak >= 2) ...[
                            const SizedBox(height: 20),
                            _buildStreakBadge(streak),
                          ],
                          
                          const SizedBox(height: 32),
                          
                          // Stats
                          _buildStatsCard(difference),
                          
                          const SizedBox(height: 40),
                          
                          // Actions
                          _buildButtons(passed),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultIcon(int stars, bool passed) {
    final config = _getResultConfig(stars, passed);
    
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [config.color, config.color.withValues(alpha: 0.5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: config.color.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(config.icon, color: Colors.white, size: 48),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          config.title,
          style: AppTheme.textTheme.displayMedium!.copyWith(
            color: config.color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildStars(int earnedStars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final earned = i < earnedStars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.star_rounded,
            size: 48,
            color: earned ? AppTheme.accentWarning : AppTheme.textTertiary.withValues(alpha: 0.2),
          ).animate(target: earned ? 1 : 0)
           .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 200.ms)
           .then()
           .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 200.ms),
        );
      }),
    );
  }

  Widget _buildStreakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            '$streak STREAK!',
            style: AppTheme.textTheme.labelLarge!.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(double difference) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard.copyWith(
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Target', '${level.targetPercentage.toStringAsFixed(1)}%', AppTheme.textSecondary),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
          _buildStat(
            'Difference', 
            '${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)}%', 
            difference.abs() <= level.marginOfError ? AppTheme.accentSuccess : AppTheme.accentError
          ),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
          _buildStat('You', '${actualPercentage.toStringAsFixed(1)}%', Colors.white),
        ],
      ),
    );
  }
  
  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: AppTheme.textTheme.bodyMedium!.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.textTheme.headlineMedium!.copyWith(color: color)),
      ],
    );
  }

  Widget _buildButtons(bool passed) {
    return Column(
      children: [
        if (passed && level.number < 100)
          GestureDetector(
            onTap: onNextLevel,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentSecondary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'NEXT LEVEL',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
          
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _SecondaryButton(
                icon: Icons.replay_rounded,
                label: 'Retry',
                onTap: onRetry,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SecondaryButton(
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: onHome,
              ),
            ),
          ],
        ),
      ],
    );
  }

  _ResultConfig _getResultConfig(int stars, bool passed) {
    if (stars == 3) {
      return _ResultConfig('PERFECT!', Icons.emoji_events_rounded, AppTheme.accentWarning);
    } else if (stars == 2) {
      return _ResultConfig('GREAT!', Icons.thumb_up_rounded, AppTheme.accentSuccess);
    } else if (stars == 1) {
      return _ResultConfig('GOOD', Icons.check_circle_rounded, AppTheme.accentSecondary);
    } else {
      return _ResultConfig('TRY AGAIN', Icons.refresh_rounded, AppTheme.accentError);
    }
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.textTheme.labelLarge!.copyWith(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ResultConfig {
  final String title;
  final IconData icon;
  final Color color;
  
  _ResultConfig(this.title, this.icon, this.color);
}
