import 'package:flutter/material.dart';
import '../constants.dart';

class RoleSelectionScreen extends StatelessWidget {
  final Function(UserRole) onRoleSelected;
  final VoidCallback onConfigureApi;

  const RoleSelectionScreen({
    super.key,
    required this.onRoleSelected,
    required this.onConfigureApi,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AromaColors.coffeeBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top logo or icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AromaColors.coffeePrimary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AromaColors.coffeePrimary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "☕",
                    style: TextStyle(fontSize: 48),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  "AROMA BISTRO",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AromaColors.coffeePrimary,
                    fontFamily: 'Serif',
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Hệ thống Gọi món QR Code & Quản lý Realtime",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AromaColors.coffeeTextSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  "VUI LÒNG CHỌN VAI TRÒ TRUY CẬP",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AromaColors.coffeeGold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Customer Option Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0x286F4E37)),
                  ),
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onRoleSelected(UserRole.customer),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AromaColors.coffeeSecondary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
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
                                        fontSize: 16,
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
                                        color: AromaColors.coffeePrimary.withOpacity(0.15),
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
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Quét mã QR để xem menu thực đơn, gọi món trực tiếp về bếp & theo dõi tiến độ chuẩn bị.",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AromaColors.coffeeTextSub,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AromaColors.coffeeTextSub),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Staff Option Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: AromaColors.coffeeTextDark,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onRoleSelected(UserRole.staff),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
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
                                        fontSize: 16,
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
                                          color: AromaColors.coffeeTextDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Nhận order tức thời, chế biến, hoàn thành món, cập nhật sơ đồ bàn & quản lý menu món.",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.7),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // System Architecture Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AromaColors.coffeeSecondary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AromaColors.coffeeCardBorder.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "💻 KIẾN TRÚC HỆ THỐNG PHÁT TRIỂN",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AromaColors.coffeePrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "ASP.NET Core Web API • Entity Framework • SQLite\nHệ thống đồng bộ SignalR truyền tải trạng thái chế biến",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: AromaColors.coffeeTextSub,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: onConfigureApi,
                        icon: const Icon(Icons.settings_ethernet, size: 14, color: AromaColors.coffeePrimary),
                        label: const Text(
                          "KẾT NỐI SERVER C# API",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AromaColors.coffeePrimary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AromaColors.coffeePrimary, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
