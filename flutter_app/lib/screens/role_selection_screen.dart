import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/item_model.dart';

class RoleSelectionScreen extends StatelessWidget {
  final Function(UserRole) onRoleSelected;

  const RoleSelectionScreen({super.key, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AromaColors.coffeeBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AromaColors.coffeePrimary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AromaColors.coffeePrimary.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                alignment: Alignment.Center,
                child: const Text(
                  "☕",
                  style: TextStyle(fontSize: 48),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header
              const Text(
                "AROMA BISTRO",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AromaColors.coffeePrimary,
                  fontFamily: 'Serif',
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Hệ thống Gọi món QR Code & Quản lý Realtime",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AromaColors.coffeeTextSub,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // Mode Divider
              const Text(
                "VUI LÒNG CHỌN VAI TRÒ TRUY CẬP",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AromaColors.coffeeGold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 18),

              // Customer Mode Entry Card
              Card(
                color: Colors.white,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AromaColors.coffeeCardBorder),
                ),
                elevation: 2,
                child: InkWell(
                  onTap: () => onRoleSelected(UserRole.customer),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AromaColors.coffeeSecondary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.Center,
                          child: const Text("🍽️", style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Khách Hàng",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AromaColors.coffeeTextDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AromaColors.coffeePrimary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "QUÉT QR",
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: AromaColors.coffeePrimary,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Quét mã QR tại bàn để xem menu thực đơn & thực hiện gọi món trực tiếp mà không cần cài đặt phức tạp.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AromaColors.coffeeTextSub,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Staff Mode Entry Card
              Card(
                color: AromaColors.coffeeDarkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: InkWell(
                  onTap: () => onRoleSelected(UserRole.staff),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.Center,
                          child: const Text("💼", style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Bếp / Nhân Viên",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AromaColors.coffeeGold,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "QUẢN LÝ",
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: AromaColors.coffeeDarkAccent,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Nhận order tức thời, chế biến món ăn, cập nhật sơ đồ phòng bàn & kết xuất báo cáo bán hàng.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Framework visualizer card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AromaColors.coffeeSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AromaColors.coffeeCardBorder.withOpacity(0.5),
                  ),
                ),
                child: const Column(
                  children: [
                    Text(
                      "💻 KIẾN TRÚC HỆ THỐNG PHÁT TRIỂN",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AromaColors.coffeePrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "ASP.NET Core Web API • Entity Framework • SQLite\nHệ thống đồng bộ SignalR truyền tải trạng thái chế biến",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: AromaColors.coffeeTextSub,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
