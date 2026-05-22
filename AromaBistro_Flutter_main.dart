import 'package:flutter/material.dart';
import 'dart:math';

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
        useMaterial3: true,
        primaryColor: const Color(0xFF4E342E), // Coffee Primary
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E342E),
          primary: const Color(0xFF4E342E),
          secondary: const Color(0xFFD7CCC8), // Coffee Secondary
          background: const Color(0xFFEFEBE9), // Coffee Background
        ),
      ),
      home: const MainContainerScreen(),
    );
  }
}

// =========================================================================
// DATA MODELS & SEED DATA
// =========================================================================

enum UserRole { undecided, customer, staff }

enum OrderStatus {
  pending,
  preparing,
  ready,
  paid;

  String get label => {
        OrderStatus.pending: "Pending",
        OrderStatus.preparing: "Preparing",
        OrderStatus.ready: "Ready",
        OrderStatus.paid: "Paid",
      }[this]!;

  String get vietnamese => {
        OrderStatus.pending: "Chờ xác nhận",
        OrderStatus.preparing: "Đang chế biến",
        OrderStatus.ready: "Hoàn thành món",
        OrderStatus.paid: "Đã thanh toán",
      }[this]!;

  Color get color => {
        OrderStatus.pending: const Color(0xFFEF8C2E),
        OrderStatus.preparing: const Color(0xFF1E88E5),
        OrderStatus.ready: const Color(0xFF4CAF50),
        OrderStatus.paid: const Color(0xFF7E5700),
      }[this]!;
}

class MenuItem {
  final String id;
  final String name;
  final String vietnameseName;
  final double price;
  final String description;
  final String emoji;
  final String category;
  bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.vietnameseName,
    required this.price,
    required this.description,
    required this.emoji,
    required this.category,
    this.isAvailable = true,
  });
}

class TableModel {
  final String id;
  final String label;
  final String description;
  String status; // "Empty", "Active", "Paid"

  TableModel({
    required this.id,
    required this.label,
    required this.description,
    required this.status,
  });
}

class CartItem {
  final MenuItem menuItem;
  int quantity;
  String note;

  CartItem({
    required this.menuItem,
    required this.quantity,
    this.note = "",
  });
}

class OrderModel {
  final String id;
  final String tableId;
  final List<CartItem> items;
  OrderStatus status;
  int timeMinutes;
  final String timestamp;
  final String note;
  final String tableLabel;

  OrderModel({
    required this.id,
    required this.tableId,
    required this.items,
    required this.status,
    this.timeMinutes = 0,
    required this.timestamp,
    this.note = "",
    required this.tableLabel,
  });
}

// Initial Menu Items (Consistent with Kotlin version)
final List<MenuItem> initialMenuItems = [
  MenuItem(id: "m1", name: "Butter Croissant", vietnameseName: "Bánh Sừng Bò Pháp", price: 4.50, description: "Bánh sừng bò ngập hương bơ Pháp, giòn rụm thơm ngon nướng vàng ươm mỗi sáng.", emoji: "🥐", category: "Pastries"),
  MenuItem(id: "m2", name: "Avocado Toast", vietnameseName: "Bánh Mì Trái Bơ", price: 12.00, description: "Bánh mì lát nướng giòn rải bơ tươi nhuyễn, cà chua bi và hạt chia hữu cơ.", emoji: "🥑", category: "Brunch"),
  MenuItem(id: "m3", name: "Matcha Latte", vietnameseName: "Trà Xanh Nhật Matcha", price: 5.75, description: "Trà xanh matcha Nhật Bản thượng hạng đánh mịn cùng sữa hạt organic thơm béo.", emoji: "🍵", category: "Teas"),
  MenuItem(id: "m4", name: "Quinoa Salmon Bowl", vietnameseName: "Cơm Salmond Quinoa", price: 14.50, description: "Cá hồi áp chảo thơm lừng cùng quinoa đỏ, khoai lang nướng và cải xoăn hữu cơ.", emoji: "🥗", category: "Brunch"),
  MenuItem(id: "m5", name: "Espresso Doppio", vietnameseName: "Cà Phê Espresso Đôi", price: 3.50, description: "Cà phê pha máy Espresso Doppio đậm đà nguyên bản từ hạt Arabica Cầu Đất tinh tế.", emoji: "☕", category: "Coffees"),
  MenuItem(id: "m6", name: "Fluffy Blueberry Pancake", vietnameseName: "Bánh Kẹp Việt Quất", price: 9.75, description: "Bánh pancake xếp lớp xốp mềm tràn ngập quả việt quất tươi và si rô phong nguyên chất.", emoji: "🥞", category: "Pastries"),
  MenuItem(id: "m7", name: "Egg Benedict", vietnameseName: "Trứng Benedict Kiểu Anh", price: 13.00, description: "Trứng chần sánh dẻo, giăm bông hun khói và sốt bơ béo Hollandaise trên English muffin.", emoji: "🍳", category: "Brunch"),
  MenuItem(id: "m8", name: "Peach Hibiscus Tea", vietnameseName: "Trà Hibiscus Đào Hồng", price: 6.00, description: "Vị chua thanh mát lành từ hoa hồng đài hòa quyện trà đào ngào mật ong ngọt nhẹ.", emoji: "🍑", category: "Teas"),
  MenuItem(id: "m9", name: "Cold Brew Tonic", vietnameseName: "Cà Phê Lạnh Sủi Bọt", price: 6.50, description: "Cà phê ủ lạnh 18 tiếng rót cùng nước tonic cao cấp sảng khoái và lát chanh vàng tươi.", emoji: "🍹", category: "Coffees"),
];

