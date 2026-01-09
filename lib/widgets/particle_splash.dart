import 'dart:math' as math;
import 'package:flutter/material.dart';

class ParticleSplash extends StatefulWidget {
  final Color color;
  final Offset position;
  final VoidCallback? onComplete;

  const ParticleSplash({
    super.key,
    required this.color,
    required this.position,
    this.onComplete,
  });

  @override
  State<ParticleSplash> createState() => _ParticleSplashState();
}

class _ParticleSplashState extends State<ParticleSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Generate particles
    _particles = List.generate(12, (i) {
      final angle = (i / 12) * 2 * math.pi + _random.nextDouble() * 0.5;
      final speed = 50 + _random.nextDouble() * 100;
      return Particle(
        angle: angle,
        speed: speed,
        size: 4 + _random.nextDouble() * 6,
        color: widget.color.withValues(alpha: 0.6 + _random.nextDouble() * 0.4),
      );
    });

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
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
          painter: SplashPainter(
            particles: _particles,
            progress: _controller.value,
            center: widget.position,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class SplashPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Offset center;

  SplashPainter({
    required this.particles,
    required this.progress,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final distance = particle.speed * progress;
      final gravity = 50 * progress * progress; // Gravity effect
      
      final x = center.dx + math.cos(particle.angle) * distance;
      final y = center.dy + math.sin(particle.angle) * distance + gravity;
      
      final opacity = (1 - progress).clamp(0.0, 1.0);
      final currentSize = particle.size * (1 - progress * 0.5);
      
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), currentSize, paint);
      
      // Glow effect
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), currentSize * 1.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SplashPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
