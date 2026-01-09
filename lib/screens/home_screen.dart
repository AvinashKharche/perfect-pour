import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:perfect_pour/services/game_state.dart';
import 'package:perfect_pour/screens/level_select_screen.dart';
import 'package:perfect_pour/screens/game_screen.dart';
import 'package:perfect_pour/utils/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(decoration: const BoxDecoration(gradient: AppTheme.bgGradient)),
          
          // Subtle background animation (optional, but nice)
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/bg_pattern.png', // Placeholder, using container for now
                errorBuilder: (c, e, s) => Container(), 
              ),
            ),
          ),

          SafeArea(
            child: Consumer<GameState>(
              builder: (context, gameState, _) {
                if (!gameState.isLoaded) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.accentPrimary));
                }
                
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    
                    // Header Stats
                    _buildHeaderStats(gameState),
                    
                    const Spacer(flex: 3),
                    
                    // Main Title Area
                    _buildTitleSection(),
                    
                    const Spacer(flex: 4),
                    
                    // Primary Action (Play)
                    _buildPlayButton(context, gameState),
                    
                    const SizedBox(height: 24),
                    
                    // Secondary Actions (Levels, etc)
                    _buildSecondaryActions(context),
                    
                    const Spacer(flex: 2),
                    
                    // Version / Credit
                    Text(
                      'v1.2.0 • INDIE STUDIO',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppTheme.textTertiary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats(GameState gameState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Total Score Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: AppTheme.glassCard.copyWith(borderRadius: BorderRadius.circular(100)),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: AppTheme.accentWarning, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${gameState.totalScore}',
                  style: AppTheme.textTheme.labelLarge,
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Streak (only if active)
          if (gameState.currentStreak > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentPrimary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${gameState.currentStreak}',
                    style: AppTheme.textTheme.labelLarge!.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ).animate().scale(curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.accentGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentSecondary.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(Icons.water_drop_rounded, size: 64, color: Colors.white),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds),
         
        const SizedBox(height: 40),
        
        Text(
          'PERFECT\nPOUR',
          textAlign: TextAlign.center,
          style: AppTheme.textTheme.displayLarge!.copyWith(
            height: 0.9,
            letterSpacing: -1,
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
        
        const SizedBox(height: 16),
        
        Text(
          'Master the flow',
          style: AppTheme.textTheme.bodyLarge!.copyWith(
            letterSpacing: 2,
            color: AppTheme.textSecondary,
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context, GameState gameState) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameScreen(level: gameState.getLevel(gameState.highestUnlockedLevel))),
      ),
      child: Container(
        width: 280,
        height: 80,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentPrimary.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CONTINUE',
                  style: AppTheme.textTheme.labelLarge!.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Level ${gameState.highestUnlockedLevel}',
                  style: AppTheme.textTheme.headlineMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate()
     .fadeIn(delay: 600.ms)
     .slideY(begin: 0.2, end: 0)
     .shimmer(delay: 2.seconds, duration: 2.seconds);
  }

  Widget _buildSecondaryActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SecondaryButton(
          icon: Icons.grid_view_rounded,
          label: 'Levels',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
          ),
        ),
        const SizedBox(width: 16),
        _SecondaryButton(
          icon: Icons.settings_rounded,
          label: 'Settings',
          onTap: () {
            // TODO: Settings screen
          },
        ),
      ],
    ).animate().fadeIn(delay: 800.ms);
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: AppTheme.glassCard.copyWith(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.bgSurface.withValues(alpha: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTheme.textTheme.labelLarge!.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
