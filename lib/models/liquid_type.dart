import 'package:flutter/material.dart';

enum LiquidType {
  water,
  honey,
  oil,
  lava,
}

extension LiquidTypeExtension on LiquidType {
  String get name {
    switch (this) {
      case LiquidType.water:
        return 'Water';
      case LiquidType.honey:
        return 'Honey';
      case LiquidType.oil:
        return 'Oil';
      case LiquidType.lava:
        return 'Lava';
    }
  }

  String get emoji {
    switch (this) {
      case LiquidType.water:
        return '💧';
      case LiquidType.honey:
        return '🍯';
      case LiquidType.oil:
        return '🛢️';
      case LiquidType.lava:
        return '🌋';
    }
  }

  Color get color {
    switch (this) {
      case LiquidType.water:
        return const Color(0xFF4CC9F0); // Neon Cyan
      case LiquidType.honey:
        return const Color(0xFFFFB703); // Golden Yellow
      case LiquidType.oil:
        return const Color(0xFF8338EC); // Deep Purple
      case LiquidType.lava:
        return const Color(0xFFFF4D6D); // Neon Red/Pink
    }
  }

  Color get darkColor {
    switch (this) {
      case LiquidType.water:
        return const Color(0xFF480CA8);
      case LiquidType.honey:
        return const Color(0xFFFB8500);
      case LiquidType.oil:
        return const Color(0xFF3A0CA3);
      case LiquidType.lava:
        return const Color(0xFFC9184A);
    }
  }

  /// Pour speed multiplier (1.0 = normal, lower = slower)
  double get pourSpeed {
    switch (this) {
      case LiquidType.water:
        return 1.0;
      case LiquidType.honey:
        return 0.4; // Honey is slow!
      case LiquidType.oil:
        return 0.7;
      case LiquidType.lava:
        return 0.5;
    }
  }

  /// Viscosity affects animation wobble
  double get viscosity {
    switch (this) {
      case LiquidType.water:
        return 0.3;
      case LiquidType.honey:
        return 0.8;
      case LiquidType.oil:
        return 0.6;
      case LiquidType.lava:
        return 0.9;
    }
  }
}
