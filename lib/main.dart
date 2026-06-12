import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'constants.dart';
import 'models/item_model.dart';
import 'models/account_model.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/staff_screen.dart';
import 'customer_main.dart'; // Thêm để chạy luồng Customer khi cần

void main() {
  int? webTableId;
  if (kIsWeb) {
    final uri = Uri.base;
    webTableId = int.tryParse(uri.queryParameters['tableId'] ?? '');
  }

  if (webTableId != null) {
    // Nếu có tableId trên URL, chạy luôn ứng dụng gọi món của khách
    runApp(CustomerApp(tableId: webTableId));
  } else {
    // Nếu không có, chạy ứng dụng chính (Admin / Staff)
    runApp(const AromaBistroApp());
  }
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
  List<AccountModel> _staffAccounts = [];

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    // TODO: Connect to backend WebSocket and call _syncOrdersOnly() when notified
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Complete data reload (Menu, orders, tables)
  Future<void> _loadBackendData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final menu = await ApiService.fetchMenuItems();
      final orders = await ApiService.fetchOrderQueue();
      final tables = await ApiService.fetchTables();
      final staffAccounts = await ApiService.fetchStaffAccounts();

      setState(() {
        _menuItems = menu;
        _orderQueue = orders;
        _tables = tables;
        _staffAccounts = staffAccounts;
      });
    } catch (e) {
      print("Error loading backend data: $e");
    } finally {
      setState(() => _isLoading = false);
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

  Future<bool> _createStaffAccount({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    final created = await ApiService.createStaffAccount(
      username: username,
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
    if (created != null) {
      await _loadBackendData();
      return true;
    }
    return false;
  }

  Future<bool> _updateStaffAccount(AccountModel account) async {
    final updated = await ApiService.updateAccount(account);
    if (updated != null) {
      await _loadBackendData();
      return true;
    }
    return false;
  }

  Future<bool> _deleteStaffAccount(int accountId) async {
    final success = await ApiService.deleteAccount(accountId);
    if (success) {
      await _loadBackendData();
    }
    return success;
  }

  void _exportQrCode(TableModel table) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Mã QR của ${table.label} đã được lưu!"),
        backgroundColor: AromaColors.successGreen,
      ),
    );
  }

  void _handleLogin(AccountModel account) {
    setState(() {
      _isLoggedIn = true;
      _currentUser = account;
    });
    _loadBackendData(); // Tải dữ liệu ngay sau khi đăng nhập thành công
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

    // Show StaffScreen if logged in
    return StaffScreen(
      orders: _orderQueue,
      menuItems: _menuItems,
      tables: _tables,
      staffAccounts: _staffAccounts,
      onUpdateOrderStatus: _updateOrderStatus,
      onToggleAvailability: _toggleAvailability,
      onCreateMenuItem: _createMenuItem,
      onUpdateMenuItem: _updateMenuItem,
      onDeleteMenuItem: _deleteMenuItem,
      onAddTable: _addTable,
      onUpdateTable: _updateTable,
      onDeleteTable: _deleteTable,
      onExportQrCode: _exportQrCode,
      onCreateStaffAccount: _createStaffAccount,
      onUpdateStaffAccount: _updateStaffAccount,
      onDeleteStaffAccount: _deleteStaffAccount,
      currentUser: _currentUser,
      onBackToGateway: () {
        ApiService.clearToken();
        setState(() {
          _isLoggedIn = false;
          _currentUser = null;
        });
      },
    );
  }
}
