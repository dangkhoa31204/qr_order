import 'dart:async';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'models/item_model.dart';
import 'services/api_service.dart';
import 'screens/role_selection_screen.dart';
import 'screens/customer_screen.dart';
import 'screens/staff_screen.dart';
import 'widgets/mock_qr_dialog.dart';

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
        primaryColor: AromaColors.coffeePrimary,
        scaffoldBackgroundColor: AromaColors.coffeeBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AromaColors.coffeePrimary,
          primary: AromaColors.coffeePrimary,
          background: AromaColors.coffeeBackground,
        ),
        fontFamily: 'Serif',
      ),
      home: const MainGateScreen(),
    );
  }
}

class MainGateScreen extends StatefulWidget {
  const MainGateScreen({super.key});

  @override
  State<MainGateScreen> createState() => _MainGateScreenState();
}

class _MainGateScreenState extends State<MainGateScreen> {
  // App dynamic states
  UserRole _currentRole = UserRole.undecided;
  String _selectedTableId = "08";
  String _selectedTableLabel = "Bàn #08";

  List<MenuItem> _menuItems = [];
  List<OrderModel> _orderQueue = [];
  OrderModel? _activeCustomerOrder;

  // Local cart cache: MenuItemID -> Quantity
  final Map<String, int> _cart = {};

  bool _isLoading = false;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _loadBackendData();
    // Periodically sync every 2 seconds to simulate real-time sockets (SignalR / WebSockets)
    _syncTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _syncOrdersOnly();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  // Complete data reload (Menu, orders, tables)
  Future<void> _loadBackendData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final menu = await ApiService.fetchMenuItems();
      final orders = await ApiService.fetchOrderQueue();

