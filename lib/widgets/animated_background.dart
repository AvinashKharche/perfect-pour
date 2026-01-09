import 'dart:math';
import 'package:flutter/material.dart';
import 'package:perfect_pour/utils/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingOrb> _orbs = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Generate subtle floating orbs
    for (int i = 0; i < 8; i++) {
      _orbs.add(_FloatingOrb(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 100 + 50,
        speed: _random.nextDouble() * 0.2 + 0.05,
        opacity: _random.nextDouble() * 0.06 + 0.02,
        color: [AppTheme.neonCyan, AppTheme.neonPurple, AppTheme.neonGold][i % 3],
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(
            orbs: _orbs,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _FloatingOrb {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final Color color;

  _FloatingOrb({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

class _BackgroundPainter extends CustomPainter {
  final List<_FloatingOrb> orbs;
  final double animationValue;

  _BackgroundPainter({
    required this.orbs,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final orb in orbs) {
      // Calculate animated position with smooth floating
      final yOffset = (orb.y + animationValue * orb.speed) % 1.3 - 0.15;
      final xWobble = sin((animationValue + orb.x) * 2 * pi) * 0.03;

      final center = Offset(
        (orb.x + xWobble) * size.width,
        yOffset * size.height,
      );

      // Draw soft glow
      final glowPaint = Paint()
        ..color = orb.color.withValues(alpha: orb.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, orb.size * 0.5);
      
      canvas.drawCircle(center, orb.size, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
