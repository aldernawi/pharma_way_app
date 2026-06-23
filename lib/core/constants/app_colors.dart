import 'package:flutter/material.dart';

class AppColors {
  // ─── Brand Palette ───
  static const Color primary = Color(0xFF1F66A6);
  static const Color secondary = Color(0xFFF06A1A); // Accent / CTA

  // Shades of Primary
  static const Color primaryLight = Color(0xFF4A8AC4);
  static const Color primaryDark = Color(0xFF154A7A);
  static const Color primaryLighter = Color(0xFFE8F1FA);

  // Shades of Secondary
  static const Color secondaryLight = Color(0xFFF4924F);
  static const Color secondaryDark = Color(0xFFCC5510);
  static const Color secondaryLighter = Color(0xFFFEF0E6);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  // Status Colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Order Status Colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusApproved = Color(0xFF16A34A);
  static const Color statusRejected = Color(0xFFDC2626);
  static const Color statusProcessing = Color(0xFF2563EB);
  static const Color statusShipped = Color(0xFF7C3AED);
  static const Color statusDelivered = Color(0xFF16A34A);
  static const Color statusCompleted = Color(0xFF0D9488);
  static const Color statusCancelled = Color(0xFF6B7280);

  // Border & Divider
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Overlay & Shadow
  static const Color overlay = Color(0x80000000);
  static const Color shadow = Color(0x14000000);

  // ─── Spacing constants ───
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  // ─── Gradients ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1F66A6), Color(0xFF4A8AC4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
