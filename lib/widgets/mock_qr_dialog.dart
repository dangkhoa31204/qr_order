import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/item_model.dart';

class MockQrScannerDialog extends StatelessWidget {
  final VoidCallback onClose;
  final Function(String tableId, String tableLabel) onScanned;

  const MockQrScannerDialog({
    super.key,
    required this.onClose,
    required this.onScanned,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AromaColors.coffeeBackground,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text("📷", style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      "Quét Mã QR Tại Bàn",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AromaColors.coffeeTextDark,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: AromaColors.coffeeTextSub),
                )
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AromaColors.coffeePrimary, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    "ĐANG TÌM MÃ QR...",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  // Animated Scanner Bar
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 2),
                      builder: (context, value, child) {
                        return Align(
                          alignment: Alignment(0, -1.0 + (value * 2.0)),
                          child: Container(
                            height: 2,
                            color: Colors.greenAccent,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.greenAccent,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        );
                      },
                      onEnd: () {}, // loops handled implicitly
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "HÃY CHỌN MỘT BÀN ĐỂ MÔ PHỎNG QUÉT QR:",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AromaColors.coffeePrimary,
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SizedBox(
                height: 220,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: systemTables.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final t = systemTables[index];
                    return InkWell(
                      onTap: () => onScanned(t.id, t.label),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AromaColors.coffeeCardBorder.withOpacity(0.8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AromaColors.coffeeSecondary.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Text("🍽️", style: TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AromaColors.coffeeTextDark,
                                    ),
                                  ),
                                  Text(
                                    t.description,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AromaColors.coffeeTextSub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.qr_code,
                              size: 18,
                              color: AromaColors.coffeePrimary.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
