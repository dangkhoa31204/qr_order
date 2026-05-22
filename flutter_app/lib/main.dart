import 'package:flutter/material.dart';
import 'constants.dart';
import 'models/item_model.dart';
import 'screens/role_selection_screen.dart';
import 'screens/customer_screen.dart';
import 'screens/staff_screen.dart';

void main() {
  runApp(const AromaBistroApp());
}

class AromaBistroApp extends StatelessWidget {
  const AromaBistroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aroma Bistro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Serif',
        primaryColor: AromaColors.coffeePrimary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AromaColors.coffeePrimary,
          primary: AromaColors.coffeePrimary,
          secondary: AromaColors.coffeeSecondary,
        ),
      ),
      home: const CustomGatewayWrapper(),
    );
  }
}

class CustomGatewayWrapper extends StatefulWidget {
  const CustomGatewayWrapper({super.key});

  @override
  State<CustomGatewayWrapper> createState() => _CustomGatewayWrapperState();
}

class _CustomGatewayWrapperState extends State<CustomGatewayWrapper> {
  UserRole _currentRole = UserRole.undecided;

  // Global Sync States
  List<MenuItem> _menuItems = [];
  final List<OrderModel> _orderQueue = [];
  OrderModel? _activeCustomerOrder;

  @override
  void initState() {
    super.initState();
    // Pre-populate with seed mock values
    _menuItems = List.from(initialMenuItems);

    // Seed one active order for table 08 to make dashboard look rich and complete instantly!
    final initialCartItems = [
      CartItem(
        menuItem: _menuItems.firstWhere((it) => it.id == "m5"), // Espresso Doppio
        quantity: 1,
      ),
      CartItem(
        menuItem: _menuItems.firstWhere((it) => it.id == "m1"), // Butter Croissant
        quantity: 2,
      ),
    ];
    _orderQueue.add(
      OrderModel(
        id: "B08-31620",
        tableId: "08",
        items: initialCartItems,
        status: OrderStatus.preparing,
        timestamp: "5 phút trước",
        note: "Trà đào ít đá ngọt vừa, bánh nướng sừng bò nóng hổi giòn rụm",
        tableLabel: "Bàn #08",
      ),
    );
  }

  void _onOrderSubmitted(OrderModel newOrder) {
    setState(() {
      _orderQueue.add(newOrder);
      // Link as active tracker for the current user
      _activeCustomerOrder = newOrder;
    });
  }