final List<TableModel> systemTables = [
  TableModel(id: "03", label: "Bàn #03", description: "Khu vực ấm cúng trong nhà", status: "Empty"),
  TableModel(id: "08", label: "Bàn #08", description: "Cạnh cửa sổ ngắm phố xá", status: "Active"),
  TableModel(id: "12", label: "Bàn #12", description: "Ban công gió mát lộng lẫy", status: "Empty"),
  TableModel(id: "15", label: "Bàn #15", description: "Phòng VIP riêng tư sang trọng", status: "Empty"),
];

// Aesthetic color constants matching Aroma Bistro Custom theme
class AromaColors {
  static const Color coffeePrimary = Color(0xFF4E342E);
  static const Color coffeeSecondary = Color(0xFFD7CCC8);
  static const Color coffeeBackground = Color(0xFFF5F2F0);
  static const Color coffeeDarkAccent = Color(0xFF2D1F1C);
  static const Color coffeeGold = Color(0xFFEF8C2E);
  static const Color coffeeTextDark = Color(0xFF3E2723);
  static const Color coffeeTextSub = Color(0xFF705C58);
  static const Color coffeeCardBorder = Color(0xFFE0D8D5);
  static const Color successGreen = Color(0xFF4CAF50);
}

// =========================================================================
// MAIN CONTAINER ROOT WITH REACTION STATES (Simulates Android Architecture)
// =========================================================================

