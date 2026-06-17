import 'package:flutter/material.dart';

class AppThemeData {
  // ── Spacing scale ──
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;

  // ── Border radius scale ──
  static const double radius8 = 8;
  static const double radius12 = 12;
  static const double radius16 = 16;
  static const double radius20 = 20;
  static const double radius24 = 24;

  // ── Elevation / shadow presets ──
  static List<BoxShadow> shadowSm(bool isDark) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> shadowMd(bool isDark) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> shadowLg(bool isDark) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // ── Desaturation filters for closed restaurants ──
  static const desatLight = ColorFilter.matrix(<double>[
    0.8032,
    0.1788,
    0.0181,
    0,
    0,
    0.0532,
    0.9288,
    0.0181,
    0,
    0,
    0.0532,
    0.1788,
    0.7681,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);
  static const desatMuted = ColorFilter.matrix(<double>[
    0.7244,
    0.2503,
    0.0253,
    0,
    0,
    0.0744,
    0.9003,
    0.0253,
    0,
    0,
    0.0744,
    0.2503,
    0.6753,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  // ── Card dimension constants ──
  static const double restaurantImageHeight = 200;
  static const double categoryIconSize = 85;
  static const double offerCardWidthPercent = 88;
  static const double featuredCardWidthPercent = 72;

  static const Color primary50 = Color(0xFFE5FBF0);
  static const Color primary100 = Color(0xFFB2F3D3);
  static const Color primary200 = Color(0xFF66E8A8);
  static Color primary300 = Color(0xFF00D96F); // Your base color #00d96f
  static const Color primary400 = Color(0xFF00974D);
  static const Color primary500 = Color(0xFF004B26);
  static const Color primary600 = Color(0xFF00150B);

  static const Color surface = Color(0xFFF9FAFB);
  static const Color surfaceDark = Color(0xFF030712);

  static const Color info50 = Color(0xFFE5F9FF);
  static const Color info100 = Color(0xFFACECFF);
  static const Color info200 = Color(0xFF72DEFF);
  static const Color info300 = Color(0xFF38D0FF);
  static const Color info400 = Color(0xFF2692B2);
  static const Color info500 = Color(0xFF135366);
  static const Color info600 = Color(0xFF00141A);

  static const Color danger50 = Color(0xFFFFE5E6);
  static const Color danger100 = Color(0xFFFFACAE);
  static const Color danger200 = Color(0xFFFF7277);
  static const Color danger300 = Color(0xFFFF3840);
  static const Color danger400 = Color(0xFFB2262B);
  static const Color danger500 = Color(0xFF661316);
  static const Color danger600 = Color(0xFF1A0001);

  static const Color cartBadge = Color(0xFFE11D48);
  static const Color cartBar = Color(0xFF047857);

  static const Color secondary50 = Color(0xFFEBE5FF);
  static const Color secondary100 = Color(0xFFC0ABFF);
  static const Color secondary200 = Color(0xFF9472FF);
  static const Color secondary300 = Color(0xFF6839FF);
  static const Color secondary400 = Color(0xFF4826B2);
  static const Color secondary500 = Color(0xFF271366);
  static const Color secondary600 = Color(0xFF06001A);

  static const Color success50 = Color(0xFFE5FFF5);
  static const Color success100 = Color(0xFFA1FFD9);
  static const Color success200 = Color(0xFF5DFFBE);
  static const Color success300 = Color(0xFF19FFA3);
  static const Color success400 = Color(0xFF10B271);
  static const Color success500 = Color(0xFF086640);
  static const Color success600 = Color(0xFF001A0F);
  static const Color lightGreen = Color(0XFFEFF9EB);
  static const Color darkGreen = Color(0XFF3F8826);

  static const Color warning50 = Color(0xFFFFF8E5);
  static const Color warning100 = Color(0xFFFFE9AB);
  static const Color warning200 = Color(0xFFFFDA72);
  static const Color warning300 = Color(0xFFFFCB39);
  static const Color warning400 = Color(0xFFB28D26);
  static const Color warning500 = Color(0xFF665013);
  static const Color warning600 = Color(0xFF191200);

  static const Color grey50 = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);
  static const Color outrageous300 = Color(0xFFFF6839);

  static const String fontFamily = 'Urbanist';
  static const String black = fontFamily;
  static const String bold = fontFamily;
  static const String extraBold = fontFamily;
  static const String extraLight = fontFamily;
  static const String light = fontFamily;
  static const String medium = fontFamily;
  static const String regular = fontFamily;
  static const String semiBold = fontFamily;
  static const String thin = fontFamily;
}
