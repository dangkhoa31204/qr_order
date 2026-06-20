import 'package:flutter/material.dart';

class AromaColors {
  static const Color coffeePrimary = Color(0xFF6F4E37);
  static const Color coffeeSecondary = Color(0xFFF5EBE6);
  static const Color coffeeBackground = Color(0xFFFAF7F5);
  static const Color coffeeTextDark = Color(0xFF33221A);
  static const Color coffeeTextSub = Color(0xFF8B7365);
  static const Color coffeeGold = Color(0xFFD4AF37);
  static const Color coffeeCardBorder = Color(0xFFE6DFD9);
  static const Color coffeeCardLightBg = Color(0xFFFAFAF9);
  
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color preparingBlue = Color(0xFF1E88E5);
  static const Color pendingOrange = Color(0xFFEF8C2E);
}

/// Role khớp DB: 1 = Admin, 2 = Staff
/// Customer không nằm trong bảng Accounts, đây là luồng riêng qua QR scan
enum UserRole {
  admin,
  staff,
  customer, // Chỉ dùng cho luồng customer QR, không lưu DB
}

class SepayConfig {
  static const String bankId = "MB"; // Ví dụ: MB, VCB, ACB, VietinBank...
  static const String accountNumber = "123456789"; // Số tài khoản ngân hàng của bạn
  static const String accountName = "NGUYEN VAN A"; // Họ và tên viết hoa không dấu
}
