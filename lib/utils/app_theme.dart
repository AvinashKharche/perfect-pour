import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- New "Deep Space & Glass" Palette ---
  
  // Backgrounds
  static const Color bgDarkest = Color(0xFF0F0E17); // Almost black purple
  static const Color bgDark = Color(0xFF161629);    // Deep slightly purple blue
  static const Color bgSurface = Color(0xFF24243E); // Lighter surface
  
  // Accents
  static const Color accentPrimary = Color(0xFFFF4D6D); // Electric Coral (Primary action)
  static const Color accentSecondary = Color(0xFF4CC9F0); // Bright Cyan (Secondary info)
  static const Color accentTertiary = Color(0xFF7209B7); // Vivid Purple (Special/Boss)
  static const Color accentSuccess = Color(0xFF06D6A0); // Mint Green
  static const Color accentWarning = Color(0xFFFFD166); // Warm Amber
  static const Color accentError = Color(0xFFEF476F);   // Hot Pink/Red
  
  // Text
  static const Color textPrimary = Color(0xFFFFFFFE);
  static const Color textSecondary = Color(0xFF94A1B2);
  static const Color textTertiary = Color(0xFF6B7280);

  // --- Gradients ---
  
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F0E17),
      Color(0xFF1A1A2E),
    ],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x26FFFFFF), // White 15%
      Color(0x0DFFFFFF), // White 5%
    ],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF4D6D), Color(0xFFFF8E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF4CC9F0), Color(0xFF4361EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bossGradient = LinearGradient(
    colors: [Color(0xFF7209B7), Color(0xFF3A0CA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Decorations ---

  static BoxDecoration glassCard = BoxDecoration(
    gradient: glassGradient,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 10),
      ),
    ],
  );

  // --- Typography (Google Fonts) ---
  
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 48,
      fontWeight: FontWeight.w800,
      color: textPrimary,
      height: 1.1,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      height: 1.2,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      height: 1.2,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: textSecondary,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textSecondary,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: 1.0,
    ),
  );

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDarkest,
      primaryColor: accentPrimary,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: accentSecondary,
        surface: bgSurface,
        error: accentError,
        onSurface: textPrimary,
      ),
    );
  }
}
