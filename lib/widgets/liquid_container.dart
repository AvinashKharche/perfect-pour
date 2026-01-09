import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:perfect_pour/models/liquid_type.dart';
import 'package:perfect_pour/utils/app_theme.dart';

class LiquidContainer extends StatefulWidget {
  final double width;
  final double height;
  final double fillPercentage;
  final double targetPercentage;
  final LiquidType liquidType;
  final bool showTarget;
  final double marginOfError;

  const LiquidContainer({
    super.key,
    required this.width,
    required this.height,
    required this.fillPercentage,
    required this.targetPercentage,
    required this.liquidType,
    this.showTarget = true,
    required this.marginOfError,
  });

  @override
  State<LiquidContainer> createState() => _LiquidContainerState();
}

class _LiquidContainerState extends State<LiquidContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            painter: _ContainerPainter(
              fillPercentage: widget.fillPercentage,
              targetPercentage: widget.targetPercentage,
              liquidColor: widget.liquidType.color,
              liquidDarkColor: widget.liquidType.darkColor,
              wavePhase: _waveController.value,
              viscosity: widget.liquidType.viscosity,
              showTarget: widget.showTarget,
              marginOfError: widget.marginOfError,
            ),
          );
        },
      ),
    );
  }
}

class _ContainerPainter extends CustomPainter {
  final double fillPercentage;
  final double targetPercentage;
  final Color liquidColor;
  final Color liquidDarkColor;
  final double wavePhase;
  final double viscosity;
  final bool showTarget;
  final double marginOfError;

  _ContainerPainter({
    required this.fillPercentage,
    required this.targetPercentage,
    required this.liquidColor,
    required this.liquidDarkColor,
    required this.wavePhase,
    required this.viscosity,
    required this.showTarget,
    required this.marginOfError,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20),
    );

    // Draw container background with subtle inner shadow
    _drawContainer(canvas, size, rect);

    // Clip to container
    canvas.save();
    canvas.clipRRect(rect);

    // Draw liquid
    if (fillPercentage > 0) {
      _drawLiquid(canvas, size);
    }

    // Draw target zone
    if (showTarget) {
      _drawTargetZone(canvas, size);
    }

    canvas.restore();

    // Draw container border with glow
    _drawContainerBorder(canvas, rect);
    
    // Draw measurement marks
    _drawMeasurementMarks(canvas, size);
  }

  void _drawContainer(Canvas canvas, Size size, RRect rect) {
    // Background
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.03),
        ],
      ).createShader(rect.outerRect);
    canvas.drawRRect(rect, bgPaint);

    // Inner shadow at top
    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.2));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.width - 8, size.height * 0.2),
        const Radius.circular(16),
      ),
      shadowPaint,
    );
  }

  void _drawLiquid(Canvas canvas, Size size) {
    final fillHeight = (fillPercentage / 100) * size.height;
    final liquidTop = size.height - fillHeight;

    // Wave path
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, liquidTop);

    final waveAmp = 5.0 * (1 - viscosity * 0.6);
    final waveFreq = 2.5;

    for (double x = 0; x <= size.width; x += 2) {
      final waveY = liquidTop +
          math.sin((x / size.width * waveFreq * math.pi * 2) + (wavePhase * math.pi * 2)) * waveAmp;
      path.lineTo(x, waveY);
    }

    path.lineTo(size.width, size.height);
    path.close();

    // Liquid gradient
    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          liquidColor.withValues(alpha: 0.85),
          liquidDarkColor,
        ],
      ).createShader(Rect.fromLTWH(0, liquidTop, size.width, fillHeight));

    canvas.drawPath(path, liquidPaint);

    // Surface highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final highlightPath = Path();
    highlightPath.moveTo(10, liquidTop);
    for (double x = 10; x <= size.width - 10; x += 2) {
      final waveY = liquidTop +
          math.sin((x / size.width * waveFreq * math.pi * 2) + (wavePhase * math.pi * 2)) * waveAmp;
      highlightPath.lineTo(x, waveY);
    }
    canvas.drawPath(highlightPath, highlightPaint);

    // Subtle bubbles
    _drawBubbles(canvas, size, liquidTop, fillHeight);
  }

  void _drawBubbles(Canvas canvas, Size size, double liquidTop, double fillHeight) {
    if (fillHeight < 30) return;

    final random = math.Random(42);
    final bubblePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final x = random.nextDouble() * (size.width - 20) + 10;
      final baseY = liquidTop + random.nextDouble() * (fillHeight - 20) + 10;
      final y = baseY - (wavePhase * 15) % fillHeight;

      if (y > liquidTop + 5 && y < size.height - 10) {
        final radius = random.nextDouble() * 3 + 1.5;
        canvas.drawCircle(Offset(x, y), radius, bubblePaint);
      }
    }
  }

  void _drawTargetZone(Canvas canvas, Size size) {
    final targetY = size.height - (targetPercentage / 100) * size.height;
    final marginHeight = (marginOfError / 100) * size.height;

    // Target zone background
    final zonePaint = Paint()
      ..color = AppTheme.accentWarning.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, targetY - marginHeight, size.width, marginHeight * 2),
      zonePaint,
    );

    // Target line (dashed)
    final linePaint = Paint()
      ..color = AppTheme.accentWarning.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dashWidth = 8.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, targetY),
        Offset(math.min(startX + dashWidth, size.width), targetY),
        linePaint,
      );
      startX += dashWidth + dashSpace;
    }

    // Target label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${targetPercentage.toStringAsFixed(0)}%',
        style: const TextStyle(
          color: AppTheme.accentWarning,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Label background
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width - textPainter.width - 14,
        targetY - textPainter.height / 2 - 4,
        textPainter.width + 10,
        textPainter.height + 8,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(labelRect, Paint()..color = AppTheme.bgSurface.withValues(alpha: 0.9));
    canvas.drawRRect(
      labelRect,
      Paint()
        ..color = AppTheme.accentWarning.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    textPainter.paint(
      canvas,
      Offset(size.width - textPainter.width - 9, targetY - textPainter.height / 2),
    );
  }

  void _drawContainerBorder(Canvas canvas, RRect rect) {
    // Subtle outer glow (only on sides and bottom, not top)
    if (fillPercentage > 0) {
      final glowPath = Path();
      // Only add glow to bottom half to avoid line at top
      glowPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rect.left - 5,
          rect.top + rect.height * 0.3,
          rect.width + 10,
          rect.height * 0.7 + 5,
        ),
        const Radius.circular(20),
      ));
      
      final glowPaint = Paint()
        ..color = liquidColor.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 12);
      canvas.drawPath(glowPath, glowPaint);
    }

    // Border gradient - more subtle
    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.1),  // Very subtle at top
          Colors.white.withValues(alpha: 0.25), // Slightly more visible at bottom
        ],
      ).createShader(rect.outerRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rect, borderPaint);

    // Left edge shine
    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, 15, rect.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 3, 12, rect.height - 6),
        const Radius.circular(17),
      ),
      shinePaint,
    );
  }

  void _drawMeasurementMarks(Canvas canvas, Size size) {
    final markPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 25; i < 100; i += 25) {
      final y = size.height - (i / 100) * size.height;
      canvas.drawLine(
        Offset(size.width - 10, y),
        Offset(size.width - 4, y),
        markPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ContainerPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.targetPercentage != targetPercentage;
  }
}