  void _onUpdateOrderStatus(String orderId, OrderStatus nextStatus) {
    setState(() {
      final index = _orderQueue.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final original = _orderQueue[index];
        final updated = original.copyWith(status: nextStatus);
        _orderQueue[index] = updated;

        // Synchronize with active customer tracker if matching id
        if (_activeCustomerOrder != null && _activeCustomerOrder!.id == orderId) {
          _activeCustomerOrder = updated;
        }
      }
    });
  }

  void _openOrderTrackerDialog() {
    if (_activeCustomerOrder == null) return;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setTrackState) {
            final double itemsTotal = _activeCustomerOrder!.items.fold(0.0, (acc, item) {
              return acc + (item.menuItem.price * item.quantity);
            });
            final double taxTotal = itemsTotal * 0.10;
            final double netTotal = itemsTotal + taxTotal;

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: AromaColors.coffeeBackground,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text("🛵", style: TextStyle(fontSize: 22)),
                            SizedBox(width: 8),
                            Text(
                              "Hành Trình Đơn Hàng",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AromaColors.coffeeTextDark),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Top basic banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AromaColors.coffeeDarkAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "MÃ ĐƠN: ${_activeCustomerOrder!.id}",
                                style: const TextStyle(color: AromaColors.coffeeGold, fontSize: 11, fontWeight: FontWeight.black),
                              ),
                              Text(
                                _activeCustomerOrder!.tableLabel,
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _activeCustomerOrder!.status.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _activeCustomerOrder!.status.label,
                              style: TextStyle(color: _activeCustomerOrder!.status.color, fontSize: 10, fontWeight: FontWeight.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Process dynamic timeline
                    const Text("TIẾN ĐỘ THỰC HIỆN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AromaColors.coffeeTextSub)),
                    const SizedBox(height: 12),
                    _buildTimelineRow("1. Bếp Tiệp Nhận Đơn", "Đã gửi vào lò chế biến thành công", _activeCustomerOrder!.status.index >= 0),
                    _buildTimelineDivider(_activeCustomerOrder!.status.index >= 1),
                    _buildTimelineRow("2. Đang Pha Chế Sủi Bọt", "Barista đang thổi hương bơ nướng bánh", _activeCustomerOrder!.status.index >= 1),
                    _buildTimelineDivider(_activeCustomerOrder!.status.index >= 2),
                    _buildTimelineRow("3. Sẵn Sàng Phục Vụ", "Vui lòng đón nhận món từ nhân viên", _activeCustomerOrder!.status.index >= 2),
                    _buildTimelineDivider(_activeCustomerOrder!.status.index >= 3),
                    _buildTimelineRow("4. Hoàn Thành Thanh toán", "Ký nhận liên hoàn đơn và lưu trữ", _activeCustomerOrder!.status.index >= 3),

                    const SizedBox(height: 16),
                    const Text("CHI TIẾT HÓA ĐƠN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AromaColors.coffeeTextSub)),
                    const SizedBox(height: 6),

                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AromaColors.coffeeCardBorder),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ..._activeCustomerOrder!.items.map((it) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${it.menuItem.emoji} ${it.menuItem.name} x${it.quantity}",
                                      style: const TextStyle(fontSize: 11, color: AromaColors.coffeeTextDark),
                                    ),
                                    Text(
                                      "\$${(it.menuItem.price * it.quantity).toStringAsFixed(2)}",
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Tổng Tiền", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AromaColors.coffeePrimary)),
                                Text("\$${netTotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AromaColors.coffeePrimary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineRow(String title, String desc, bool isDone) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isDone ? AromaColors.successGreen : Colors.grey.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: isDone ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDone ? AromaColors.coffeeTextDark : Colors.grey,
              ),
            ),
            Text(
              desc,
              style: TextStyle(fontSize: 9, color: isDone ? AromaColors.coffeeTextSub : Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineDivider(bool isDone) {
    return Container(
      width: 2,
      height: 12,
      margin: const EdgeInsets.only(left: 6),
      color: isDone ? AromaColors.successGreen : Colors.grey.withOpacity(0.3),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentRole) {
      case UserRole.undecided:
        return RoleSelectionScreen(
          onRoleSelected: (role) {
            setState(() {
              _currentRole = role;
            });
          },
        );
      case UserRole.customer:
        return CustomerScreen(
          menuItems: _menuItems,
          onBackToGateway: () {
            setState(() {
              _currentRole = UserRole.undecided;
            });
          },
          activeCustomerOrder: _activeCustomerOrder,
          onOrderSubmitted: _onOrderSubmitted,
          onOpenTracker: _openOrderTrackerDialog,
        );
      case UserRole.staff:
        return StaffScreen(
          orderQueue: _orderQueue,
          menuItems: _menuItems,
          onBackToGateway: () {
            setState(() {
              _currentRole = UserRole.undecided;
            });
          },
          onUpdateOrderStatus: _onUpdateOrderStatus,
          onCreateMenuItem: (newItem) {
            setState(() {
              _menuItems.add(newItem);
            });
          },
          onUpdateMenuItem: (updatedItem) {
            setState(() {
              final index = _menuItems.indexWhere((it) => it.id == updatedItem.id);
              if (index != -1) {
                _menuItems[index] = updatedItem;
              }
            });
          },
          onDeleteMenuItem: (itemId) {
            setState(() {
              _menuItems.removeWhere((it) => it.id == itemId);
            });
          },
          onToggleAvailability: (itemId) {
            setState(() {
              final index = _menuItems.indexWhere((it) => it.id == itemId);
              if (index != -1) {
                final original = _menuItems[index];
                _menuItems[index] = original.copyWith(isAvailable: !original.isAvailable);
              }
            });
          },
        );
    }
  }
}