class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  UserRole userRole = UserRole.undecided;
  String selectedTableId = "08";
  String selectedTableLabel = "Bàn #08";
  String searchQuery = "";
  String activeCategory = "All";

  // Dynamic States
  late List<MenuItem> menuItems;
  final List<OrderModel> orderQueue = [];
  OrderModel? activeCustomerOrder;
  final Map<String, CartItem> cartState = {};
  String customOrderNote = "";

  @override
  void initState() {
    super.initState();
    // Clone initial menu items reference
    menuItems = List.from(initialMenuItems);

    // Initial Active order mock seed
    final demoCart = [
      CartItem(menuItem: initialMenuItems[1], quantity: 1, note: "Less spice"),
      CartItem(menuItem: initialMenuItems[2], quantity: 1, note: "Extra ice"),
    ];
    final demoOrder = OrderModel(
      id: "OD-1024",
      tableId: "08",
      items: demoCart,
      status: OrderStatus.preparing,
      timeMinutes: 4,
      timestamp: "12:15",
      note: "Không đá, ít ngọt",
      tableLabel: "Bàn #08",
    );
    orderQueue.add(demoOrder);
    activeCustomerOrder = demoOrder;
  }

  // Calculate Subtotals
  double get subtotal {
    double total = 0.0;
    cartState.forEach((key, value) {
      total += value.menuItem.price * value.quantity;
    });
    return total;
  }

  double get taxAndService => subtotal * 0.10;
  double get totalAmount => subtotal + taxAndService;
  int get totalItemsCount {
    int count = 0;
    cartState.forEach((key, value) {
      count += value.quantity;
    });
    return count;
  }

  void _addCart(MenuItem item) {
    setState(() {
      if (cartState.containsKey(item.id)) {
        cartState[item.id]!.quantity += 1;
      } else {
        cartState[item.id] = CartItem(menuItem: item, quantity: 1);
      }
    });
  }

  void _removeCart(MenuItem item) {
    setState(() {
      if (cartState.containsKey(item.id)) {
        if (cartState[item.id]!.quantity > 1) {
          cartState[item.id]!.quantity -= 1;
        } else {
          cartState.remove(item.id);
        }
      }
    });
  }

  void _triggerQrCodeScanSimulation() {
    showDialog(
      context: context,
      builder: (context) => MockQrScannerDialog(
        onScanned: (tableId, tableLabel) {
          setState(() {
            selectedTableId = tableId;
            selectedTableLabel = tableLabel;
          });
        },
      ),
    );
  }

  void _openCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AromaColors.coffeeBackground,
      shape: const RoundedCornerShape(24),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ShoppingCartSheet(
              cartItems: cartState.values.toList(),
              selectedTableLabel: selectedTableLabel,
              subtotal: subtotal,
              taxAndService: taxAndService,
              total: totalAmount,
              note: customOrderNote,
              onNoteChange: (newNote) {
                customOrderNote = newNote;
              },
              onIncrease: (item) {
                _addCart(item);
                setModalState(() {});
                setState(() {});
              },
              onDecrease: (item) {
                _removeCart(item);
                setModalState(() {});
                setState(() {});
              },
              onCheckout: () {
                if (cartState.isNotEmpty) {
                  final newId = "B$selectedTableId-${1000 + Random().nextInt(8999)}";
                  final createdOrder = OrderModel(
                    id: newId,
                    tableId: selectedTableId,
                    items: cartState.values.toList(),
                    status: OrderStatus.pending,
                    timestamp: "Vừa xong",
                    note: customOrderNote,
                    tableLabel: selectedTableLabel,
                  );
                  setState(() {
                    orderQueue.add(createdOrder);
                    activeCustomerOrder = createdOrder;
                    cartState.clear();
                    customOrderNote = "";
                  });
                  Navigator.pop(context);
                  _openOrderTracker();
                }
              },
            );
          },
        );
      },
    );
  }

  void _openOrderTracker() {
    if (activeCustomerOrder == null) return;
    showDialog(
      context: context,
      builder: (context) => OrderTrackerDialog(
        order: activeCustomerOrder!,
        onCancel: () {
          setState(() {
            orderQueue.removeWhere((o) => o.id == activeCustomerOrder!.id);
            activeCustomerOrder = null;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == UserRole.undecided) {
      return UserRoleSelectionScreen(
        onRoleSelected: (role) {
          setState(() {
            userRole = role;
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: AromaColors.coffeeBackground,
      body: SafeArea(
        child: userRole == UserRole.customer
            ? CustomerMainScreen(
                selectedTableId: selectedTableId,
                selectedTableLabel: selectedTableLabel,
                searchQuery: searchQuery,
                onSearchChange: (val) => setState(() => searchQuery = val),
                activeCategory: activeCategory,
                onCategorySelect: (val) => setState(() => activeCategory = val),
                menuItems: menuItems,
                cartState: cartState,
                onAddCart: _addCart,
                onRemoveCart: _removeCart,
                onOpenQrScanner: _triggerQrCodeScanSimulation,
                onCartClick: _openCartBottomSheet,
                subtotal: subtotal,
                totalItemsCount: totalItemsCount,
                onBackToGateway: () => setState(() => userRole = UserRole.undecided),
                activeCustomerOrder: activeCustomerOrder,
                onOpenTracker: _openOrderTracker,
              )
            : StaffDashboard(
                orderQueue: orderQueue,
                menuItems: menuItems,
                onToggleAvailability: (id) {
                  setState(() {
                    for (var item in menuItems) {
                      if (item.id == id) {
                        item.isAvailable = !item.isAvailable;
                      }
                    }
                  });
                },
                onUpdateOrderStatus: (orderId, newStatus) {
                  setState(() {
                    for (var order in orderQueue) {
                      if (order.id == orderId) {
                        order.status = newStatus;
                      }
                    }
                    if (activeCustomerOrder?.id == orderId) {
                      activeCustomerOrder!.status = newStatus;
                    }
                  });
                },
                onBackToGateway: () => setState(() => userRole = UserRole.undecided),
              ),
      ),
    );
  }
}

// =========================================================================
// UI COMPONENT: ROLE SELECTION SCREEN
// =========================================================================

class UserRoleSelectionScreen extends StatelessWidget {
  final Function(UserRole) onRoleSelected;

  const UserRoleSelectionScreen({super.key, required this.onRoleSelected});

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
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AromaColors.coffeePrimary,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.Center,
                child: const Text("☕", style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 16),
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
              const Text(
                "Hệ thống Gọi món QR Code & Quản lý Realtime",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AromaColors.coffeeTextSub,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "VUI LÒNG CHỌN VAI TRÒ TRUY CẬP",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AromaColors.coffeeGold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Customer Gateway Card
              Card(
                color: Colors.white,
                shape: RoundedCornerShape(20),
                elevation: 2,
                child: InkWell(
                  onTap: () => onRoleSelected(UserRole.customer),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
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
                                    padding: const EdgeInsets.all(4),
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

              // Staff Gateway Card
              Card(
                color: AromaColors.coffeeDarkAccent,
                shape: RoundedCornerShape(20),
                elevation: 4,
                child: InkWell(
                  onTap: () => onRoleSelected(UserRole.staff),
                  borderRadius: BorderRadius.circular(20),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

              // Architectural framework spec card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AromaColors.coffeeSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
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
                    SizedBox(height: 4),
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

// =========================================================================
// CUSTOMER PANEL SCREEN (Exclusively Customer Focused)
// =========================================================================

class CustomerMainScreen extends StatelessWidget {
  final String selectedTableId;
  final String selectedTableLabel;
  final String searchQuery;
  final ValueChanged<String> onSearchChange;
  final String activeCategory;
  final ValueChanged<String> onCategorySelect;
  final List<MenuItem> menuItems;
  final Map<String, CartItem> cartState;
  final Function(MenuItem) onAddCart;
  final Function(MenuItem) onRemoveCart;
  final VoidCallback onOpenQrScanner;
  final VoidCallback onCartClick;
  final double subtotal;
  final int totalItemsCount;
  final VoidCallback onBackToGateway;
  final OrderModel? activeCustomerOrder;
  final VoidCallback onOpenTracker;

  const CustomerMainScreen({
    super.key,
    required this.selectedTableId,
    required this.selectedTableLabel,
    required this.searchQuery,
    required this.onSearchChange,
    required this.activeCategory,
    required this.onCategorySelect,
    required this.menuItems,
    required this.cartState,
    required this.onAddCart,
    required this.onRemoveCart,
    required this.onOpenQrScanner,
    required this.onCartClick,
    required this.subtotal,
    required this.totalItemsCount,
    required this.onBackToGateway,
    this.activeCustomerOrder,
    required this.onOpenTracker,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ["All", "Coffees", "Teas", "Pastries", "Brunch"];

    // Filtering items
    final filteredItems = menuItems.where((item) {
      final matchesCategory = activeCategory == "All" || item.category == activeCategory;
      final matchesSearch = item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.vietnameseName.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Column(
      children: [
        // Beautiful Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AromaColors.coffeePrimary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.Center,
                      child: const Text("☕", style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Aroma Bistro",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AromaColors.coffeeTextDark,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AromaColors.successGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Màn Menu • Bàn: $selectedTableId",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AromaColors.coffeeTextSub,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  // QR Scan simulated button
                  IconButton(
                    onPressed: onOpenQrScanner,
                    style: IconButton.styleFrom(
                      backgroundColor: AromaColors.coffeeSecondary.withOpacity(0.3),
                      padding: const EdgeInsets.all(10),
                    ),
                    icon: const Icon(Icons.qr_code_scanner, color: AromaColors.coffeePrimary, size: 20),
                  ),
                  const SizedBox(width: 8),
                  // Switching Role Gateway back button
                  ElevatedButton.icon(
                    onPressed: onBackToGateway,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AromaColors.coffeePrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text("Đổi Vai", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),

        // Horizontally Scrollable categories list
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, idx) {
              final cat = categories[idx];
              final isSelected = cat == activeCategory;
              String displayName = cat;
              if (cat == "All") displayName = "Tất cả menu";
              if (cat == "Coffees") displayName = "Cà phê ☕";
              if (cat == "Teas") displayName = "Trà hoa quả 🍵";
              if (cat == "Pastries") displayName = "Bánh ngọt 🥐";
              if (cat == "Brunch") displayName = "Điểm tâm 🥑";

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AromaColors.coffeeTextSub,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AromaColors.coffeePrimary,
                  backgroundColor: AromaColors.coffeeSecondary.withOpacity(0.3),
                  onSelected: (selected) {
                    if (selected) onCategorySelect(cat);
                  },
                ),
              );
            },
          ),
        ),

        // Beautiful Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: TextField(
            onChanged: onSearchChange,
            decoration: InputDecoration(
              hintText: "Tìm món ăn, đồ uống thơm phức...",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AromaColors.coffeePrimary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AromaColors.coffeeCardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AromaColors.coffeeCardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AromaColors.coffeePrimary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),

        // Main ListView menu cards
        Expanded(
          child: filteredItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("☕", style: TextStyle(fontSize: 48)),
                      SizedBox(height: 8),
                      Text("Món ăn không có sẵn!", style: TextStyle(color: AromaColors.coffeeTextSub, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final cartCount = cartState[item.id]?.quantity ?? 0;

                    return MenuCardItem(
                      item: item,
                      cartCount: cartCount,
                      onAdd: () => onAddCart(item),
                      onRemove: () => onRemoveCart(item),
                    );
                  },
                ),
        ),

        // Dynamic shopping float bar & order tracker sticky panels
        if (totalItemsCount > 0)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: onCartClick,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AromaColors.coffeePrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(color: AromaColors.coffeeGold, shape: BoxShape.circle),
                          alignment: Alignment.Center,
                          child: Text(
                            "$totalItemsCount",
                            style: const TextStyle(color: AromaColors.coffeePrimary, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Xem giỏ hàng của bạn",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    Text(
                      "\$${subtotal.toStringAsFixed(2)}",
                      style: const TextStyle(color: AromaColors.coffeeGold, fontWeight: FontWeight.bold, fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
          ),

        // Bottom Tracker trigger bar
        if (activeCustomerOrder != null && activeCustomerOrder!.status != OrderStatus.paid)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              color: AromaColors.coffeeDarkAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: InkWell(
                onTap: onOpenTracker,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(color: AromaColors.coffeeGold, shape: BoxShape.circle),
                            child: const Icon(Icons.autorenew, color: AromaColors.coffeePrimary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Đơn ${activeCustomerOrder!.id} • ${activeCustomerOrder!.status.vietnamese}",
                                style: const TextStyle(color: AromaColors.coffeeGold, fontSize: 11, fontWeight: FontWeight.black),
                              ),
                              const Text(
                                "Bấm để chi tiết tiến độ món ăn...",
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          )
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AromaColors.coffeePrimary),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activeCustomerOrder!.tableLabel,
                          style: const TextStyle(color: AromaColors.coffeeGold, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}

// =========================================================================
// UI COMPONENT: MENU LIST CARD ITEM
// =========================================================================

class MenuCardItem extends StatelessWidget {
  final MenuItem item;
  final int cartCount;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const MenuCardItem({
    super.key,
    required this.item,
    required this.cartCount,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AromaColors.coffeeCardBorder),
      ),
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Frame container for item Emoji Photo layout
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AromaColors.coffeeSecondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.Center,
                  child: Text(item.emoji, style: const TextStyle(fontSize: 38)),
                ),
                if (!item.isAvailable)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.Center,
                    child: const Text(
                      "HẾT HÀNG",
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  )
              ],
            ),
            const SizedBox(width: 14),

            // Item Metadata details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AromaColors.coffeeTextDark),
                  ),
                  Text(
                    item.vietnameseName,
                    style: const TextStyle(fontSize: 11, color: AromaColors.coffeeTextSub),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "\$${item.price.toStringAsFixed(2)}",
                        style: const TextStyle(color: AromaColors.coffeePrimary, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "(~${(item.price * 25000).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ)",
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Controls
            if (!item.isAvailable)
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AromaColors.coffeeSecondary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text("Hết", style: TextStyle(fontSize: 11)),
              )
            else if (cartCount == 0)
              IconButton(
                onPressed: onAdd,
                iconSize: 20,
                style: IconButton.styleFrom(
                  backgroundColor: AromaColors.coffeeSecondary.withOpacity(0.3),
                  foregroundColor: AromaColors.coffeePrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Text("+ THÊM", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AromaColors.coffeePrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.remove, color: Colors.white, size: 14),
                    ),
                    Text("$cartCount", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    IconButton(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add, color: Colors.white, size: 14),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// UI COMPONENT: STAFF SERVICE DASHBOARD & ADMIN PANEL
// =========================================================================

class StaffDashboard extends StatefulWidget {
  final List<OrderModel> orderQueue;
  final List<MenuItem> menuItems;
  final Function(String) onToggleAvailability;
  final Function(String, OrderStatus) onUpdateOrderStatus;
  final VoidCallback onBackToGateway;

  const StaffDashboard({
    super.key,
    required this.orderQueue,
    required this.menuItems,
    required this.onToggleAvailability,
    required this.onUpdateOrderStatus,
    required this.onBackToGateway,
  });

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  String activeStaffSubTab = "orders"; // "orders", "menu", "tables", "architecture"

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Staff Dashboard Header
        Container(
          color: AromaColors.coffeeDarkAccent,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.storefront, color: AromaColors.coffeeGold),
                      SizedBox(width: 8),
                      Text(
                        "Aroma Crew 💼",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AromaColors.successGreen.withOpacity(0.2),
                          border: Border.all(color: AromaColors.successGreen),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text("SIGNALR ACTIVE", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: widget.onBackToGateway,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.12),
                          padding: const EdgeInsets.all(8),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white, size: 14),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),

              // Horizontal sub tabs selector
              Row(
                children: [
                  _subTabButton("orders", "Đơn hàng"),
                  _subTabButton("menu", "Thực đơn"),
                  _subTabButton("tables", "Sơ đồ"),
                  _subTabButton("architecture", "C# Kiến trúc"),
                ],
              ),
            ],
          ),
        ),

        // Bottom Dashboard view layouts
        Expanded(
          child: _renderSubTabContent(),
        ),
      ],
    );
  }

  Widget _subTabButton(String tab, String label) {
    final isSelected = activeStaffSubTab == tab;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: ElevatedButton(
          onPressed: () => setState(() => activeStaffSubTab = tab),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? AromaColors.coffeePrimary : Colors.transparent,
            foregroundColor: isSelected ? Colors.white : Colors.white70,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _renderSubTabContent() {
    switch (activeStaffSubTab) {
      case "orders":
        return _buildOrdersSubTab();
      case "menu":
        return _buildMenuManagementSubTab();
      case "tables":
        return _buildTablesVisualSubTab();
      case "architecture":
        return _buildArchitectureDetails();
      default:
        return const SizedBox();
    }
  }

  Widget _buildOrdersSubTab() {
    if (widget.orderQueue.isEmpty) {
      return const Center(child: Text("Hôm nay chưa có đơn gọi món nào."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.orderQueue.length,
      itemBuilder: (context, idx) {
        final order = widget.orderQueue[idx];
        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AromaColors.coffeeCardBorder)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Đơn ${order.id}", style: const TextStyle(fontWeight: FontWeight.bold, color: AromaColors.coffeeTextDark, fontSize: 13)),
                    Chip(
                      backgroundColor: order.status.color.withOpacity(0.12),
                      side: BorderSide.none,
                      label: Text(order.status.vietnamese, style: TextStyle(color: order.status.color, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                Text("Bàn: ${order.tableLabel} • Thời điểm: ${order.timestamp}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const Divider(),
                // Order elements
                Column(
                  children: order.items.map((cartItem) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${cartItem.quantity}x ${cartItem.menuItem.name}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          Text("\$${(cartItem.menuItem.price * cartItem.quantity).toStringAsFixed(2)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                if (order.note.isNotEmpty) ...[
                  const Divider(),
                  Text("Ghi chú khách hàng: \"${order.note}\"", style: const TextStyle(color: AromaColors.coffeeGold, fontSize: 11, fontStyle: FontStyle.italic)),
                ],
                const Divider(),
                // Control Status Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order.status == OrderStatus.pending)
                      ElevatedButton(
                        onPressed: () => widget.onUpdateOrderStatus(order.id, OrderStatus.preparing),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white),
                        child: const Text("Xác nhận chế biến"),
                      )
                    else if (order.status == OrderStatus.preparing)
                      ElevatedButton(
                        onPressed: () => widget.onUpdateOrderStatus(order.id, OrderStatus.ready),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white),
                        child: const Text("Hoàn thành món"),
                      )
                    else if (order.status == OrderStatus.ready)
                      ElevatedButton(
                        onPressed: () => widget.onUpdateOrderStatus(order.id, OrderStatus.paid),
                        style: ElevatedButton.styleFrom(backgroundColor: AromaColors.coffeeGold, foregroundColor: Colors.white),
                        child: const Text("Thanh toán thành công"),
                      )
                    else
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AromaColors.successGreen, size: 16),
                          SizedBox(width: 6),
                          Text("Đã thanh toán kết đơn", style: TextStyle(color: AromaColors.successGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuManagementSubTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.menuItems.length,
      itemBuilder: (context, idx) {
        final item = widget.menuItems[idx];
        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AromaColors.coffeeCardBorder)),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Text(item.emoji, style: const TextStyle(fontSize: 24)),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text(item.vietnameseName, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: Switch(
              value: item.isAvailable,
              activeColor: AromaColors.successGreen,
              onChanged: (val) {
                widget.onToggleAvailability(item.id);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTablesVisualSubTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
      itemCount: systemTables.length,
      itemBuilder: (context, idx) {
        final table = systemTables[idx];
        final isActive = widget.orderQueue.any((o) => o.tableId == table.id && o.status != OrderStatus.paid);

        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AromaColors.coffeeCardBorder)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(table.label, style: const TextStyle(fontWeight: FontWeight.bold, color: AromaColors.coffeeTextDark, fontSize: 13)),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isActive ? AromaColors.successGreen : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Text(table.description, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AromaColors.coffeePrimary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isActive ? "ĐANG PHỤC VỤ" : "TRỐNG",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AromaColors.coffeePrimary : Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildArchitectureDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "C# ASP.NET Core & SignalR Hub Synchronizer",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AromaColors.coffeeTextDark),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AromaColors.coffeeDarkAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "public class OrderHub : Hub {\n"
              "    public async Task UpdateOrderStatus(string orderId, string status) {\n"
              "        await Clients.All.SendAsync(\"ReceiveOrderUpdate\", orderId, status);\n"
              "    }\n"
              "}",
              style: TextStyle(color: Colors.lightGreenAccent, fontFamily: 'Monospace', fontSize: 10),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Chi tiết công nghệ phía Backend:\n"
            "• Entity Framework Core kết nối SQLite lưu trữ thông tin thực đơn lâu dài.\n"
            "• Sử dụng SignalR thời gian thực để truyền tín hiệu trạng thái món ăn tự động phản hồi tức thời từ phía Crew của Bếp đến màn hình khách hàng.",
            style: TextStyle(fontSize: 11, color: AromaColors.coffeeTextSub, height: 1.4),
          )
        ],
      ),
    );
  }
}

// =========================================================================
// DIALOGS & SHEET HELPERS
// =========================================================================

class MockQrScannerDialog extends StatelessWidget {
  final Function(String, String) onScanned;

  const MockQrScannerDialog({super.key, required this.onScanned});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: AromaColors.coffeeBackground,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Quét mã QR gọi món", style: TextStyle(fontWeight: FontWeight.bold, color: AromaColors.coffeeTextDark, fontSize: 16)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.Center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, color: AromaColors.coffeeGold, size: 56),
                  SizedBox(height: 8),
                  Text("MÔ PHỎNG CAMERA...", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Chọn một Bàn để mô phỏng quét mã QR thành công:",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AromaColors.coffeeTextSub),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _tableBtn(context, "03", "Bàn #03")),
                const SizedBox(width: 8),
                Expanded(child: _tableBtn(context, "08", "Bàn #08")),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _tableBtn(context, "12", "Bàn #12")),
                const SizedBox(width: 8),
                Expanded(child: _tableBtn(context, "15", "Bàn #15")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _tableBtn(BuildContext context, String tableId, String tableLabel) {
    return ElevatedButton(
      onPressed: () {
        onScanned(tableId, tableLabel);
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(backgroundColor: AromaColors.coffeePrimary, foregroundColor: Colors.white),
      child: Text(tableLabel, style: const TextStyle(fontSize: 11)),
    );
  }
}

class ShoppingCartSheet extends StatelessWidget {
  final List<CartItem> cartItems;
  final String selectedTableLabel;
  final double subtotal;
  final double taxAndService;
  final double total;
  final String note;
  final ValueChanged<String> onNoteChange;
  final Function(MenuItem) onIncrease;
  final Function(MenuItem) onDecrease;
  final VoidCallback onCheckout;

  const ShoppingCartSheet({
    super.key,
    required this.cartItems,
    required this.selectedTableLabel,
    required this.subtotal,
    required this.taxAndService,
    required this.total,
    required this.note,
    required this.onNoteChange,
    required this.onIncrease,
    required this.onDecrease,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Giỏ Hàng [$selectedTableLabel]",
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AromaColors.coffeeTextDark),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          if (cartItems.isEmpty)
            const SizedBox(
              height: 100,
              child: Center(child: Text("Giỏ hàng của bạn đang trống trơn!")),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cartItems.length,
                itemBuilder: (context, idx) {
                  final item = cartItems[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Text("${item.quantity}x", style: const TextStyle(fontWeight: FontWeight.bold, color: AromaColors.coffeePrimary)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.menuItem.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                        Row(
                          children: [
                            IconButton(onPressed: () => onDecrease(item.menuItem), icon: const Icon(Icons.remove, size: 16)),
                            IconButton(onPressed: () => onIncrease(item.menuItem), icon: const Icon(Icons.add, size: 16)),
                          ],
                        ),
                        Text("\$${(item.menuItem.price * item.quantity).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
          TextField(
            onChanged: onNoteChange,
            decoration: const InputDecoration(
              hintText: "Ghi chú món đặc biệt (Ví dụ: Không hành, không đá...)",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Tổng phụ:"), Text("\$${subtotal.toStringAsFixed(2)}")]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("VAT & Phí dịch vụ (10%):"), Text("\$${taxAndService.toStringAsFixed(2)}")]),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tổng cộng:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AromaColors.coffeePrimary)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: cartItems.isEmpty ? null : onCheckout,
              style: ElevatedButton.styleFrom(backgroundColor: AromaColors.coffeePrimary, foregroundColor: Colors.white),
              child: const Text("Xác nhận gửi yêu cầu bếp", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

class OrderTrackerDialog extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onCancel;

  const OrderTrackerDialog({super.key, required this.order, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Đơn hàng ${order.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AromaColors.coffeeTextDark)),
                    Text(order.tableLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Stepper
            _stepRow(context, "1. Gửi Đơn Bếp", "Chờ xác nhận", order.status.index >= 0),
            _stepRow(context, "2. Chế Biến", "Đang được làm nóng", order.status.index >= 1),
            _stepRow(context, "3. Sẵn Sàng", "Chờ nhân viên bưng lên bàn", order.status.index >= 2),
            _stepRow(context, "4. Hoàn Thành", "Đã thanh toán kết thúc", order.status.index >= 3),

            const SizedBox(height: 16),
            if (order.status == OrderStatus.pending)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    onCancel();
                    Navigator.pop(context);
                  },
                  child: const Text("Hủy yêu cầu món ăn", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _stepRow(BuildContext context, String title, String sub, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.radio_button_off,
            color: isActive ? AromaColors.successGreen : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 12, color: isActive ? AromaColors.coffeeTextDark : Colors.grey)),
              Text(sub, style: TextStyle(fontSize: 10, color: isActive ? Colors.black54 : Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}
