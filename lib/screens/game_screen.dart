import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:perfect_pour/models/level.dart';
import 'package:perfect_pour/models/liquid_type.dart';
import 'package:perfect_pour/services/game_state.dart';
import 'package:perfect_pour/utils/app_theme.dart';
import 'package:perfect_pour/widgets/liquid_container.dart';
import 'package:perfect_pour/widgets/result_overlay.dart';
import 'package:perfect_pour/widgets/achievement_popup.dart';
import 'package:perfect_pour/services/audio_service.dart';
import 'package:perfect_pour/services/ad_service.dart';

enum GamePhase { ready, pouring, stopped, result }

class GameScreen extends StatefulWidget {
  final Level level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  GamePhase _phase = GamePhase.ready;
  double _currentFillPercentage = 0;
  Timer? _pourTimer;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  
  double _shakeOffset = 0;
  
  late AnimationController _pourController;
  late AnimationController _resultController;
  late AnimationController _shakeController;
  
  final _audio = AudioService();
  
  bool get _isBossLevel => widget.level.number % 10 == 0;
  
  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.level.timeLimitSeconds;
    
    _pourController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _shakeController.addListener(() {
      setState(() {
        _shakeOffset = math.sin(_shakeController.value * math.pi * 8) * 
            (1 - _shakeController.value) * 8;
      });
    });
  }

  @override
  void dispose() {
    _pourTimer?.cancel();
    _countdownTimer?.cancel();
    _audio.playPourStop(); 
    _pourController.dispose();
    _resultController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _startPouring() {
    if (_phase != GamePhase.ready) return;
    
    HapticFeedback.lightImpact();
    _audio.playTap();
    setState(() => _phase = GamePhase.pouring);
    _pourController.forward();
    
    _audio.playPourStart();
    
    if (widget.level.hasTimeLimit) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
          if (_remainingSeconds <= 3) HapticFeedback.mediumImpact();
        } else {
          _stopPouring();
        }
      });
    }
    
    final pourRate = 1.2 * widget.level.liquidType.pourSpeed;
    _pourTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_phase == GamePhase.pouring) {
        setState(() {
          _currentFillPercentage += pourRate;
          if (_currentFillPercentage >= 100) {
            _currentFillPercentage = 100;
            _stopPouring();
          }
        });
      }
    });
  }

  void _stopPouring() {
    if (_phase != GamePhase.pouring) return;
    
    _pourTimer?.cancel();
    _countdownTimer?.cancel();
    _pourController.reverse();
    
    _audio.playPourStop();
    
    final stars = widget.level.getStars(_currentFillPercentage);
    
    if (stars == 3) {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
      _audio.playPerfect();
    } else if (stars > 0) {
      HapticFeedback.mediumImpact();
      _audio.playSuccess();
    } else {
      HapticFeedback.mediumImpact();
      _audio.playFail();
    }
    
    setState(() => _phase = GamePhase.stopped);
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _phase = GamePhase.result);
        _resultController.forward();
        _saveResult();
      }
    });
  }

  void _saveResult() {
    final gameState = context.read<GameState>();
    final accuracy = widget.level.calculateAccuracy(_currentFillPercentage);
    final stars = widget.level.getStars(_currentFillPercentage);
    final isPerfect = widget.level.isPerfect(_currentFillPercentage);
    final difference = _currentFillPercentage - widget.level.targetPercentage;
    
    // Check for "Rate Us" trigger (3 stars and not rated yet)
    if (stars == 3 && !gameState.hasRatedApp) {
      // Small delay to not interfere with result animation
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _showRateUsDialog();
      });
    }
    
    // Track game completion for ads
    AdService.instance.onGameCompleted();
    
    // Show interstitial if needed (after a slight delay so it doesn't pop instantly)
    if (AdService.instance.shouldShowInterstitial()) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        AdService.instance.showInterstitial();
      });
    }
    
    gameState.completeLevel(
      levelNumber: widget.level.number,
      stars: stars,
      accuracy: accuracy,
      isPerfect: isPerfect,
      difference: difference,
      remainingSeconds: _remainingSeconds,
    );
  }
  
  void _showRateUsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Enjoying Perfect Pour?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'If you like the game, please take a moment to rate it. It really helps us!',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later', style: TextStyle(color: AppTheme.textTertiary)),
          ),
          TextButton(
            onPressed: () {
              context.read<GameState>().markAppRated();
              Navigator.pop(context);
              // TODO: Launch store URL
              // launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.perfectpour.game'));
            },
            child: const Text('Rate Now', style: TextStyle(color: AppTheme.accentPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _retry() {
    setState(() {
      _phase = GamePhase.ready;
      _currentFillPercentage = 0;
      _remainingSeconds = widget.level.timeLimitSeconds;
    });
    _resultController.reset();
  }

  void _nextLevel() {
    final gameState = context.read<GameState>();
    if (widget.level.number < 100) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            level: gameState.getLevel(widget.level.number + 1),
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gameState = context.watch<GameState>();
    
    return Scaffold(
      backgroundColor: AppTheme.bgDarkest,
      body: Transform.translate(
        offset: Offset(_shakeOffset, 0),
        child: Container(
          decoration: BoxDecoration(
            gradient: _isBossLevel 
                ? AppTheme.bossGradient
                : AppTheme.bgGradient,
          ),
          child: Stack(
            children: [
              if (_phase != GamePhase.result)
                SafeArea(
                  child: Column(
                    children: [
                      // Header
                      _buildHeader(gameState),
                      
                      const Spacer(),
                      
                      // Target Display (Cleaner)
                      _buildTargetDisplay(),
                      
                      const SizedBox(height: 32),
                      
                      // Game Area
                      _buildGameArea(size),
                      
                      const SizedBox(height: 32),
                      
                      // Percentage Display
                      _buildFillDisplay(),
                      
                      const Spacer(),
                      
                      // Instructions
                      if (_phase == GamePhase.ready) _buildInstructions(),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              
              // Result overlay
              if (_phase == GamePhase.result)
                ResultOverlay(
                  level: widget.level,
                  actualPercentage: _currentFillPercentage,
                  onRetry: _retry,
                  onNextLevel: _nextLevel,
                  onHome: () => Navigator.pop(context),
                  animationController: _resultController,
                ),
              
              // Achievement popup
              if (gameState.pendingAchievement != null)
                AchievementPopup(
                  achievement: gameState.pendingAchievement!,
                  onDismiss: () => gameState.clearPendingAchievement(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(GameState gameState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: AppTheme.glassCard.copyWith(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 20),
            ),
          ),
          
          const Spacer(),
          
          // Level Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: AppTheme.glassCard.copyWith(borderRadius: BorderRadius.circular(100)),
            child: Row(
              children: [
                Text(widget.level.liquidType.emoji),
                const SizedBox(width: 8),
                Text(
                  'Level ${widget.level.number}',
                  style: AppTheme.textTheme.labelLarge,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Timer (if exists)
          if (widget.level.hasTimeLimit)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (_remainingSeconds <= 3 ? AppTheme.accentError : AppTheme.bgSurface)
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: _remainingSeconds <= 3 ? AppTheme.accentError : Colors.transparent
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, 
                    size: 16, 
                    color: _remainingSeconds <= 3 ? Colors.white : AppTheme.textSecondary
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_remainingSeconds}s',
                    style: AppTheme.textTheme.labelLarge!.copyWith(
                      color: _remainingSeconds <= 3 ? Colors.white : AppTheme.textPrimary
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTargetDisplay() {
    return Column(
      children: [
        Text(
          'TARGET',
          style: AppTheme.textTheme.labelLarge!.copyWith(
            color: AppTheme.textSecondary, 
            letterSpacing: 2
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${widget.level.targetPercentage.toStringAsFixed(0)}',
              style: AppTheme.textTheme.displayLarge!.copyWith(
                color: AppTheme.accentWarning,
                fontSize: 56,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '%',
                style: AppTheme.textTheme.headlineMedium!.copyWith(
                  color: AppTheme.accentWarning.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '±${widget.level.marginOfError.toStringAsFixed(1)}% margin',
            style: AppTheme.textTheme.bodyMedium!.copyWith(fontSize: 12),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildGameArea(Size size) {
    return GestureDetector(
      onTapDown: (_) => _phase == GamePhase.ready ? _startPouring() : null,
      onTapUp: (_) => _phase == GamePhase.pouring ? _stopPouring() : null,
      onTapCancel: () => _phase == GamePhase.pouring ? _stopPouring() : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: size.width * 0.5,
            height: size.height * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.level.liquidType.color.withValues(alpha: 0.15),
                  blurRadius: 100,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
          
          LiquidContainer(
            width: size.width * 0.6,
            height: size.height * 0.38,
            fillPercentage: _currentFillPercentage,
            targetPercentage: widget.level.targetPercentage,
            liquidType: widget.level.liquidType,
            showTarget: _phase != GamePhase.result,
            marginOfError: widget.level.marginOfError,
          ),
        ],
      ),
    );
  }

  Widget _buildFillDisplay() {
    final diff = _currentFillPercentage - widget.level.targetPercentage;
    final isClose = diff.abs() <= widget.level.marginOfError;
    final isPerfect = diff.abs() <= widget.level.marginOfError * 0.3;
    
    Color color = AppTheme.textSecondary;
    if (_currentFillPercentage > 0) {
      color = isPerfect ? AppTheme.accentSuccess 
           : isClose ? AppTheme.accentWarning 
           : widget.level.liquidType.color;
    }

    return Column(
      children: [
        Text(
          '${_currentFillPercentage.toStringAsFixed(1)}%',
          style: AppTheme.textTheme.displayMedium!.copyWith(color: color),
        ),
        if (_phase == GamePhase.stopped || _phase == GamePhase.result)
          Text(
            diff.abs() < 0.1 ? 'PERFECT' 
                : diff > 0 ? '+${diff.toStringAsFixed(1)}% over'
                : '${diff.abs().toStringAsFixed(1)}% under',
            style: AppTheme.textTheme.labelLarge!.copyWith(color: color),
          ).animate().fadeIn().scale(),
      ],
    );
  }

  Widget _buildInstructions() {
    return Text(
      'HOLD TO POUR',
      style: AppTheme.textTheme.labelLarge!.copyWith(
        color: AppTheme.accentSecondary,
        letterSpacing: 3,
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .fadeIn()
     .shimmer(duration: 2.seconds);
  }
}
