import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AromaColors {
  // Brand Colors (Deep, rich, and vibrant)
  static const Color coffeePrimary = Color(0xFF5D4037); // Richer Espresso
  static const Color coffeeSecondary = Color(0xFFD7CCC8); // Warmer Latte
  static const Color coffeeAccent = Color(0xFFF57C00); // Vibrant Orange for CTAs
  
  // Backgrounds & Surfaces (Clean and minimal)
  static const Color coffeeBackground = Color(0xFFFDFBF7); // Off-white cream
  static const Color coffeeSurface = Color(0xFFFFFFFF);
  static const Color coffeeCardLightBg = Color(0xFFF8F5F2);
  static const Color coffeeCardBorder = Color(0xFFEFEBE9);
  
  // Typography Colors (High contrast)
  static const Color coffeeTextDark = Color(0xFF2E221E);
  static const Color coffeeTextSub = Color(0xFF8D6E63);
  static const Color coffeeGold = Color(0xFFFFB300); // More vibrant gold
  
  // Semantic / Status Colors
  static const Color successGreen = Color(0xFF10B981); // Modern emerald
  static const Color preparingBlue = Color(0xFF3B82F6); // Modern vibrant blue
  static const Color pendingOrange = Color(0xFFF59E0B); // Modern amber
  static const Color errorRed = Color(0xFFEF4444); // Modern red
}

class AromaTypography {
  static TextStyle get h1 => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AromaColors.coffeeTextDark,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AromaColors.coffeeTextDark,
        letterSpacing: -0.3,
      );

  static TextStyle get h3 => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AromaColors.coffeeTextDark,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AromaColors.coffeeTextDark,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AromaColors.coffeeTextDark,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AromaColors.coffeeTextSub,
      );

  static TextStyle get buttonText => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );
}

class AromaStyles {
  // Border Radii
  static final BorderRadius radiusSmall = BorderRadius.circular(8);
  static final BorderRadius radiusMedium = BorderRadius.circular(16);
  static final BorderRadius radiusLarge = BorderRadius.circular(24);
  static final BorderRadius radiusPill = BorderRadius.circular(999);

  // Shadows
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: AromaColors.coffeeTextDark.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: AromaColors.coffeeTextDark.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> glowShadow = [
    BoxShadow(
      color: AromaColors.coffeeAccent.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Role khớp DB: 1 = Admin, 2 = Staff
/// Customer không nằm trong bảng Accounts, đây là luồng riêng qua QR scan
enum UserRole {
  admin,
  staff,
  customer, // Chỉ dùng cho luồng customer QR, không lưu DB
}

class SepayConfig {
  static const String bankId = String.fromEnvironment('SEPAY_BANK_ID', defaultValue: "TPB"); // Ngân hàng TPBank
  static const String accountNumber = String.fromEnvironment('SEPAY_ACCOUNT_NUMBER', defaultValue: "07738020201"); // Số tài khoản ngân hàng của bạn
  static const String accountName = String.fromEnvironment('SEPAY_ACCOUNT_NAME', defaultValue: "NGUYEN DANG KHOA"); // Họ và tên viết hoa không dấu
}
