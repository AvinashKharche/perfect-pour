import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:perfect_pour/models/liquid_type.dart';

class PouringStream extends StatefulWidget {
  final LiquidType liquidType;
  final double width;
  final double height;

  const PouringStream({
    super.key,
    required this.liquidType,
    required this.width,
    required this.height,
  });

  @override
  State<PouringStream> createState() => _PouringStreamState();
}

class _PouringStreamState extends State<PouringStream>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _StreamPainter(
              color: widget.liquidType.color,
              darkColor: widget.liquidType.darkColor,
              phase: _controller.value,
              viscosity: widget.liquidType.viscosity,
            ),
          );
        },
      ),
    );
  }
}

class _StreamPainter extends CustomPainter {
  final Color color;
  final Color darkColor;
  final double phase;
  final double viscosity;

  _StreamPainter({
    required this.color,
    required this.darkColor,
    required this.phase,
    required this.viscosity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final streamWidth = size.width * 0.5;
    
    // Main stream
    final streamPath = Path();
    streamPath.moveTo(centerX - streamWidth / 2, 0);
    
    for (double y = 0; y <= size.height; y += 3) {
      final wobble = math.sin((y / size.height * 4 * math.pi) + (phase * math.pi * 2)) 
          * (1.5 * (1 - viscosity * 0.5));
      final widthVar = streamWidth * (1 + math.sin(y / size.height * math.pi) * 0.15);
      streamPath.lineTo(centerX - widthVar / 2 + wobble, y);
    }
    
    for (double y = size.height; y >= 0; y -= 3) {
      final wobble = math.sin((y / size.height * 4 * math.pi) + (phase * math.pi * 2)) 
          * (1.5 * (1 - viscosity * 0.5));
      final widthVar = streamWidth * (1 + math.sin(y / size.height * math.pi) * 0.15);
      streamPath.lineTo(centerX + widthVar / 2 + wobble, y);
    }
    
    streamPath.close();

    // Gradient fill
    final streamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [darkColor, color, color, darkColor],
        stops: const [0, 0.35, 0.65, 1],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(streamPath, streamPaint);

    // Center highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final highlightPath = Path();
    highlightPath.moveTo(centerX, 0);
    for (double y = 0; y <= size.height; y += 3) {
      final wobble = math.sin((y / size.height * 4 * math.pi) + (phase * math.pi * 2)) 
          * (0.8 * (1 - viscosity * 0.5));
      highlightPath.lineTo(centerX + wobble, y);
    }
    canvas.drawPath(highlightPath, highlightPaint);

    // Small droplets
    _drawDroplets(canvas, size, centerX);
  }

  void _drawDroplets(Canvas canvas, Size size, double centerX) {
    final dropletPaint = Paint()..color = color.withValues(alpha: 0.7);
    final random = math.Random((phase * 100).toInt());
    
    for (int i = 0; i < 3; i++) {
      final x = centerX + (random.nextDouble() - 0.5) * size.width * 0.6;
      final y = ((phase + i * 0.33) % 1) * size.height;
      final radius = random.nextDouble() * 2 + 1.5;
      
      canvas.drawCircle(Offset(x, y), radius, dropletPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StreamPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
