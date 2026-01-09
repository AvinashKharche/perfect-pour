import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_pour/utils/app_theme.dart';

class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Gradient? gradient;
  final double? width;

  const GlassButton({
    super.key,
    required this.child,
    required this.onTap,
    this.gradient,
    this.width,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: widget.width,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: widget.gradient,
                color: widget.gradient == null ? AppTheme.glassWhite : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.gradient != null
                      ? Colors.transparent
                      : AppTheme.glassBorder,
                  width: 1,
                ),
                boxShadow: widget.gradient != null
                    ? [
                        BoxShadow(
                          color: AppTheme.neonCyan.withValues(alpha: _isPressed ? 0.4 : 0.2),
                          blurRadius: _isPressed ? 20 : 10,
                          spreadRadius: _isPressed ? 2 : 0,
                        ),
                      ]
                    : null,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
