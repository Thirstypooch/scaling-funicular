import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF1E40AF);
  static const Color primaryBlueDark = Color(0xFF1E3A8A);

  // Accent Colors
  static const Color accentGreen = Color(0xFF16A34A);
  static const Color accentGreenLight = Color(0xFF22C55E);

  // Grays
  static const Color backgroundGray = Color(0xFFF3F4F6);
  static const Color surfaceGray = Color(0xFFF9FAFB);
  static const Color textGray = Color(0xFF6B7280);
  static const Color textGrayDark = Color(0xFF374151);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color dividerGray = Color(0xFFD1D5DB);

  // Whites
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF9FAFB);

  // Location Pin
  static const Color pinOrange = Color(0xFFFB923C);
  static const Color pinBackground = Color(0xFFFEF3C7);

  // Text Styles
  static const TextStyle tabLabelSelected = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle tabLabelUnselected = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textGrayDark,
  );

  static const TextStyle searchHint = TextStyle(
    fontSize: 14,
    color: textGray,
  );

  static const TextStyle filterLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textGray,
  );

  static const TextStyle filterValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textGrayDark,
  );

  static const TextStyle summaryTitle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textGray,
  );

  static const TextStyle summaryValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textGrayDark,
  );

  static const TextStyle summarySubtitle = TextStyle(
    fontSize: 11,
    color: textGray,
  );

  static const TextStyle groupHeader = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textGray,
  );

  static const TextStyle itemTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: primaryBlue,
  );

  static const TextStyle itemSubtitle = TextStyle(
    fontSize: 12,
    color: textGray,
  );

  static const TextStyle metricLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textGrayDark,
  );

  static const TextStyle metricValue = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: textGrayDark,
  );

  static const TextStyle metricValueGreen = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: accentGreen,
  );

  static const TextStyle badgeText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: accentGreen,
  );

  static const TextStyle positionText = TextStyle(
    fontSize: 12,
    color: textGray,
  );

  static const TextStyle timestampText = TextStyle(
    fontSize: 11,
    color: textGray,
  );

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusPill = 30.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
