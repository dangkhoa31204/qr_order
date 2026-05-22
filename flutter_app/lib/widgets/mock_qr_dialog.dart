import 'package:flutter/material.dart';
import '../constants.dart';

class MockQrScannerDialog extends StatefulWidget {
  final Function(String, String) onScanned;

  const MockQrScannerDialog({super.key, required this.onScanned});

  @override
  State<MockQrScannerDialog> createState() => _MockQrScannerDialogState();
}

class _MockQrScannerDialogState extends State<MockQrScannerDialog> {
  final List<Map<String, String>> mockTables = [
    {"id": "03", "label": "Bàn #03", "desc": "Khu vực ấm cúng trong nhà"},
    {"id": "08", "label": "Bàn #08", "desc": "Cạnh cửa sổ ngắm phố xá"},
    {"id": "12", "label": "Bàn #12", "desc": "Ban công gió mát lộng lẫy"},
    {"id": "15", "label": "Bàn #15", "desc": "Phòng VIP riêng tư sang trọng"},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AromaColors.coffeeDarkAccent,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "MÔ PHỎNG QUÉT MÃ QR",
                  style: TextStyle(
                    color: AromaColors.coffeeGold,
                    fontSize: 14,
                    fontWeight: FontWeight.black,
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                )
              ],
            ),
            const SizedBox(height: 16),

            // Camera bounds layout mockup
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 72,
                    color: AromaColors.coffeeGold,
                  ),
                  Positioned(
                    bottom: 12,
                    child: Text(
                      "MÔ PHỎNG CAMERA...",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Chọn một mã QR bàn có sẵn để quét giả lập:",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // QR table option buttons
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mockTables.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final tbl = mockTables[idx];
                  return Card(
                    color: Colors.white.withOpacity(0.08),
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        widget.onScanned(tbl["id"]!, tbl["label"]!);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tbl["label"]!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.black,
                                  ),
                                ),
                                Text(
                                  tbl["desc"]!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.qr_code,
                              color: AromaColors.coffeeGold,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
