import 'dart:async';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'models/item_model.dart';
import 'services/api_service.dart';
import 'screens/customer_screen.dart';

void main() {
  // Trong thực tế khi build ra web app, ID bàn có thể lấy từ URL query parameters
  // Ví dụ: Uri.base.queryParameters['table'] ?? '08'
  runApp(const CustomerApp(tableId: '08'));
}

class CustomerApp extends StatelessWidget {
  final String tableId;
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
  final String tableId;
  const CustomerMainScreen({super.key, required this.tableId});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  String _selectedTableLabel = "";
  List<MenuItem> _menuItems = [];
  List<OrderModel> _orderQueue = [];
  OrderModel? _activeCustomerOrder;

  final Map<String, int> _cart = {};

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
      final tableActiveOrders = _orderQueue
          .where((o) =>
              o.tableId == widget.tableId && o.status != OrderStatus.paid)
          .toList();
      if (tableActiveOrders.isNotEmpty) {
        // use latest
        _activeCustomerOrder = tableActiveOrders.last;
      }
    }
  }

  void _addCartItem(MenuItem item) {
    setState(() {
      final count = _cart[item.id] ?? 0;
      _cart[item.id] = count + 1;
    });
  }

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

  Future<void> _submitCustomerOrder(
      String tableId, List<CartItem> items, String note) async {
    final orderId =
        "B$tableId-${1000 + (DateTime.now().microsecondsSinceEpoch % 9000)}";
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
