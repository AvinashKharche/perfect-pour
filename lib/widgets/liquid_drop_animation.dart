import 'package:flutter/material.dart';
import 'package:perfect_pour/utils/app_theme.dart';

class LiquidDropAnimation extends StatefulWidget {
  const LiquidDropAnimation({super.key});

  @override
  State<LiquidDropAnimation> createState() => _LiquidDropAnimationState();
}

class _LiquidDropAnimationState extends State<LiquidDropAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dropAnimation;
  late Animation<double> _splashAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _dropAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.4, curve: Curves.easeIn),
      ),
    );

    _splashAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.5, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 150,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: DropPainter(
              dropProgress: _dropAnimation.value,
              splashProgress: _splashAnimation.value,
              scaleProgress: _scaleAnimation.value,
            ),
          );
        },
      ),
    );
  }
}

class DropPainter extends CustomPainter {
  final double dropProgress;
  final double splashProgress;
  final double scaleProgress;

  DropPainter({
    required this.dropProgress,
    required this.splashProgress,
    required this.scaleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final containerTop = size.height * 0.4;
    
    // Draw container (glass)
    _drawContainer(canvas, size, centerX, containerTop);
    
    // Draw falling drop
    if (dropProgress < 1) {
      _drawDrop(canvas, size, centerX, containerTop);
    }
    
    // Draw splash effect
    if (splashProgress > 0 && splashProgress < 1) {
      _drawSplash(canvas, size, centerX, containerTop);
    }
    
    // Draw liquid level in container
    _drawLiquid(canvas, size, centerX, containerTop);
  }

  void _drawContainer(Canvas canvas, Size size, double centerX, double containerTop) {
    final containerWidth = size.width * 0.6;
    final containerHeight = size.height * 0.55;
    
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX - containerWidth / 2,
        containerTop,
        containerWidth,
        containerHeight,
      ),
      const Radius.circular(8),
    );
    
    // Glass effect
    final glassPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, glassPaint);
    
    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rect, borderPaint);
    
    // Shine
    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(rect.outerRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - containerWidth / 2 + 4,
          containerTop + 4,
          containerWidth * 0.3,
          containerHeight - 8,
        ),
        const Radius.circular(4),
      ),
      shinePaint,
    );
  }

  void _drawDrop(Canvas canvas, Size size, double centerX, double containerTop) {
    final dropY = dropProgress * containerTop;
    final dropSize = 12.0 * scaleProgress;
    
    final dropPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.waterColor,
          AppTheme.waterColorDark,
        ],
      ).createShader(Rect.fromCircle(center: Offset(centerX, dropY), radius: dropSize));
    
    // Draw teardrop shape
    final path = Path();
    path.moveTo(centerX, dropY - dropSize);
    path.quadraticBezierTo(
      centerX + dropSize,
      dropY,
      centerX,
      dropY + dropSize * 1.2,
    );
    path.quadraticBezierTo(
      centerX - dropSize,
      dropY,
      centerX,
      dropY - dropSize,
    );
    
    canvas.drawPath(path, dropPaint);
    
    // Glow
    final glowPaint = Paint()
      ..color = AppTheme.waterColor.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(centerX, dropY), dropSize * 0.8, glowPaint);
  }

  void _drawSplash(Canvas canvas, Size size, double centerX, double containerTop) {
    final splashY = containerTop + 10;
    final splashRadius = splashProgress * 20;
    
    final splashPaint = Paint()
      ..color = AppTheme.waterColor.withValues(alpha: (1 - splashProgress) * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(Offset(centerX, splashY), splashRadius, splashPaint);
    
    // Small droplets
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * 3.14159 - 3.14159 / 2;
      final dx = centerX + splashRadius * 0.8 * cos(angle);
      final dy = splashY + splashRadius * 0.5 * sin(angle) - splashProgress * 10;
      
      final dropletPaint = Paint()
        ..color = AppTheme.waterColor.withValues(alpha: (1 - splashProgress) * 0.6);
      canvas.drawCircle(Offset(dx, dy), 3 * (1 - splashProgress), dropletPaint);
    }
  }

  void _drawLiquid(Canvas canvas, Size size, double centerX, double containerTop) {
    final containerWidth = size.width * 0.6;
    final containerHeight = size.height * 0.55;
    
    // Liquid fill (animated based on splash)
    final fillHeight = containerHeight * 0.3 + (splashProgress > 0 ? splashProgress * 5 : 0);
    
    final liquidRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        centerX - containerWidth / 2 + 2,
        containerTop + containerHeight - fillHeight,
        containerWidth - 4,
        fillHeight - 2,
      ),
      bottomLeft: const Radius.circular(6),
      bottomRight: const Radius.circular(6),
    );
    
    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.waterColor.withValues(alpha: 0.8),
          AppTheme.waterColorDark,
        ],
      ).createShader(liquidRect.outerRect);
    
    canvas.drawRRect(liquidRect, liquidPaint);
    
    // Surface wave
    final wavePaint = Paint()
      ..color = AppTheme.waterColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawLine(
      Offset(centerX - containerWidth / 2 + 4, containerTop + containerHeight - fillHeight),
      Offset(centerX + containerWidth / 2 - 4, containerTop + containerHeight - fillHeight),
      wavePaint,
    );
  }

  double cos(double x) => cosDegrees(x * 180 / 3.14159);
  double sin(double x) => sinDegrees(x * 180 / 3.14159);
  
  double cosDegrees(double degrees) {
    return cosRadians(degrees * 3.14159 / 180);
  }
  
  double sinDegrees(double degrees) {
    return sinRadians(degrees * 3.14159 / 180);
  }
  
  double cosRadians(double radians) {
    // Taylor series approximation
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 10; i++) {
      term *= -radians * radians / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }
  
  double sinRadians(double radians) {
    // Taylor series approximation
    double result = radians;
    double term = radians;
    for (int i = 1; i <= 10; i++) {
      term *= -radians * radians / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant DropPainter oldDelegate) {
    return oldDelegate.dropProgress != dropProgress ||
        oldDelegate.splashProgress != splashProgress;
  }
}