      setState(() {
        _menuItems = menu;
        _orderQueue = orders;

        // Auto-match active customer order
        _syncActiveCustomerOrder();
      });
    } catch (e) {
      print("Error loading backend data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Light-weight sync for order flow changes in real-time
  Future<void> _syncOrdersOnly() async {
    try {
      final orders = await ApiService.fetchOrderQueue();
      if (mounted) {
        setState(() {
          _orderQueue = orders;
          _syncActiveCustomerOrder();
        });
      }
    } catch (_) {}
  }

  void _syncActiveCustomerOrder() {
    if (_activeCustomerOrder != null) {
      final updated = _orderQueue.firstWhere(
        (o) => o.id == _activeCustomerOrder!.id,
        orElse: () => _activeCustomerOrder!,
      );
      if (updated.status == OrderStatus.paid) {
        _activeCustomerOrder = null; // cleared when paid
      } else {
        _activeCustomerOrder = updated;
      }
    } else {
      // Look for any pending/preparing/ready order belonging to the current selected table
      final tableActiveOrders = _orderQueue.where((o) => o.tableId == _selectedTableId && o.status != OrderStatus.paid).toList();
      if (tableActiveOrders.isNotEmpty) {
        // use latest
        _activeCustomerOrder = tableActiveOrders.last;
      }
    }
  }

  // --- ACTIONS ---

  // Add cart item
  void _addCartItem(MenuItem item) {
    setState(() {
      final count = _cart[item.id] ?? 0;
      _cart[item.id] = count + 1;
    });
  }

  // Remove cart item
  void _removeCartItem(MenuItem item) {
    setState(() {
      final count = _cart[item.id] ?? 0;
      if (count > 1) {
        _cart[item.id] = count - 1;
      } else {
        _cart.remove(item.id);
      }
    });
  }

  // Checkout submission
  Future<void> _submitCustomerOrder(String tableId, List<CartItem> items, String note) async {
    final orderId = "B$tableId-${1000 + (DateTime.now().microsecondsSinceEpoch % 9000)}";
    final customOrderObj = OrderModel(
      id: orderId,
      tableId: tableId,
      items: items,
      status: OrderStatus.pending,
      timeMinutes: 5 + (DateTime.now().microsecondsSinceEpoch % 15),
      timestamp: "Vừa xong",
      note: note,
      tableLabel: _selectedTableLabel,
    );

    setState(() => _isLoading = true);
    final success = await ApiService.submitOrder(customOrderObj);
    if (success) {
      setState(() {
        _cart.clear();
        _activeCustomerOrder = customOrderObj;
        _orderQueue.add(customOrderObj);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Đã gửi đơn hàng thành công đến Bếp Co-working!"),
          backgroundColor: AromaColors.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Không thể kết nối đến máy chủ. Đang sử dụng chế độ cục bộ mô phỏng."),
          backgroundColor: AromaColors.pendingOrange,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  // Cancel order in pending state
  Future<void> _cancelCustomerOrder() async {
    if (_activeCustomerOrder == null) return;
    final id = _activeCustomerOrder!.id;
    setState(() {
      _orderQueue.removeWhere((o) => o.id == id);
      _activeCustomerOrder = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🛑 Đã hủy đơn hàng thành công."),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // Kitchen Status advanced progression
  Future<void> _updateOrderStatus(String orderId, OrderStatus status) async {
    final success = await ApiService.updateOrderStatus(orderId, status);
    if (success) {
      _loadBackendData();
    }
  }

  // Modify item availability
  Future<void> _toggleAvailability(String itemId) async {
    final success = await ApiService.toggleMenuItemAvailability(itemId);
    if (success) {
      _loadBackendData();
    }
  }

  // Add item
  Future<void> _createMenuItem(MenuItem item) async {
    final success = await ApiService.createMenuItem(item);
    if (success) {
      _loadBackendData();
    }
  }

  // Edit item
  Future<void> _updateMenuItem(MenuItem item) async {
    final success = await ApiService.updateMenuItem(item);
    if (success) {
      _loadBackendData();
    }
  }

  // Delete item
  Future<void> _deleteMenuItem(String id) async {
    final success = await ApiService.deleteMenuItem(id);
    if (success) {
      _loadBackendData();
    }
  }

  // --- POPUPS & API OPTION DIALOG ---
  void _showConfigureApiDialog() {
    final controller = TextEditingController(text: ApiService.baseUrl);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Cấu hình C# API Server",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Nhập địa chỉ máy chủ ASP.NET Core API cục bộ của bạn để đồng bộ dữ liệu thật:",
                style: TextStyle(fontSize: 12, color: AromaColors.coffeeTextSub),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "API URL",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                style: const TextStyle(fontSize: 13, color: AromaColors.coffeeTextDark),
              ),
              const SizedBox(height: 12),
              const Text(
                "Gợi ý kết nối:\n• localhost PC: http://10.0.2.2:5000\n• Lan IP: http://192.168.1.XX:5000\n• Web live service: URL công khai của bạn",
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy bỏ", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  ApiService.baseUrl = controller.text.trim();
                });
                Navigator.pop(context);
                _loadBackendData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Kính chào! Đã chuyển hướng máy chủ sang: ${ApiService.baseUrl}"),
                    backgroundColor: AromaColors.coffeePrimary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AromaColors.coffeePrimary),
              child: const Text("Lưu Kết Nối", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  void _showQrScannerSimulator() {
    showDialog(
      context: context,
      builder: (context) {
        return MockQrScannerDialog(
          onClose: () => Navigator.pop(context),
          onScanned: (tableId, tableLabel) {
            setState(() {
              _selectedTableId = tableId;
              _selectedTableLabel = tableLabel;
              // Clean customer cart when moving table
              _cart.clear();
              _syncActiveCustomerOrder();
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("📷 Quét thành công! Đã đăng kí thực đơn tại: $tableLabel"),
                backgroundColor: AromaColors.successGreen,
              ),
            );
          },
        );
      },
    );
  }

  // --- SCREEN RENDERING CONTROLLER ---
  @override
  Widget build(BuildContext context) {
    switch (_currentRole) {
      case UserRole.undecided:
        return RoleSelectionScreen(
          onRoleSelected: (role) {
            setState(() {
              _currentRole = role;
              _syncActiveCustomerOrder();
            });
          },
          onConfigureApi: _showConfigureApiDialog,
        );

      case UserRole.customer:
        return CustomerScreen(
          cart: _cart,
          onAddCart: _addCartItem,
          onRemoveCart: _removeCartItem,
          onOpenQrScanner: _showQrScannerSimulator,
          onBackToGateway: () {
            setState(() {
              _currentRole = UserRole.undecided;
            });
          },
          selectedTableId: _selectedTableId,
          selectedTableLabel: _selectedTableLabel,
          menuItems: _menuItems,
          activeOrder: _activeCustomerOrder,
          onSubmitOrder: _submitCustomerOrder,
          onCancelActiveOrder: _cancelCustomerOrder,
        );

      case UserRole.staff:
        return StaffScreen(
          orders: _orderQueue,
          menuItems: _menuItems,
          onUpdateOrderStatus: _updateOrderStatus,
          onToggleAvailability: _toggleAvailability,
          onCreateMenuItem: _createMenuItem,
          onUpdateMenuItem: _updateMenuItem,
          onDeleteMenuItem: _deleteMenuItem,
          onBackToGateway: () {
            setState(() {
              _currentRole = UserRole.undecided;
            });
          },
        );
    }
  }
}
