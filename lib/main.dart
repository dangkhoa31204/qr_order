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
          surface: AromaColors.coffeeBackground,
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
  bool _isLoggedIn = false;
  AccountModel? _currentUser;

  List<MenuItem> _menuItems = [];
  List<OrderModel> _orderQueue = [];
  List<TableModel> _tables = [];
  List<AccountModel> _staffs = [];
  List<FeedbackModel> _feedbacks = [];

  // Đếm đơn hoàn thành hôm nay (real-time qua SignalR)
  int _completedTodayCount = 0;

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
    final success = await ApiService.updateOrderStatus(orderId, status);
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
      _completedTodayCount = 0;
    });
    _loadBackendData();
    // Khởi tạo SignalR ngay sau khi login thành công
    SignalRService.init(
      () {
        _loadBackendData();
      },
      onOrderStatusUpdated: (orderId, newStatus) {
        // Tăng counter real-time khi staff hoàn thành đơn hàng
        final status = newStatus.toLowerCase();
        if (status == 'paid' || status == 'completed' || status == '4') {
          if (mounted) {
            setState(() => _completedTodayCount++);
          }
        }
        // Reload để cập nhật danh sách đơn
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
            _completedTodayCount = 0;
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
