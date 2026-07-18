import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../models/item_model.dart';

/*==================================================
  1. WEEKLY SALES CHART (BAR CHART)
==================================================*/
class WeeklySalesChart extends StatelessWidget {
  final List<OrderModel> history;

  const WeeklySalesChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // Group sales by day for the last 7 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weeklyData = List.generate(7, (index) {
      final day = today.subtract(Duration(days: 6 - index));
      double total = 0;
      for (var o in history) {
        if (o.status == OrderStatus.paid) {
          final orderDay = DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
          if (orderDay.isAtSameMomentAs(day)) {
            total += o.totalAmount;
          }
        }
      }
      return _BarData(
        label: DateFormat('E', 'vi').format(day).toUpperCase(),
        value: total,
      );
    });

    double maxValue = weeklyData.map((d) => d.value).reduce(max);
    if (maxValue == 0) maxValue = 100000; // Default height scaling if no data

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AromaColors.coffeeCardBorder),
        boxShadow: AromaStyles.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AromaColors.coffeePrimary, size: 20),
              SizedBox(width: 8),
              Text(
                "Doanh thu 7 ngày qua",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AromaColors.coffeeTextDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _BarChartPainter(data: weeklyData, maxValue: maxValue),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarData {
  final String label;
  final double value;
  _BarData({required this.label, required this.value});
}

class _BarChartPainter extends CustomPainter {
  final List<_BarData> data;
  final double maxValue;

  _BarChartPainter({required this.data, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AromaColors.coffeeCardBorder.withOpacity(0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final barPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [AromaColors.coffeePrimary, AromaColors.coffeeGold],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Draw horizontal grid lines
    const gridCount = 3;
    final usableHeight = size.height - 24; // Leave space for labels
    for (int i = 0; i <= gridCount; i++) {
      final y = (usableHeight / gridCount) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final barWidth = (size.width / data.length) * 0.45;
    final spacing = (size.width / data.length);

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final barHeight = d.value == 0 ? 4.0 : (d.value / maxValue) * (usableHeight - 16);
      
      final x = spacing * i + (spacing - barWidth) / 2;
      final y = usableHeight - barHeight;

      // Draw rounded bar
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      );
      canvas.drawRRect(rect, barPaint);

      // Draw value text
      if (d.value > 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: _formatShortAmount(d.value),
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: AromaColors.coffeeTextSub,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(x + (barWidth - textPainter.width) / 2, y - 14),
        );
      }

      // Draw day label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: d.label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AromaColors.coffeeTextSub,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(x + (barWidth - labelPainter.width) / 2, usableHeight + 8),
      );
    }
  }

  String _formatShortAmount(double val) {
    if (val >= 1000000) {
      return "${(val / 1000000).toStringAsFixed(1)}M";
    } else if (val >= 1000) {
      return "${(val / 1000).toStringAsFixed(0)}K";
    }
    return val.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/*==================================================
  2. CATEGORY DISTRIBUTION CHART (DONUT CHART)
==================================================*/
class CategoryDistributionChart extends StatelessWidget {
  final List<OrderModel> history;
  final List<MenuItem> menuItems;

  const CategoryDistributionChart({
    super.key,
    required this.history,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    // Count items sold by category
    final categoryCounts = <CategoryType, int>{};
    for (var o in history) {
      if (o.status == OrderStatus.paid) {
        for (var item in o.items) {
          final menuRef = menuItems.firstWhere(
            (m) => m.menuItemId == item.menuItemId,
            orElse: () => MenuItem(
              menuItemId: -1,
              name: "",
              price: 0,
              category: CategoryType.other,
            ),
          );
          if (menuRef.menuItemId != -1) {
            categoryCounts[menuRef.category] = (categoryCounts[menuRef.category] ?? 0) + item.quantity;
          }
        }
      }
    }

    final totalItems = categoryCounts.values.fold(0, (sum, count) => sum + count);
    final List<_PieSegment> segments = [];
    final categoryColors = {
      CategoryType.coffee: const Color(0xFF8D6E63),
      CategoryType.tea: const Color(0xFF81C784),
      CategoryType.cake: const Color(0xFFFFB74D),
      CategoryType.juice: const Color(0xFF4FC3F7),
      CategoryType.other: const Color(0xFFBA68C8),
    };

    categoryColors.forEach((cat, color) {
      final count = categoryCounts[cat] ?? 0;
      if (count > 0 || totalItems == 0) {
        segments.add(_PieSegment(
          category: cat,
          count: count,
          percentage: totalItems == 0 ? 0.2 : count / totalItems,
          color: color,
        ));
      }
    });

    if (totalItems == 0) {
      // Setup mock segments if no data is available
      segments.clear();
      segments.add(_PieSegment(category: CategoryType.coffee, count: 0, percentage: 0.4, color: categoryColors[CategoryType.coffee]!));
      segments.add(_PieSegment(category: CategoryType.tea, count: 0, percentage: 0.3, color: categoryColors[CategoryType.tea]!));
      segments.add(_PieSegment(category: CategoryType.cake, count: 0, percentage: 0.15, color: categoryColors[CategoryType.cake]!));
      segments.add(_PieSegment(category: CategoryType.juice, count: 0, percentage: 0.15, color: categoryColors[CategoryType.juice]!));
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AromaColors.coffeeCardBorder),
        boxShadow: AromaStyles.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: AromaColors.coffeePrimary, size: 20),
              SizedBox(width: 8),
              Text(
                "Phân bố theo danh mục",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AromaColors.coffeeTextDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _DonutChartPainter(segments: segments),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: segments.map((seg) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: seg.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              seg.category.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AromaColors.coffeeTextDark,
                              ),
                            ),
                          ),
                          Text(
                            "${(seg.percentage * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AromaColors.coffeeTextSub,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _PieSegment {
  final CategoryType category;
  final int count;
  final double percentage;
  final Color color;

  _PieSegment({
    required this.category,
    required this.count,
    required this.percentage,
    required this.color,
  });
}

class _DonutChartPainter extends CustomPainter {
  final List<_PieSegment> segments;

  _DonutChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;

    for (var seg in segments) {
      final sweepAngle = 2 * pi * seg.percentage;
      paint.color = seg.color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Border line inside donut
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), (size.width - 24) / 2, borderPaint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), (size.width + 24) / 2, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/*==================================================
  3. HOURLY TRAFFIC CHART (LINE CHART)
==================================================*/
class HourlyTrafficChart extends StatelessWidget {
  final List<OrderModel> history;

  const HourlyTrafficChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // Groups orders by intervals: Morning (6-11), Noon (11-14), Afternoon (14-18), Evening (18-22)
    final counts = [0, 0, 0, 0];
    final labels = ["Sáng", "Trưa", "Chiều", "Tối"];

    for (var o in history) {
      if (o.status == OrderStatus.paid) {
        final hour = o.createdAt.toLocal().hour;
        if (hour >= 6 && hour < 11) {
          counts[0]++;
        } else if (hour >= 11 && hour < 14) {
          counts[1]++;
        } else if (hour >= 14 && hour < 18) {
          counts[2]++;
        } else if (hour >= 18 && hour < 23) {
          counts[3]++;
        }
      }
    }

    int maxCount = counts.reduce(max);
    if (maxCount == 0) maxCount = 5; // Default grid scale if empty

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AromaColors.coffeeCardBorder),
        boxShadow: AromaStyles.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart_rounded, color: AromaColors.coffeePrimary, size: 20),
              SizedBox(width: 8),
              Text(
                "Lượng khách theo khung giờ (Hôm nay)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AromaColors.coffeeTextDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineChartPainter(counts: counts, labels: labels, maxCount: maxCount),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<int> counts;
  final List<String> labels;
  final int maxCount;

  _LineChartPainter({required this.counts, required this.labels, required this.maxCount});

  @override
  void paint(Canvas canvas, Size size) {
    final usableHeight = size.height - 24;
    final stepWidth = size.width / (counts.length - 1);

    // Draw gridlines
    final gridPaint = Paint()
      ..color = AromaColors.coffeeCardBorder.withOpacity(0.6)
      ..strokeWidth = 1;
    for (int i = 0; i < 3; i++) {
      final y = (usableHeight / 2) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Compute coordinates
    final points = <Offset>[];
    for (int i = 0; i < counts.length; i++) {
      final x = stepWidth * i;
      final y = usableHeight - (counts[i] / maxCount) * (usableHeight - 16);
      points.add(Offset(x, y));
    }

    // Draw glowing gradient shadow path
    final fillPath = Path()
      ..moveTo(0, usableHeight);
    for (var p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(size.width, usableHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AromaColors.coffeePrimary.withOpacity(0.18), Colors.white.withOpacity(0.01)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw smooth curve line
    final linePaint = Paint()
      ..color = AromaColors.coffeePrimary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      linePath.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p2.dx, p2.dy,
      );
    }
    canvas.drawPath(linePath, linePaint);

    // Draw dots and text
    final dotPaint = Paint()
      ..color = AromaColors.coffeeGold
      ..style = PaintingStyle.fill;
    final dotStrokePaint = Paint()
      ..color = AromaColors.coffeePrimary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      canvas.drawCircle(p, 5, dotPaint);
      canvas.drawCircle(p, 5, dotStrokePaint);

      // Value label
      final valuePainter = TextPainter(
        text: TextSpan(
          text: "${counts[i]}đ",
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AromaColors.coffeePrimary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valuePainter.paint(canvas, Offset(p.dx - valuePainter.width / 2, p.dy - 16));

      // X Label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AromaColors.coffeeTextSub,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(p.dx - labelPainter.width / 2, usableHeight + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
