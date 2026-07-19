import 'dart:async';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'models/item_model.dart';
import 'models/account_model.dart';
import 'models/feedback_model.dart';
import 'services/api_service.dart';
import 'services/signalr_service.dart';
import 'screens/login_screen.dart';
import 'screens/staff_screen.dart';
import 'screens/admin_screen.dart';

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
          secondary: AromaColors.coffeeAccent,
          surface: AromaColors.coffeeSurface,
          background: AromaColors.coffeeBackground,
          error: AromaColors.errorRed,
        ),
        textTheme: TextTheme(
          displayLarge: AromaTypography.h1,
          displayMedium: AromaTypography.h2,
          displaySmall: AromaTypography.h3,
          bodyLarge: AromaTypography.bodyLarge,
          bodyMedium: AromaTypography.bodyMedium,
          bodySmall: AromaTypography.bodySmall,
          labelLarge: AromaTypography.buttonText,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AromaColors.coffeePrimary,
            foregroundColor: Colors.white,
            textStyle: AromaTypography.buttonText,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AromaStyles.radiusMedium,
            ),
            elevation: 0,
          ),
        ),
        cardTheme: CardThemeData(
          color: AromaColors.coffeeSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AromaStyles.radiusMedium,
            side: const BorderSide(color: AromaColors.coffeeCardBorder, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AromaColors.coffeeCardLightBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: AromaStyles.radiusSmall,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AromaStyles.radiusSmall,
            borderSide: const BorderSide(color: AromaColors.coffeeCardBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AromaStyles.radiusSmall,
            borderSide: const BorderSide(color: AromaColors.coffeePrimary, width: 2),
          ),
          labelStyle: AromaTypography.bodyMedium,
          hintStyle: AromaTypography.bodyMedium.copyWith(color: AromaColors.coffeeTextSub),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AromaColors.coffeeSurface,
          foregroundColor: AromaColors.coffeeTextDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AromaTypography.h2,
          iconTheme: const IconThemeData(color: AromaColors.coffeeTextDark),
        ),
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
  bool _isLoggedIn = false;
  AccountModel? _currentUser;

  List<MenuItem> _menuItems = [];
  List<OrderModel> _orderQueue = [];
  List<TableModel> _tables = [];
  List<AccountModel> _staffs = [];
  List<FeedbackModel> _feedbacks = [];

  // Đếm đơn hoàn thành hôm nay (real-time qua SignalR)
  int get _completedTodayCount {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _orderQueue
        .where((o) =>
            o.status == OrderStatus.paid &&
            o.createdAt.toLocal().isAfter(todayStart))
        .length;
  }

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  // Complete data reload (Menu, orders, tables)
  Future<void> _loadBackendData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final menu = await ApiService.fetchMenuItems();
      final orders = await ApiService.fetchOrderQueue();
      final tables = await ApiService.fetchTables();
      final staffs = _currentRole == UserRole.admin
          ? await ApiService.fetchStaffs()
          : <AccountModel>[];
      final feedbacks = _currentRole == UserRole.admin
          ? await ApiService.fetchFeedbacks()
          : <FeedbackModel>[];

      setState(() {
        _menuItems = menu;
        _orderQueue = orders;
        _tables = tables;
        _staffs = staffs;
        _feedbacks = feedbacks;
      });
    } catch (e) {
      debugPrint('Error loading backend data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleManualRefresh() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text("Đang tải dữ liệu..."),
          ],
        ),
        duration: Duration(milliseconds: 800),
        backgroundColor: AromaColors.coffeePrimary,
      ),
    );
    await _loadBackendData();
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Đã cập nhật dữ liệu mới nhất!"),
          duration: Duration(seconds: 1),
          backgroundColor: AromaColors.successGreen,
        ),
      );
    }
  }

  // --- ACTIONS ---

  // Kitchen Status advanced progression
  Future<void> _updateOrderStatus(int orderId, OrderStatus status) async {
    // Cập nhật local state trước để UI phản hồi nhanh
    setState(() {
      final idx = _orderQueue.indexWhere((o) => o.orderId == orderId);
      if (idx != -1) {
        _orderQueue[idx] = _orderQueue[idx].copyWith(status: status);
      }
      if (status == OrderStatus.paid) {
        final order = _orderQueue[idx];
        final tIdx = _tables.indexWhere((t) => t.tableId == order.tableId);
        if (tIdx != -1) {
          _tables[tIdx] = _tables[tIdx].copyWith(status: TableStatus.available);
        }
      }
    });

    final success = await ApiService.updateOrderStatus(orderId, status);
    if (success) {
      _loadBackendData();
    }
  }

  Future<void> _updateOrderItemStatus(int orderId, int itemId, OrderItemStatus status) async {
    setState(() {
      final oIdx = _orderQueue.indexWhere((o) => o.orderId == orderId);
      if (oIdx != -1) {
        final order = _orderQueue[oIdx];
        final iIdx = order.items.indexWhere((i) => i.orderItemId == itemId);
        if (iIdx != -1) {
          final newItems = List<OrderItemModel>.from(order.items);
          newItems[iIdx] = newItems[iIdx].copyWith(status: status);
          _orderQueue[oIdx] = order.copyWith(items: newItems);
        }
      }
    });
    final success = await ApiService.updateOrderItemStatus(orderId, itemId, status);
    if (success) {
      _loadBackendData();
    }
  }

  // Modify item availability
  Future<void> _toggleAvailability(int itemId) async {
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
  Future<void> _deleteMenuItem(int id) async {
    final success = await ApiService.deleteMenuItem(id);
    if (success) {
      _loadBackendData();
    }
  }

  // Table Management Functions
  Future<void> _addTable(TableModel table) async {
    final success = await ApiService.createTable(table);
    if (success) {
      _loadBackendData();
    }
  }

  Future<void> _updateTable(TableModel table) async {
    final success = await ApiService.updateTable(table);
    if (success) {
      _loadBackendData();
    }
  }

  Future<void> _deleteTable(int tableId) async {
    final success = await ApiService.deleteTable(tableId);
    if (success) {
      _loadBackendData();
    }
  }

  void _exportQrCode(TableModel table) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Mã QR của ${table.label} đã được lưu!'),
        backgroundColor: AromaColors.successGreen,
      ),
    );
  }

  // Staff Management Functions (Admin Only)
  Future<void> _createStaff(AccountModel staff, String password) async {
    final success = await ApiService.createStaff(staff, password);
    if (success) {
      _loadBackendData();
    }
  }

  Future<void> _updateStaff(AccountModel staff) async {
    final success = await ApiService.updateStaff(staff);
    if (success) {
      _loadBackendData();
    }
  }

  Future<void> _deleteStaff(int accountId) async {
    final success = await ApiService.deleteStaff(accountId);
    if (success) {
      _loadBackendData();
    }
  }

  Future<void> _toggleFeedbackVisibility(int feedbackId) async {
    final success = await ApiService.toggleFeedbackVisibility(feedbackId);
    if (success) {
      _loadBackendData();
    }
  }

  void _handleLogin(AccountModel account) {
    setState(() {
      _isLoggedIn = true;
      _currentUser = account;
    });

    // Khởi tạo SignalR ngay sau khi login thành công.
    // Dữ liệu chỉ được tải sau khi SignalR kết nối thành công (khi server đã hoàn thành khởi động/thức giấc)
    // để tránh việc các API request bị timeout (30s) trong quá trình cold start của Render.
    SignalRService.init(
      () {
        _loadBackendData();
      },
      onOrderStatusUpdated: (orderId, newStatus) async {
        final status = newStatus.toLowerCase();
        final orderStatus = OrderStatus.fromString(status);

        // Cập nhật local state ngay lập tức để UI đóng lại nhanh và bàn trống ngay
        if (mounted) {
          setState(() {
            final idx = _orderQueue.indexWhere((o) => o.orderId == orderId);
            if (idx != -1) {
              _orderQueue[idx] = _orderQueue[idx].copyWith(status: orderStatus);
            }
            if (orderStatus == OrderStatus.paid) {
              final order = _orderQueue.firstWhere(
                (o) => o.orderId == orderId,
                orElse: () => OrderModel(orderId: -1, tableId: -1),
              );
              if (order.orderId != -1) {
                final tIdx = _tables.indexWhere((t) => t.tableId == order.tableId);
                if (tIdx != -1) {
                  _tables[tIdx] = _tables[tIdx].copyWith(status: TableStatus.available);
                }
              }
            }
          });
        }

        // Reload để cập nhật danh sách đơn
        _loadBackendData();
      },
      onConnected: () {
        _loadBackendData();
      },
    );
  }

  UserRole get _currentRole {
    if (_currentUser == null) return UserRole.staff;
    return _currentUser!.role == AccountRole.admin
        ? UserRole.admin
        : UserRole.staff;
  }

  // --- SCREEN RENDERING CONTROLLER ---
  @override
  Widget build(BuildContext context) {
    // Show login if not logged in
    if (!_isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: _handleLogin,
      );
    }

    if (_currentRole == UserRole.admin) {
      return AdminScreen(
        orders: _orderQueue,
        menuItems: _menuItems,
        tables: _tables,
        staffs: _staffs,
        feedbacks: _feedbacks,
        completedTodayCount: _completedTodayCount,
        onUpdateOrderStatus: _updateOrderStatus,
        onUpdateOrderItemStatus: _updateOrderItemStatus,
        onToggleAvailability: _toggleAvailability,
        onCreateMenuItem: _createMenuItem,
        onUpdateMenuItem: _updateMenuItem,
        onDeleteMenuItem: _deleteMenuItem,
        onAddTable: _addTable,
        onUpdateTable: _updateTable,
        onDeleteTable: _deleteTable,
        onCreateStaff: _createStaff,
        onUpdateStaff: _updateStaff,
        onDeleteStaff: _deleteStaff,
        onToggleFeedbackVisibility: _toggleFeedbackVisibility,
        onExportQrCode: _exportQrCode,
        currentUser: _currentUser,
        onBackToGateway: () {
          SignalRService.disconnect();
          ApiService.clearToken();
          setState(() {
            _isLoggedIn = false;
            _currentUser = null;
          });
        },
        onRefreshData: _handleManualRefresh,
      );
    }

    // Show StaffScreen if logged in
    return StaffScreen(
      orders: _orderQueue,
      menuItems: _menuItems,
      tables: _tables,
      onUpdateOrderStatus: _updateOrderStatus,
      onUpdateOrderItemStatus: _updateOrderItemStatus,
      onToggleAvailability: _toggleAvailability,
      onUpdateTable: _updateTable,
      onExportQrCode: _exportQrCode,
      currentUser: _currentUser,
      onBackToGateway: () {
        SignalRService.disconnect();
        ApiService.clearToken();
        setState(() {
          _isLoggedIn = false;
          _currentUser = null;
        });
      },
      onRefreshData: _handleManualRefresh,
    );
  }
}
