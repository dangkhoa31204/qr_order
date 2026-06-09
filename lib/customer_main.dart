import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'constants.dart';
import 'models/item_model.dart';
import 'services/api_service.dart';
import 'screens/customer_screen.dart';

void main() {
  // Khi build ra web app, lấy tableId từ URL query parameters
  // Ví dụ: https://qr-order-api.onrender.com/order?tableId=1
  int tableId = 1; // Giá trị mặc định
  if (kIsWeb) {
    final uri = Uri.base;
    tableId = int.tryParse(uri.queryParameters['tableId'] ?? '') ?? 1;
  }
  runApp(CustomerApp(tableId: tableId));
}

class CustomerApp extends StatelessWidget {
  final int tableId;
  const CustomerApp({super.key, required this.tableId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aroma Bistro - Menu Khách',
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
      home: CustomerMainScreen(tableId: tableId),
    );
  }
}

class CustomerMainScreen extends StatefulWidget {
  final int tableId;
  const CustomerMainScreen({super.key, required this.tableId});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  String _selectedTableLabel = "";
  List<MenuItem> _menuItems = [];
  List<OrderModel> _orderQueue = [];
  OrderModel? _activeCustomerOrder;

  final Map<int, int> _cart = {};

  bool _isLoading = false;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _selectedTableLabel = "Bàn #${widget.tableId}";
    _loadBackendData();
    _syncTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _syncOrdersOnly();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBackendData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final menu = await ApiService.fetchMenuItems();
      final orders = await ApiService.fetchOrderQueue();

      if (mounted) {
        setState(() {
          _menuItems = menu;
          _orderQueue = orders;
          _syncActiveCustomerOrder();
        });
      }
    } catch (e) {
      print("Error loading backend data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _syncOrdersOnly() async {
    try {
      final orders = await ApiService.fetchOrderQueue();
      final menu = await ApiService.fetchMenuItems();
      if (mounted) {
        setState(() {
          _orderQueue = orders;
          _menuItems = menu;
          _cart.removeWhere((itemId, _) {
            final item = _menuItems.where((it) => it.menuItemId == itemId);
            return item.isEmpty || !item.first.isAvailable;
          });
          _syncActiveCustomerOrder();
        });
      }
    } catch (_) {}
  }

  void _syncActiveCustomerOrder() {
    if (_activeCustomerOrder != null) {
      final updated = _orderQueue.firstWhere(
        (o) => o.orderId == _activeCustomerOrder!.orderId,
        orElse: () => _activeCustomerOrder!,
      );
      if (updated.status == OrderStatus.paid ||
          updated.status == OrderStatus.cancelled) {
        _activeCustomerOrder = null; // cleared when paid or cancelled
      } else {
        _activeCustomerOrder = updated;
      }
    } else {
      // Look for any pending/preparing/ready order belonging to the current selected table
      final tableActiveOrders = _orderQueue
          .where((o) =>
              o.tableId == widget.tableId &&
              o.status != OrderStatus.paid &&
              o.status != OrderStatus.cancelled)
          .toList();
      if (tableActiveOrders.isNotEmpty) {
        // use latest
        _activeCustomerOrder = tableActiveOrders.last;
      }
    }
  }

  void _addCartItem(MenuItem item) {
    if (!item.isAvailable) return;
    setState(() {
      final count = _cart[item.menuItemId] ?? 0;
      _cart[item.menuItemId] = count + 1;
    });
  }

  void _removeCartItem(MenuItem item) {
    setState(() {
      final count = _cart[item.menuItemId] ?? 0;
      if (count > 1) {
        _cart[item.menuItemId] = count - 1;
      } else {
        _cart.remove(item.menuItemId);
      }
    });
  }

  Future<void> _submitCustomerOrder(
      int tableId, List<OrderItemModel> items, String note) async {
    final availableItems = items.where((it) {
      final menuItem = _menuItems.where((m) => m.menuItemId == it.menuItemId);
      return menuItem.isNotEmpty && menuItem.first.isAvailable;
    }).toList();
    if (availableItems.length != items.length || availableItems.isEmpty) {
      setState(() {
        _cart.removeWhere((itemId, _) {
          final item = _menuItems.where((it) => it.menuItemId == itemId);
          return item.isEmpty || !item.first.isAvailable;
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Một số món đã hết. Vui lòng kiểm tra lại giỏ hàng."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final orderId = DateTime.now().microsecondsSinceEpoch % 900000;

    double totalAmount = 0;
    for (var it in availableItems) {
      totalAmount += it.unitPrice * it.quantity;
    }
    totalAmount *= 1.10; // add 10% tax/service

    final customOrderObj = OrderModel(
      orderId: orderId,
      tableId: tableId,
      items: availableItems,
      status: OrderStatus.pending,
      totalAmount: totalAmount,
      note: note,
      createdAt: DateTime.now(),
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
          content: Text("🎉 Đã gửi đơn hàng thành công đến Bếp!"),
          backgroundColor: AromaColors.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "❌ Không thể kết nối đến máy chủ. Đang sử dụng chế độ cục bộ mô phỏng."),
          backgroundColor: AromaColors.pendingOrange,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _cancelCustomerOrder() async {
    if (_activeCustomerOrder == null) return;
    final id = _activeCustomerOrder!.orderId;

    final success =
        await ApiService.updateOrderStatus(id, OrderStatus.cancelled);

    if (success) {
      setState(() {
        final idx = _orderQueue.indexWhere((o) => o.orderId == id);
        if (idx != -1) {
          _orderQueue[idx] =
              _orderQueue[idx].copyWith(status: OrderStatus.cancelled);
        }
        _activeCustomerOrder = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🛑 Đã hủy đơn hàng thành công."),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Không thể hủy đơn hàng lúc này."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScreen(
      cart: _cart,
      onAddCart: _addCartItem,
      onRemoveCart: _removeCartItem,
      onBackToGateway: () {
        // Đối với Customer flow độc lập, nút back có thể chỉ làm mới giỏ hàng thay vì quay về role selection
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đã làm mới phiên gọi món."),
            backgroundColor: AromaColors.coffeePrimary,
          ),
        );
        setState(() {
          _cart.clear();
        });
      },
      selectedTableId: widget.tableId,
      selectedTableLabel: _selectedTableLabel,
      menuItems: _menuItems,
      activeOrder: _activeCustomerOrder,
      onSubmitOrder: _submitCustomerOrder,
      onCancelActiveOrder: _cancelCustomerOrder,
    );
  }
}
