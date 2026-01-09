import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:perfect_pour/services/game_state.dart';
import 'package:perfect_pour/screens/game_screen.dart';
import 'package:perfect_pour/utils/app_theme.dart';
import 'package:perfect_pour/models/level.dart';
import 'package:perfect_pour/models/liquid_type.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDarkest,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Level grid
            Expanded(
              child: Consumer<GameState>(
                builder: (context, gameState, _) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: gameState.allLevels.length,
                    itemBuilder: (context, index) {
                      final level = gameState.allLevels[index];
                      final isUnlocked = gameState.isLevelUnlocked(level.number);
                      final stars = gameState.getStarsForLevel(level.number);
                      final isBoss = level.number % 10 == 0;
                      
                      return _LevelTile(
                        level: level,
                        isUnlocked: isUnlocked,
                        stars: stars,
                        isBoss: isBoss,
                        onTap: isUnlocked ? () => _navigateToLevel(context, level) : null,
                      )
                          .animate(delay: (20 * (index % 25)).ms)
                          .fadeIn()
                          .scale(begin: const Offset(0.9, 0.9));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.glassCard.copyWith(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            'Select Level',
            style: AppTheme.textTheme.headlineMedium,
          ),
          const Spacer(),
          Consumer<GameState>(
            builder: (context, gameState, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentWarning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppTheme.accentWarning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: AppTheme.accentWarning, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${gameState.totalStars}/${gameState.maxPossibleStars}',
                      style: AppTheme.textTheme.labelLarge!.copyWith(color: AppTheme.accentWarning),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _navigateToLevel(BuildContext context, Level level) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(level: level)),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final Level level;
  final bool isUnlocked;
  final int stars;
  final bool isBoss;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.isBoss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isBoss ? AppTheme.accentTertiary : level.liquidType.color;
    final color = isUnlocked ? baseColor : AppTheme.textTertiary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isUnlocked && isBoss ? AppTheme.bossGradient : null,
          color: isBoss ? null : (isUnlocked 
              ? color.withValues(alpha: 0.15)
              : AppTheme.bgSurface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked 
                ? color.withValues(alpha: isBoss ? 0.6 : 0.3)
                : Colors.white.withValues(alpha: 0.05),
            width: isBoss ? 2 : 1,
          ),
          boxShadow: stars == 3 && isUnlocked && !isBoss
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              if (isBoss)
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('BOSS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                
              Text(
                '${level.number}',
                style: AppTheme.textTheme.headlineMedium!.copyWith(
                  color: isBoss ? Colors.white : color,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              
              const SizedBox(height: 6),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Icon(
                      Icons.star_rounded,
                      size: 10,
                      color: i < stars 
                          ? (isBoss ? AppTheme.accentWarning : color)
                          : Colors.black.withValues(alpha: 0.2),
                    ),
                  );
                }),
              ),
            ] else ...[
              Icon(
                Icons.lock_rounded,
                color: AppTheme.textTertiary.withValues(alpha: 0.5),
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
